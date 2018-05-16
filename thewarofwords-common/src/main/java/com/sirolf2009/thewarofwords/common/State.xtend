package com.sirolf2009.thewarofwords.common

import clojure.lang.PersistentVector
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.CryptoHelper
import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.model.Account
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.common.model.SavedUpvote
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.Upvote
import datomic.Connection
import datomic.Database
import datomic.Peer
import datomic.Util
import java.io.StringReader
import java.math.BigInteger
import java.net.URL
import java.security.PublicKey
import java.util.Date
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Set
import java.util.TreeSet
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

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
			val sourceOpt = vector.stream().map[parseSource(it, connection.db)].findFirst()
			val source = sourceOpt.get()
			val credit = getCredit(new SavedUpvote(mutation.hash(kryo), upvote))
			val account = source.getOwner().getAccount().map[new Account(key, username, credibility + credit)].orElse(new Account(source.getOwner(), source.getOwner().encoded.toHexString(), credit))
			execute(#['''
			{:account/key "«account.getKey().encoded.toHexString()»"
			 :account/username "«account.getUsername()»"
			 :account/credibility «account.getCredibility()»}'''])
		]

		return new State(connection, connection.db, blockNumber + 1)
	}
	
	def getCredit(SavedSource source) {
		getUpvotes(source.getHash()).stream().map[getCredit()].reduce[a,b|a+b].orElse(0d)
	}

	def getCredit(SavedUpvote upvote) {
		val query = '''
		[:find [?e ...]
		 :where [?e source/hash "«upvote.getUpvote().getSourceHash()»"]
		 		[?upvote upvote/source "«upvote.getUpvote().getSourceHash()»"]
		 		[?upvote upvote/hash "«upvote.getHash()»"]]'''
		val vector = queryVector(query, connection.db)
		val sourceOpt = vector.stream().map[parseSource(it, connection.db)].findFirst()
		val source = sourceOpt.orElseThrow[new RuntimeException("Could not find source accompanying "+upvote)]
		return switch (source.getSource().getSourceType()) {
			case TRUSTED: 100
			case CITATION: 80
			case VIDEO: 60
			case ARTICLE: 40
			case TWEET: 20
		} * getAccount(upvote.getUpvote().getVoter()).map[1 + credibility / 100].orElse(1d)
		//TODO when in prod, a certain amount of credibility must already be assigned before credit counts
	}

	override toString() {
		'''State for block «blockNumber»'''
	}

	def getAccount(PublicKey account) {
		queryVector('''
		[:find [?e ...]
		 :where [?e account/key "«account.encoded.toHexString()»"]]''').stream().map[parseAccount()].findFirst()
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

	def getTopics() {
		val response = queryVector('''
		[:find [?e ...]
		 :where [?e topic/hash _]]''')
		response.map [parseTopic(it)].toList()
	}
	
	def getTopic(Hash topicHash) {
		queryVector('''
		[:find [?e ...]
		 :where [?e topic/hash "«topicHash»"]]''').stream().map[parseTopic()].findFirst()
	}

	def getBlocknumberForTopic(Hash topicHash) {
		queryVector('''
			[:find [?b ...]
			 :where [?block block/added-topics "«topicHash»"]
			 		[?block block/number ?b]]
		''').get(0)
	}

	def getBlocknumberForSource(Hash sourceHash) {
		queryVector('''
			[:find [?b ...]
			 :where [?block block/added-sources "«sourceHash»"]
			 		[?block block/number ?b]]
		''').get(0)
	}

	def hasUpvoted(PublicKey key, Hash source, Hash topic) {
		query('''
			[:find ?t
			 :where [?t upvote/voter "«key.encoded.toHexString()»"]
			 		[?t upvote/topic "«topic»"]
			 		[?t upvote/source "«source»"]]
		''').size() > 0
	}

	def getSources() {
		queryVector('''
		[:find [?e ...]
		 :where [?e source/hash _]]''').map[parseSource()]
	}

	def getSource(Hash sourceHash) {
		queryVector('''
		[:find [?e ...]
		 :where [?e source/hash "«sourceHash»"]]''').stream().map[parseSource()].findFirst()
	}

	def getSources(Hash topicHash) {
		queryVector('''
		[:find [?e ...]
		 :where [?topic topic/hash "«topicHash»"]
		        [?topic topic/refers ?reference]
		        [?e source/hash ?reference]]''').map[parseSource()]
	}

	def getUpvotes(PublicKey key) {
		queryVector('''
		[:find [?upvote ...]
		 :where [?source source/owner "«key.encoded.toHexString()»"]
		 		[?source source/hash ?source-hash]
		 		[?upvote upvote/source ?source-hash]]''').map[parseUpvote()]
	}

	def getUpvotes(Hash sourceHash) {
		queryVector('''
		[:find [?upvote ...]
		 :where [?upvote upvote/source "«sourceHash»"]]''').map[parseUpvote()]
	}

	def getUpvote(Hash upvoteHash) {
		getUpvote(upvoteHash, database)
	}

	def getUpvote(Hash upvoteHash, Database database) {
		queryVector('''
		[:find [?upvote ...]
		 :where [?upvote upvote/hash "«upvoteHash»"]]''').stream().map[parseUpvote(database)].findFirst()
	}

	def protected parseAccount(Object blockID) {
		val entity = database.entity(blockID)
		val key = CryptoHelper.publicKey((entity.get(":account/key") as String).toByteArray)
		val username = entity.get(":account/username") as String
		val credibility = entity.get(":account/credibility") as Double
		return new Account(key, username, credibility)
	}

	def protected parseBlock(Object blockID) {
		val entity = database.entity(blockID)
		val previousBlock = entity.get(":block/previous-block") as String
		val merkleroot = entity.get(":block/merkleroot") as String
		val time = entity.get(":block/time") as Long
		val target = entity.get(":block/target") as String
		val nonce = entity.get(":block/nonce") as Long
		val sources = entity.get(":block/added-sources") as Set<String>
		val topics = entity.get(":block/added-topics") as Set<String>

		val header = new BlockHeader(new Hash(previousBlock), new Hash(merkleroot), new Date(time), new BigInteger(target.toByteArray()), nonce.intValue())
		return new Block(header, new TreeSet(#[sources.map[parseSource().getSource()], topics.map[parseTopic().getTopic()]]))
	}

	def protected parseTopic(Object blockID) {
		val entity = database.entity(blockID)
		val hash = new Hash(entity.get(":topic/hash") as String)
		val name = entity.get(":topic/name") as String
		val description = entity.get(":topic/description") as String
		val tags = entity.get(":topic/tags") as Set<String>
		val image = new URL(entity.get(":topic/image") as String)
		return new SavedTopic(hash, new Topic(name, description, tags, image))
	}

	def protected parseUpvote(Object blockID) {
		return parseUpvote(blockID, database)
	}

	def protected parseUpvote(Object blockID, Database database) {
		val entity = database.entity(blockID)
		val hash = new Hash(entity.get(":upvote/hash") as String)
		val voter = CryptoHelper.publicKey((entity.get(":upvote/voter") as String).toByteArray())
		val source = new Hash(entity.get(":upvote/source") as String)
		val topic = new Hash(entity.get(":upvote/topic") as String)
		return new SavedUpvote(hash, new Upvote(voter, source, topic))
	}

	def protected parseSource(Object sourceHash) {
		return parseSource(sourceHash, database)
	}

	def protected parseSource(Object sourceHash, Database database) {
		val entity = database.entity(sourceHash)
		val hash = new Hash(entity.get(":source/hash") as String)
		val owner = CryptoHelper.publicKey((entity.get(":source/owner") as String).toByteArray())
		val source = entity.get(":source/source") as String
		val comment = entity.get(":source/comment") as String
		val type = entity.get(":source/type") as String
		return new SavedSource(hash, owner, new Source(SourceType.valueOf(type), new URL(source), comment))
	}

	def private query(String query) {
		return query(query, database)
	}

	def private static query(String query, Database database) {
		log.debug("Executing query {}", query)
		return Peer.query(query, database) as HashSet<PersistentVector>
	}

	def private queryVector(String query) {
		return queryVector(query, database)
	}

	def private static queryVector(String query, Database database) {
		log.debug("Executing query {}", query)
		return Peer.query(query, database) as PersistentVector
	}

}
