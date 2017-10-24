package com.sirolf2009.thewarofwords.node

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Configuration
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.node.Node
import com.sirolf2009.thewarofwords.common.Schema
import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.Upvote
import com.sirolf2009.thewarofwords.common.serializer.SerializerReference
import com.sirolf2009.thewarofwords.common.serializer.SerializerSource
import com.sirolf2009.thewarofwords.common.serializer.SerializerSourceType
import com.sirolf2009.thewarofwords.common.serializer.SerializerTopic
import com.sirolf2009.thewarofwords.common.serializer.SerializerUpvote
import datomic.Peer
import java.io.File
import java.net.InetSocketAddress
import java.security.KeyPair
import java.util.List
import org.slf4j.LoggerFactory
import picocli.CommandLine

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class TheWarOfWordsNode extends Node {

	static val log = LoggerFactory.getLogger(TheWarOfWordsNode)

	new(List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		super(log, configuration(), [kryo()], trackers, nodePort, keys)
	}
	
	override isValid(Mutation mutation) {
		val state = blockchain.mainBranch.lastState as State
		if(mutation.object instanceof Source) {
			try {
				(mutation.object as Source).verify()
				return true
			} catch(Exception e) {
				log.error("Failed to verify source mutation", e)
				return false
			}
		} else if(mutation.object instanceof Upvote) {
			try {
				return !state.getSource((mutation.object as Upvote).sourceHash.toHexString()).isEmpty()
			} catch(Exception e) {
				log.error("Failed to verify upvote mutation", e)
				return false
			}
		}
		return true
	}

	def static configuration() {
		val uri = "datomic:mem://thewarofwords"
		Peer.createDatabase(uri)
		val conn = Peer.connect(uri)
		Schema.addSchema(conn)
		return new Configuration.Builder().setGenesisState(new State(conn, conn.db)).build()
	}

	def static kryo() {
		val kryo = new Kryo()
		kryo.register(SourceType, new SerializerSourceType())
		kryo.register(Source, new SerializerSource())
		kryo.register(Topic, new SerializerTopic())
		kryo.register(Reference, new SerializerReference())
		kryo.register(Upvote, new SerializerUpvote())
		return kryo
	}

	def static void main(String[] args) {
		val options = CommandLine.populateCommand(new Options(), args)

		val trackers = options.trackers.map [
			val data = split(":")
			if(data.size() != 2) {
				log.error("Invalid data format: " + it)
				CommandLine.usage(new Options(), System.out)
				System.exit(-1)
				return null //wow, java
			} else {
				return new InetSocketAddress(data.get(0), Integer.parseInt(data.get(1)))
			}
		]

		val keyLocations = options.keys.split(":")
		if(keyLocations.size() != 2) {
			log.error("Invalid keys format: " + keyLocations)
			CommandLine.usage(new Options(), System.out)
		}
		val privateKey = Keys.readPrivateKeyFromFile(new File(keyLocations.get(0)))
		val publicKey = Keys.readPublicKeyFromFile(new File(keyLocations.get(1)))

		new TheWarOfWordsNode(trackers, options.port, new KeyPair(publicKey, privateKey)).start()
	}

}