package com.sirolf2009.thewarofwords

import datomic.Connection
import datomic.Peer
import datomic.Util
import java.io.StringReader
import java.util.List
import java.util.UUID
import org.junit.Test

import static datomic.Connection.*
import static datomic.Peer.*
import static datomic.Util.*

class TestDatomic {
	
	@Test
	//https://github.com/Datomic/datomic-java-examples/blob/master/src/java/datomic/samples/CompareAndSwap.java
	def void test() {		
		val conn = scratchConnection()
		val List<List<?>> txes = Util.readAll(new StringReader('''
		[{:db/ident :topic/name
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one
		  :db.install/_attribute :db.part/db}
		 {:db/ident :topic/tags
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/many
		  :db.install/_attribute :db.part/db}]'''))
		txes.forEach[
			println("Schema: "+conn.transact(it).get())
		]
		
		val List<List<?>> put = Util.readAll(new StringReader('''
		[{:topic/name "testTopic"
		  :topic/tags ["test" "datomic"]}]'''))
		put.forEach[
			println("testTopic:" +conn.transact(it).get())
		]
		
		val topic = tempid(":db.part/user")
		val tx = conn.transact(list(
			map(":db/id", topic, ":topic/name", "test"),
			map(":db/id", topic, ":topic/tags", "test"),
			map(":db/id", topic, ":topic/tags", "topic")
		)).get()
		println("topic: "+tx)
		
		println(query('''
		[:find ?e ?topic-name
		 :where [?e :topic/tags ?topic-name]]'''.toString(), conn.db))
		
		println(query('''
		[:find ?e ?topic-name
		 :where [?e :topic/tags ?topic-name]]'''.toString(), tx.get(DB_AFTER)))
		
		println(query('''
		[:find ?e
		 :in $ ?name
		 :where [?e :topic/name ?name]]'''.toString(), conn.db, "testTopic"))
		 
		println(query('''
		[:find ?name
		 :in $ ?tags
		 :where [?e :topic/name ?name]
		 		[?e :topic/tags ?tags]]'''.toString(), conn.db, "test"))
		println(query('''
		[:find ?name
		 :in $ ?tags
		 :where [?e :topic/name ?name]
		 		[?e :topic/tags ?tags]]'''.toString(), conn.db, "datomic"))
	}

	def static Connection scratchConnection() {
		val uri = "datomic:mem://" + UUID.randomUUID()
		Peer.createDatabase(uri)
		return Peer.connect(uri)
	}
	
}