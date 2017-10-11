package com.sirolf2009.thewarofwords.node

import datomic.Connection
import datomic.Util
import java.io.StringReader

class Schema {
	
	def static addSchema(Connection conn) {
		val txes = Util.readAll(new StringReader('''
		[{:db/ident :topic/name
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one}
		  
		 {:db/ident :topic/tags
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/many}
		  		  
		 {:db/ident :source/source
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one}
		  
		 {:db/ident :source/comment
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one}
		  
		 {:db/ident :source/owner
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one}
		  
		 {:db/ident :source/type
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one}]'''))
		txes.forEach[
			conn.transact(it).get()
		]
	}
	
}