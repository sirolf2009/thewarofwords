package com.sirolf2009.thewarofwords.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.Topic
import datomic.Connection
import datomic.Database
import datomic.Util
import java.io.StringReader
import java.util.List
import java.util.concurrent.atomic.AtomicReference
import org.eclipse.xtend.lib.annotations.Data
import org.slf4j.LoggerFactory

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class State implements IState {

	static val log = LoggerFactory.getLogger(State)
	val Connection connection
	val Database database

	override apply(Kryo kryo, Block block) {
		val topics = block.mutations.filter[object instanceof Topic].map[object as Topic].map[
			'''
				{:topic/name "«name»"
				 «tags.map[''':topic/tags «it»'''].join("\n")»]}'''
		].toList()
		val sources = block.mutations.filter[object instanceof Source].map[mutation|
			val it = mutation.object as Source
			'''
				{:source/source "«source»"
				 :source/type "«sourceType»"
				 :source/comment "«comment»"
				 :source/owner "«mutation.publicKey.encoded.toHexString()»"}'''
		].toList()

		//TODO references
		//TODO prepared statements
		
		val query = (topics+sources).join("[", "\n", "]", [toString()])
		log.info("executing query {}", query)
		val reader = new StringReader(query)
		val lastTx = new AtomicReference()
		val List<List<?>> statements = Util.readAll(reader)
		statements.forEach[
			lastTx.set(connection.transact(it).get())
		]

		return new State(connection, lastTx.get().get(Connection.DB_AFTER) as Database)
	}

}
