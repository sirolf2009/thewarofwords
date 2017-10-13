package com.sirolf2009.thewarofwords.common

import clojure.lang.PersistentVector
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.Topic
import datomic.Connection
import datomic.Database
import datomic.Peer
import datomic.Util
import java.io.StringReader
import java.util.HashSet
import java.util.List
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import java.util.stream.Collectors

@Data class State implements IState {

	static val log = LoggerFactory.getLogger(State)
	val Connection connection
	val Database database

	override apply(Kryo kryo, Block block) {
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
		
		val query = (topics+sources+references).join("[", "\n", "]", [toString()])
		log.info("executing query {}", query)
		val reader = new StringReader(query)
		val lastTx = new AtomicReference()
		val List<List<?>> statements = Util.readAll(reader)
		statements.forEach[
			lastTx.set(connection.transact(it).get())
		]

		return new State(connection, lastTx.get().get(Connection.DB_AFTER) as Database)
	}
	
	def getTopics() {
		val query = '''
		[:find ?h ?n ?t
		 :where [?e topic/hash ?h]
		        [?e topic/name ?n]
		        [?e topic/tags ?t]]'''
		val response = Peer.query(query, database) as HashSet<PersistentVector>
		val responseById = response.groupBy[get(0) as String]
		responseById.mapValues[
			val name = get(0).get(1) as String
			val tags = map[get(2) as String].stream.distinct.collect(Collectors.toList())
			return new Topic(name, tags)
		]
	}
	
	def getSource(String hash) {
		
	}

}
