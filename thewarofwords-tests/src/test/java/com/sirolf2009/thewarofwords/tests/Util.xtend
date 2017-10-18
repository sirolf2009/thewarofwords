package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.thewarofwords.miner.TheWarOfWordsMiner
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import com.sirolf2009.thewarofwords.node.TheWarOfWordsTracker
import java.net.InetSocketAddress
import java.util.concurrent.atomic.AtomicReference

class Util {
	
	def static submitMutation(AtomicReference<TheWarOfWordsNode> node, Object object) {
		node.get().submitMutation(object)
	}
	
	def static createTracker(AtomicReference<TheWarOfWordsTracker> tracker) {
		tracker.createTracker("Tracker")		
	}
	
	def static createTracker(AtomicReference<TheWarOfWordsTracker> tracker, String threadName) {
		new Thread([
			new TheWarOfWordsTracker() => [
				tracker.set(it)
				start()
			]
		], threadName).start()
	}
	
	def static createNode(AtomicReference<TheWarOfWordsNode> node) {
		node.createNode(4567, "Node")
	}
	
	def static createNode(AtomicReference<TheWarOfWordsNode> node, int port) {
		node.createNode(port, "Node")
	}
	
	def static createNode(AtomicReference<TheWarOfWordsNode> node, String name) {
		node.createNode(4567, name)
	}
	
	def static createNode(AtomicReference<TheWarOfWordsNode> node, int port, String threadName) {
		new Thread([
			new TheWarOfWordsNode(#[new InetSocketAddress("localhost", 2012)], port, Keys.generateAssymetricPair()) => [
				node.set(it)
				start()
			]
		], threadName).start()
	}
	
	def static createMiner(AtomicReference<TheWarOfWordsMiner> miner) {
		miner.createMiner(4569, "Miner")
	}
	
	def static createMiner(AtomicReference<TheWarOfWordsMiner> miner, int port) {
		miner.createMiner(port, "Miner")
	}
	
	def static createMiner(AtomicReference<TheWarOfWordsMiner> miner, String name) {
		miner.createMiner(4569, name)
	}
	
	def static createMiner(AtomicReference<TheWarOfWordsMiner> miner, int port, String threadName) {
		new Thread([
			new TheWarOfWordsMiner(#[new InetSocketAddress("localhost", 2012)], port, Keys.generateAssymetricPair()) => [
				miner.set(it)
				start()
			]
		], threadName).start()
	}

	def static closeSafe(TheWarOfWordsTracker tracker) {
		try {
			tracker.close()
		} catch(Exception e) {
		}
	}

	def static closeSafe(TheWarOfWordsNode node) {
		try {
			node.close()
		} catch(Exception e) {
		}
	}

	def static closeSafe(TheWarOfWordsMiner miner) {
		try {
			miner.close()
		} catch(Exception e) {
		}
	}
	
}