package com.sirolf2009.thewarofwords.common

import datomic.Connection
import datomic.Util
import java.io.StringReader
import java.util.List

class Schema {

	def static addSchema(Connection conn) {
		val List<List<?>> txes = Util.readAll(new StringReader('''
[{:db/ident :block/hash
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/one
  :db/unique :db.unique/identity}
  
 {:db/ident :block/number
  :db/valueType :db.type/long
  :db/cardinality :db.cardinality/one}
  
 {:db/ident :block/added-sources
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/many}
 
 {:db/ident :block/added-topics
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/many}
 
 {:db/ident :block/added-references
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/many}
  
    
 {:db/ident :topic/hash
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
  :db/cardinality :db.cardinality/one}
  
  
 {:db/ident :upvote/hash
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/one
  :db/unique :db.unique/identity}
  		  		  
 {:db/ident :upvote/voter
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/one}
  		  		  
 {:db/ident :upvote/source
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/one}
  		  		  		  
 {:db/ident :upvote/topic
  :db/valueType :db.type/string
  :db/cardinality :db.cardinality/one}]'''))
		txes.forEach [
			conn.transact(it).get()
		]
	}

}
