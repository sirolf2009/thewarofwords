package com.sirolf2009.thewarofwords.common

import clojure.lang.PersistentVector
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.CryptoHelper
import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.thewarofwords.common.model.Reference
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
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import java.util.TreeSet

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
			{:topic/hash "«mutation.hash(kryo).toHexString()»"
			 :topic/name "«name»"
			 «IF !tags.empty»
			 	:topic/tags [«tags.map['''"«it»"'''].join(" ")»]
			 «ENDIF»
			 }'''
		].toList()

		val sources = block.mutations.filter[object instanceof Source].toList()
		val sourcesQuery = sources.map [ mutation |
			val it = mutation.object as Source
			'''
			{:source/hash "«mutation.hash(kryo).toHexString()»"
			 :source/source "«source»"
			 :source/type "«sourceType»"
			 :source/comment "«comment»"
			 :source/owner "«mutation.publicKey.encoded.toHexString()»"}'''
		].toList()

		val references = block.mutations.filter[object instanceof Reference].toList()
		val referencesQuery = references.map [ mutation |
			val it = mutation.object as Reference
			'''
			{:db/id [:topic/hash "«topic.toHexString()»"]
			 :topic/refers "«source.toHexString()»"}'''
		].toList()

		val upvotes = block.mutations.filter[object instanceof Upvote].toList()
		val upvotesQuery = upvotes.map [ mutation |
			val it = mutation.object as Upvote
			'''
			{:upvote/hash "«mutation.hash(kryo).toHexString()»"
			 :upvote/voter "«voter.encoded.toHexString()»"
			 :upvote/source "«sourceHash.toHexString()»"
			 :upvote/topic "«topicHash.toHexString()»"}'''
		].toList()

		val blockQuery = '''
			{:block/hash "«block.hash(kryo).toHexString()»"
			 :block/number «blockNumber»
			 :block/previous-block "«block.header.previousBlock.toHexString()»"
			 :block/merkleroot "«block.header.merkleRoot.toHexString()»"
			 :block/time «block.header.time.time»
			 :block/target "«block.header.target.toByteArray().toHexString()»"
			 :block/nonce «block.header.nonce»
			 «topics.map['''"«hash(kryo).toHexString()»"'''].join(":block/added-topics [", " ", "]", [toString()])»
			 «sources.map['''"«hash(kryo).toHexString()»"'''].join(":block/added-sources [", " ", "]", [toString()])»
			 «references.map['''"«hash(kryo).toHexString()»"'''].join(":block/added-references [", " ", "]", [toString()])»}
		'''
		// TODO prepared statements
		log.debug("new topics and sources: {}", execute(topicsQuery + sourcesQuery))
		log.debug("new references and upvotes: {}", execute(referencesQuery + upvotesQuery))
		log.debug("new block: {}", execute(#[blockQuery]))

		return new State(connection, connection.db, blockNumber + 1)
	}

	def private execute(Iterable<String> queries) {
		val query = queries.join("[", "\n", "]", [toString()])
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
		response.map[database.entity(it)].map [
			get(":topic/hash") as String -> new Topic(get(":topic/name") as String, (get(":topic/tags") as Set<String>).toList())
		].toMap([key], [value])
	}

	def getBlocknumberForTopic(String topicHash) {
		queryVector('''
		[:find [?b ...]
		 :where [?block block/added-topics "«topicHash»"]
		 		[?block block/number ?b]]
		''').get(0)
	}

	def getBlocknumberForSource(String sourceHash) {
		queryVector('''
		[:find [?b ...]
		 :where [?block block/added-sources "«sourceHash»"]
		 		[?block block/number ?b]]
		''').get(0)
	}

	def getSources() {
		query('''
		[:find ?h ?s ?t ?c ?o
		 :where [?e source/hash ?h]
		        [?e source/source ?s]
		 	[?e source/type ?t]
		 	      [?e source/comment ?c]
		 	      [?e source/owner ?o]]''').parseSources()
	}

	def getSource(String sourceHash) {
		query('''
		[:find ?h ?s ?t ?c ?o
		 :where [?e source/hash "«sourceHash»"]
		 		[?e source/hash ?h]
		 		     [?e source/source ?s]
		 	[?e source/type ?t]
		 	      [?e source/comment ?c]
		 	      [?e source/owner ?o]]''').parseSources()
	}

	def getSources(String topicHash) {
		query('''
		[:find ?h ?s ?t ?c ?o
		 :where [?topic topic/hash "«topicHash»"]
		        [?topic topic/refers ?reference]
		        [?source source/hash ?reference]
		        [?source source/hash ?h]
		        [?source source/source ?s]
		        [?source source/type ?t]
		        [?source source/comment ?c]
		        [?source source/owner ?o]]''').parseSources()
	}

	def private parseSources(HashSet<PersistentVector> response) {
		val responseById = response.groupBy[get(0) as String]
		responseById.mapValues [
			val source = new URL(get(0).get(1) as String)
			val type = SourceType.valueOf(get(0).get(2) as String)
			val comment = get(0).get(3) as String
			val owner = CryptoHelper.publicKey((get(0).get(4) as String).toByteArray)
			return owner -> new Source(type, source, comment)
		]
	}

	def getUpvotes(PublicKey key) {
		queryVector('''
		[:find [?upvote ...]
		 :where [?source source/owner "«key.encoded.toHexString()»"]
		 		[?source source/hash ?source-hash]
		 		[?upvote upvote/source ?source-hash]]''')
	}
	
	def parseBlock(Object blockID) {
		val entity = database.entity(blockID)
		val previousBlock = entity.get(":block/previous-block") as String
		val merkleroot = entity.get(":block/merkleroot") as String
		val time = entity.get(":block/time") as Long
		val target = entity.get(":block/target") as String
		val nonce = entity.get(":block/nonce") as Long
		val sources = entity.get(":block/added-sources") as Set<String>
		val topics = entity.get(":block/added-topics") as Set<String>
		
		val header = new BlockHeader(previousBlock.toByteArray(), merkleroot.toByteArray(), new Date(time), new BigInteger(target.toByteArray()), nonce.intValue())
		return new Block(header, new TreeSet(#[sources.map[parseSource], topics.map[parseTopic]]))
	}
	
	def parseTopic(Object blockID) {
		val entity = database.entity(blockID)
		val name = entity.get(":topic/name") as String
		val tags = entity.get(":topic/tags") as Set<String>
		return new Topic(name, tags.toList())
	}
	
	def parseSource(Object blockID) {
		val entity = database.entity(blockID)
		val source = entity.get(":source/source") as String
		val comment = entity.get(":source/comment") as String
		val type = entity.get(":source/type") as String
		return new Source(SourceType.valueOf(type), new URL(source), comment)
	}

	def private query(String query) {
		log.debug("Executing query {}", query)
		return Peer.query(query, database) as HashSet<PersistentVector>
	}

	def private queryVector(String query) {
		log.debug("Executing query {}", query)
		return Peer.query(query, database) as PersistentVector
	}

}
