package com.sirolf2009.thewarofwords

import datomic.Connection
import datomic.Peer
import java.util.UUID
import org.junit.Test
import datomic.Util
import java.io.StringReader

class TestDatomic {
	
	@Test
	//https://github.com/Datomic/datomic-java-examples/blob/master/src/java/datomic/samples/CompareAndSwap.java
	def void test() {
		val conn = scratchConnection()
		val txes = Util.readAll(new StringReader('''
		[{:db/id #db/id[:db.part/db]
		  :db/ident :account/balance
		  :db/valueType :db.type/long
		  :db/cardinality :db.cardinality/one
		:db.install/_attribute :db.part/db}]'''))
		txes.forEach[
			println(conn.transact(it).get())
		]
	}

	def static Connection scratchConnection() {
		val uri = "datomic:mem://" + UUID.randomUUID()
		Peer.createDatabase(uri)
		return Peer.connect(uri)
	}
	
}