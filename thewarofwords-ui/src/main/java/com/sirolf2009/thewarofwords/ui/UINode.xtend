package com.sirolf2009.thewarofwords.ui

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryonet.Connection
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import java.net.InetSocketAddress
import java.security.KeyPair
import java.util.List
import javafx.beans.property.BooleanProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.StringProperty
import org.eclipse.xtend.lib.annotations.Accessors
import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import javafx.beans.property.IntegerProperty
import javafx.beans.property.SimpleIntegerProperty

@Accessors class UINode extends TheWarOfWordsNode {
	
	val BooleanProperty isConnected
	val StringProperty lastBlock
	val IntegerProperty nodes
	
	new(List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		super(trackers, nodePort, keys)
		isConnected = new SimpleBooleanProperty(false)
		lastBlock = new SimpleStringProperty()
		nodes = new SimpleIntegerProperty(0)
	}
	
	override synchronized onNewConnection(Kryo kryo, Connection connection) {
		isConnected.set(true)
		nodes.add(1)
		super.onNewConnection(kryo, connection)
	}
	
	override onDisconnected(Connection connection) {
		nodes.subtract(1)
		if(nodes.get() == 0) {
			isConnected.set(false)
		}
		super.onDisconnected(connection)
	}
	
	override onBranchExpanded() {
		lastBlock.set(hash(blockchain.mainBranch.getLastBlock()).toHexString())
	}
	
}