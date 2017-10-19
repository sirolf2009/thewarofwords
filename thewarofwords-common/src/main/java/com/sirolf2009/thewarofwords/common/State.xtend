package com.sirolf2009.thewarofwords.common

import clojure.lang.PersistentVector
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.CryptoHelper
import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import datomic.Connection
import datomic.Database
import datomic.Peer
import datomic.Util
import java.io.StringReader
import java.net.URL
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class State implements IState {

	static val log = LoggerFactory.getLogger(State)
	val Connection connection
	val Database database

	override apply(Kryo kryo, Block block) {
		log.debug("Applying block {}", block.toString(kryo))
		val topics = block.mutations.filter[object instanceof Topic].map[mutation|
			val it = mutation.object as Topic
			'''
				{:topic/hash "«mutation.hash(kryo).toHexString()»"
				 :topic/name "«name»"
				 «IF !tags.empty»
				 :topic/tags [«tags.map['''"«it»"'''].join(" ")»]
				 «ENDIF»
				 }'''
		].toList()
		val sources = block.mutations.filter[object instanceof Source].map[mutation|
			val it = mutation.object as Source
			'''
				{:source/hash "«mutation.hash(kryo).toHexString()»"
				 :source/source "«source»"
				 :source/type "«sourceType»"
				 :source/comment "«comment»"
				 :source/owner "«mutation.publicKey.encoded.toHexString()»"}'''
		].toList()

		val references = block.mutations.filter[object instanceof Reference].map[mutation|
			val it = mutation.object as Reference
			'''
			 {:db/id [:topic/hash "«topic.toHexString()»"]
			  :topic/refers "«source.toHexString()»"}'''
		].toList()
		//TODO prepared statements
		
		log.debug("new topics and sources: {}", execute(topics + sources))
		log.debug("new references: {}", execute(references))

		return new State(connection, connection.db)
	}
	
	def private execute(Iterable<String> queries) {
		val query = queries.join("[", "\n", "]", [toString()])
		log.debug("executing query {}", query)
		val reader = new StringReader(query)
		val lastTx = new AtomicReference()
		val List<List<?>> statements = Util.readAll(reader)
		statements.forEach[
			lastTx.set(connection.transact(it).get() as Map<?, ?>)
		]
		return lastTx.get()
	}
	
	def getTopics() {
		val query = '''
		[:find [?e ...]
		 :where [?e topic/hash _]]'''
		log.debug("executing query {}", query)
		val response = Peer.query(query, database) as PersistentVector
		response.map[database.entity(it)].map[
			get(":topic/hash") as String -> new Topic(get(":topic/name") as String, get(":topic/tags") as List<String>)
		].toMap([key], [value])
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
		responseById.mapValues[
			val source = new URL(get(0).get(1) as String)
			val type = SourceType.valueOf(get(0).get(2) as String)
			val comment = get(0).get(3) as String
			val owner = CryptoHelper.publicKey((get(0).get(4) as String).toByteArray)
			return owner -> new Source(type, source, comment)
		]
	}
	
	def private query(String query) {
		log.debug("Executing query {}", query)
		return Peer.query(query, database) as HashSet<PersistentVector>
	}

}
