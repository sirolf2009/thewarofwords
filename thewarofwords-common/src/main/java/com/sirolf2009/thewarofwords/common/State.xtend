package com.sirolf2009.thewarofwords.common

import clojure.lang.PersistentVector
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.model.Account
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.SavedUpvote
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.Upvote
import datomic.Connection
import datomic.Database
import datomic.Peer
import datomic.Util
import java.io.StringReader
import java.security.PublicKey
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.thewarofwords.common.datomic.ParseExtensions.*

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import io.reactivex.Observable

@Data class State implements IState {

	static val log = LoggerFactory.getLogger(State)
	val Connection connection
	val Database database
	val int blockNumber

	override apply(Kryo kryo, Block block) {
		log.debug("Applying block {}", block.toString(kryo))

		val topics = block.mutations.filter[object instanceof Topic].toList()
		val topicsQuery = topics.map [ mutation |
			val it = mutation.object as Topic
			'''
			{:topic/hash "«mutation.hash(kryo)»"
			 :topic/name "«name»"
			 :topic/description "«description»"
			 «IF !tags.empty»
			 	:topic/tags [«tags.map['''"«it»"'''].join(" ")»]
			 «ENDIF»
			 :topic/image "«getImage().toExternalForm()»"
			 }'''
		].toList()

		val sources = block.mutations.filter[object instanceof Source].toList()
		val sourcesQuery = sources.map [ mutation |
			val it = mutation.object as Source
			'''
			{:source/hash "«mutation.hash(kryo)»"
			 :source/source "«source»"
			 :source/type "«sourceType»"
			 :source/comment "«comment»"
			 :source/owner "«mutation.publicKey.encoded.toHexString()»"}'''
		].toList()

		val references = block.mutations.filter[object instanceof Reference].toList()
		val referencesQuery = references.map [ mutation |
			val it = mutation.object as Reference
			'''
			{:db/id [:topic/hash "«topic»"]
			 :topic/refers "«source»"}'''
		].toList()

		val upvotes = block.mutations.filter[object instanceof Upvote].toList()
		val upvotesQuery = upvotes.map [ mutation |
			val it = mutation.object as Upvote
			'''
			{:upvote/hash "«mutation.hash(kryo)»"
			 :upvote/voter "«voter.encoded.toHexString()»"
			 :upvote/source "«sourceHash»"
			 :upvote/topic "«topicHash»"}'''
		].toList()

		val blockQuery = '''
			{:block/hash "«block.hash(kryo)»"
			 :block/number «blockNumber»
			 :block/previous-block "«block.header.previousBlock»"
			 :block/merkleroot "«block.header.merkleRoot»"
			 :block/time «block.header.time.time»
			 :block/target "«block.header.target.toByteArray().toHexString()»"
			 :block/nonce «block.header.nonce»
			 «topics.map['''"«hash(kryo)»"'''].join(":block/added-topics [", " ", "]", [toString()])»
			 «sources.map['''"«hash(kryo)»"'''].join(":block/added-sources [", " ", "]", [toString()])»
			 «references.map['''"«hash(kryo)»"'''].join(":block/added-references [", " ", "]", [toString()])»}
		'''
		// TODO prepared statements
		log.trace("new topics and sources: {}", execute(topicsQuery + sourcesQuery))
		log.trace("new references and upvotes: {}", execute(referencesQuery + upvotesQuery))
		log.trace("new block: {}", execute(#[blockQuery]))

		upvotes.forEach [ mutation |
			val upvote = mutation.object as Upvote
			val query = '''
			[:find [?e ...]
			 :where [?e source/hash "«upvote.sourceHash»"]]'''
			val vector = queryVector(query, connection.db)
			val source = vector.firstOrError().map[parseSource(connection.db)].blockingGet()
			val credit = getCredit(new SavedUpvote(mutation.hash(kryo), upvote), connection.db).toSingle().blockingGet()
			val account = source.getOwner().getAccount().map[new Account(key, username, credibility + credit)].blockingGet(new Account(source.getOwner(), source.getOwner().encoded.toHexString(), credit))
			execute(#['''
			{:account/key "«account.getKey().encoded.toHexString()»"
			 :account/username "«account.getUsername()»"
			 :account/credibility «account.getCredibility()»}'''])
		]

		return new State(connection, connection.db, blockNumber + 1)
	}

	def getCredit(SavedSource source) {
		getUpvotes(source.getHash()).map[getCredit().blockingGet(0d)].toList().map[reduce[a,b|a+b]]
	}

	def getCredit(SavedUpvote upvote) {
		getCredit(upvote, database)
	}

	def getCredit(SavedUpvote upvote, Database database) {
		val query = '''
		[:find [?e ...]
		 :where [?e source/hash "«upvote.getUpvote().getSourceHash()»"]
		 		[?upvote upvote/source "«upvote.getUpvote().getSourceHash()»"]
		 		[?upvote upvote/hash "«upvote.getHash()»"]]'''
		val vector = queryVector(query, database)
		vector.firstElement().map[parseSource(database)].map [
			return switch (getSource().getSourceType()) {
				case TRUSTED: 100
				case CITATION: 80
				case VIDEO: 60
				case ARTICLE: 40
				case TWEET: 20
			} * getAccount(upvote.getUpvote().getVoter()).map[1 + credibility / 100].blockingGet(1d)
		]
	// TODO when in prod, a certain amount of credibility must already be assigned before credit counts
	}

	override toString() {
		'''State for block «blockNumber»'''
	}

	def getAccount(PublicKey account) {
		queryVector('''
		[:find [?e ...]
		 :where [?e account/key "«account.encoded.toHexString()»"]]''').firstElement().map[parseAccount(database)]
	}

	def private execute(Iterable<String> queries) {
		val query = queries.join("[", "\n", "]", [toString()])
		if(query.empty) {
			return null
		}
		log.debug("executing query {}", query)
		val reader = new StringReader(query)
		val lastTx = new AtomicReference()
		val List<List<?>> statements = Util.readAll(reader)
		statements.forEach [
			lastTx.set(connection.transact(it).get() as Map<?, ?>)
		]
		return lastTx.get()
	}

	def getSourcesForTopicSince(Hash topicHash, long since) {
		queryVector('''
			[:find [?e ...]
			 :where [?t topic/hash "«topicHash»"]
			        [?t topic/refers ?e]
			        [?b block/added-sources ?e]
			        [?b block/time ?m]
			        [(< ?m «since»)]]
		       ''').map[parseSource(database)]
	}

	def getTopics() {
		queryVector('''
		[:find [?e ...]
		 :where [?e topic/hash _]]''').map[parseTopic(database)]
	}

	def getTopic(Hash topicHash) {
		queryVector('''
		[:find [?e ...]
		 :where [?e topic/hash "«topicHash»"]]''').firstElement().map[parseTopic(database)]
	}

	def getBlocknumberForTopic(Hash topicHash) {
		queryVector('''
			[:find [?b ...]
			 :where [?block block/added-topics "«topicHash»"]
			 		[?block block/number ?b]]
		''').firstElement().map[it as Long]
	}

	def getBlocknumberForSource(Hash sourceHash) {
		queryVector('''
			[:find [?b ...]
			 :where [?block block/added-sources "«sourceHash»"]
			 		[?block block/number ?b]]
		''').firstElement().map[it as Long]
	}

	def getBlock(long number) {
		queryVector('''
			[:find [?b ...]
			 :where [?block block/number «number»]]
		''').firstElement().map[parseBlock(database)]
	}

	def hasUpvoted(PublicKey key, Hash source, Hash topic) {
		query('''
			[:find ?t
			 :where [?t upvote/voter "«key.encoded.toHexString()»"]
			 		[?t upvote/topic "«topic»"]
			 		[?t upvote/source "«source»"]]
		''').isEmpty().map[!it]
	}

	def getSources() {
		queryVector('''
		[:find [?e ...]
		 :where [?e source/hash _]]''').map[parseSource(database)]
	}

	def getSource(Hash sourceHash) {
		queryVector('''
		[:find [?e ...]
		 :where [?e source/hash "«sourceHash»"]]''').firstElement().map[parseSource(database)]
	}

	def getSources(Hash topicHash) {
		queryVector('''
		[:find [?e ...]
		 :where [?topic topic/hash "«topicHash»"]
		        [?topic topic/refers ?reference]
		        [?e source/hash ?reference]]''').map[parseSource(database)]
	}

	def getUpvotes(PublicKey key) {
		queryVector('''
		[:find [?upvote ...]
		 :where [?source source/owner "«key.encoded.toHexString()»"]
		 		[?source source/hash ?source-hash]
		 		[?upvote upvote/source ?source-hash]]''').map[parseUpvote(database)]
	}

	def getUpvotes(Hash sourceHash) {
		queryVector('''
		[:find [?upvote ...]
		 :where [?upvote upvote/source "«sourceHash»"]]''').map[parseUpvote(database)]
	}

	def getUpvote(Hash upvoteHash) {
		getUpvote(upvoteHash, database)
	}

	def getUpvote(Hash upvoteHash, Database database) {
		queryVector('''
		[:find [?upvote ...]
		 :where [?upvote upvote/hash "«upvoteHash»"]]''').firstElement().map[parseUpvote(database)]
	}

	def private query(String query) {
		return query(query, database)
	}

	def private static query(String query, Database database) {
		Observable.create [
			try {
				log.debug("Executing query {}", query)
				(Peer.query(query, database) as HashSet<PersistentVector>).forEach [ item |
					onNext(item)
				]
				onComplete()
			} catch(Exception e) {
				onError(e)
			}
		]
	}

	def private queryVector(String query) {
		return queryVector(query, database)
	}

	def private static queryVector(String query, Database database) {
		Observable.create [
			try {
				log.debug("Executing query {}", query)
				(Peer.query(query, database) as PersistentVector).forEach [ item |
					onNext(item)
				]
				onComplete()
			} catch(Exception e) {
				onError(e)
			}
		]
	}

}
