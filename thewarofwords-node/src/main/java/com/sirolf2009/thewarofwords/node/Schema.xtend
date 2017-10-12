package com.sirolf2009.thewarofwords.node

import datomic.Connection
import datomic.Util
import java.io.StringReader
import java.util.List

class Schema {
	
	def static addSchema(Connection conn) {
		val List<List<?>> txes = Util.readAll(new StringReader('''
		[{:db/ident :topic/hash
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one
		  :db/unique :db.unique/identity}
		
		 {:db/ident :topic/name
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one}
		  
		 {:db/ident :topic/tags
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/many}
		  		  
		 {:db/ident :topic/refers
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/many}
		  		  		  
		 {:db/ident :source/hash
		  :db/valueType :db.type/string
		  :db/cardinality :db.cardinality/one
		  :db/unique :db.unique/identity}
		  		  
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