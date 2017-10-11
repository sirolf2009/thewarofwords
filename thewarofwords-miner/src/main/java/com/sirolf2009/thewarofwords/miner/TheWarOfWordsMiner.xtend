package com.sirolf2009.thewarofwords.miner

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.mining.model.Miner
import com.sirolf2009.thewarofwords.node.Options
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import java.io.File
import java.net.InetSocketAddress
import java.security.KeyPair
import java.util.List
import org.slf4j.LoggerFactory
import picocli.CommandLine

class TheWarOfWordsMiner extends Miner {
	
	static val log = LoggerFactory.getLogger(TheWarOfWordsMiner)
	
	new(List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		super(log, TheWarOfWordsNode.configuration(), [TheWarOfWordsNode.kryo()], trackers, nodePort, keys)
	}

	def static void main(String[] args) {
		val options = CommandLine.populateCommand(new Options(), args)

		val trackers = options.trackers.map [
			val data = split(":")
			if(data.size() != 2) {
				log.error("Invalid data format: " + it)
				CommandLine.usage(new Options(), System.out)
				System.exit(-1)
				return null // wow, java
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

		new TheWarOfWordsMiner(trackers, options.port, new KeyPair(publicKey, privateKey)).start()
	}
	
}