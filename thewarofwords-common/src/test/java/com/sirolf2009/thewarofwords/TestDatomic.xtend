package com.sirolf2009.thewarofwords

import com.sirolf2009.thewarofwords.common.Schema
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
import java.util.HashSet
import clojure.lang.PersistentVector

class TestDatomic {
	
	@Test
	def void testSchema() {
		val conn = scratchConnection()
		Schema.addSchema(conn)
		val topic = '''
		{:topic/hash "a52c1f10db3732590af183e06745381933440f4751130ecbfc55d4ed5ce7a943"
		 :topic/name "Awesome Things"
		 :topic/tags ["a" "b"]}'''
		val source = '''
		{:source/hash "f780a86f71959c8c77fc78a0322e7d33e6b5d1aa44734c1972958b5337e49ead"
		 :source/source "https://github.com/sirolf2009/thewarofwords"
		 :source/type "CITATION"
		 :source/comment "Look at this!"
		 :source/owner "30819f300d06092a864886f70d010101050003818d003081890281810094c3152b2dd7d1d350d09631d4add2c1aad1c193da09f576abeb43c54900d13a3c8f54564ca3a28079f03ce8df3ae0804bc3a00da868584fc9fa6edf15907d3fd1692b0b44abcd42098c5f3c01eae28bea2272e4a45c7393a8df525045262a86c10b237b8d8606af89d78d829afda5792350da77e0d3552d4ea4f6dffd91aefd0203010001"}'''
		val reference = 
		'''
		{:db/id [:topic/hash "a52c1f10db3732590af183e06745381933440f4751130ecbfc55d4ed5ce7a943"]
		 :topic/refers "f780a86f71959c8c77fc78a0322e7d33e6b5d1aa44734c1972958b5337e49ead"}''' 
		 
		 println(conn.transact(Util.readAll(new StringReader(topic))).get())
		 println(conn.transact(Util.readAll(new StringReader(source))).get())
		 println(conn.transact(Util.readAll(new StringReader(reference))).get())
		 
		 val getTopics =  '''
		[:find ?h ?n ?t
		 :where [?e topic/hash ?h]
		        [?e topic/name ?n]
		        [?e topic/tags ?t]]'''
		 val topics = query(getTopics, conn.db) as HashSet<PersistentVector>
		 println(topics.get(0))
		 println(topics.get(0).get(0))
		 println(query(getTopics, conn.db))
		 val getSources = '''
		 [:find ?e ?n ?t ?r
		  :where [?e :topic/hash "a52c1f10db3732590af183e06745381933440f4751130ecbfc55d4ed5ce7a943"]
		  		 [?e :topic/name ?n]
		  		 [?e :topic/tags ?t]
		  		 [?e :topic/refers ?r]]'''
		 println(query(getSources, conn.db))
	}
	
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