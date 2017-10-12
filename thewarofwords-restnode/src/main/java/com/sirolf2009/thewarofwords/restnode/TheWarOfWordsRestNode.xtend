package com.sirolf2009.thewarofwords.restnode

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.objectchain.network.node.NewMutation
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import java.io.File
import java.net.InetSocketAddress
import java.net.URL
import java.security.KeyPair
import java.util.List
import org.slf4j.LoggerFactory
import picocli.CommandLine

import static spark.Spark.*

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class TheWarOfWordsRestNode extends TheWarOfWordsNode {

	static val log = LoggerFactory.getLogger(TheWarOfWordsRestNode)

	val int restPort

	new(List<InetSocketAddress> trackers, int nodePort, int restPort, KeyPair keys) {
		super(trackers, nodePort, keys)
		this.restPort = restPort
	}

	override start() {
		super.start()
		port(restPort)
		
		get("/lastblock") [req,res|
			kryoPool.run[blockchain.mainBranch.lastBlock.toString(it)]
		]
		
		post("/source") [ req, res |
			val sourceType = req.queryParams("sourceType")
			val source = req.queryParams("source")
			val comment = req.queryParams("comment")
			if(sourceType === null) {
				res.status(400)
				return "missing sourceType param"
			}
			if(source === null) {
				res.status(400)
				return "missing source param"
			}
			val mutation = kryoPool.run[kryo| new Mutation(new Source(SourceType.valueOf(sourceType), new URL(source.sanitize), sanitize(if(comment !== null) comment else "")), kryo, keys)]
			floatingMutations.add(mutation)
			val message = new NewMutation() => [
				it.mutation = mutation
			]
			message.broadcast()
			res.status(200)
			return kryoPool.run[mutation.toString(it)]
		]
		
		post("/topic") [ req, res |
			val name = req.queryParams("name")
			val tags = req.queryParamsValues("tag")
			if(name === null) {
				res.status(400)
				return "missing name param"
			}
			val mutation = kryoPool.run[kryo| new Mutation(new Topic(name.sanitize(), if(tags === null) #[] else tags), kryo, keys)]
			floatingMutations.add(mutation)
			val message = new NewMutation() => [
				it.mutation = mutation
			]
			message.broadcast()
			res.status(200)
			return kryoPool.run[mutation.toString(it)]
		]
		
		post("/refer") [ req, res |
			val topic = req.queryParams("topic")
			val source = req.queryParams("source")
			if(topic === null) {
				res.status(400)
				return "missing topic param"
			}
			if(source === null) {
				res.status(400)
				return "missing source param"
			}
			val mutation = kryoPool.run[kryo| new Mutation(new Reference(topic.toByteArray(), source.toByteArray()), kryo, keys)]
			floatingMutations.add(mutation)
			val message = new NewMutation() => [
				it.mutation = mutation
			]
			message.broadcast()
			res.status(200)
			return kryoPool.run[mutation.toString(it)]
		]
		
		log.info("Hosting REST api on port {}", restPort)
	}
	
	def static sanitize(String string) {
		return string.replace("\"", "\\\"").replace("\'", "\\\'")
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

		new TheWarOfWordsRestNode(trackers, options.port, options.restPort, new KeyPair(publicKey, privateKey)).start()
	}

}
