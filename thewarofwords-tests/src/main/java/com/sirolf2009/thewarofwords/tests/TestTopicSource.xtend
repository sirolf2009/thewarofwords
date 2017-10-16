package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.miner.TheWarOfWordsMiner
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import com.sirolf2009.thewarofwords.node.TheWarOfWordsTracker
import java.net.InetSocketAddress
import java.net.URL
import java.util.concurrent.atomic.AtomicReference
import junit.framework.Assert
import org.junit.After
import org.junit.Test

import static extension com.sirolf2009.thewarofwords.tests.Util.*

class TestTopicSource {
	
	val AtomicReference<TheWarOfWordsTracker> tracker = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node = new AtomicReference()
	val AtomicReference<TheWarOfWordsMiner> miner = new AtomicReference()

	@Test
	def void test() {
		new Thread([
			new TheWarOfWordsTracker() => [
				tracker.set(it)
				start()
			]
		], "Tracker").start()
		Thread.sleep(2000)
		new Thread([
			new TheWarOfWordsNode(#[new InetSocketAddress("localhost", 2012)], 4567, Keys.generateAssymetricPair()) => [
				node.set(it)
				start()
			]
		], "Node").start()
		Thread.sleep(2000)
		new Thread([
			new TheWarOfWordsMiner(#[new InetSocketAddress("localhost", 2012)], 4569, Keys.generateAssymetricPair()) => [
				miner.set(it)
				start()
			]
		], "Miner").start()
		Thread.sleep(2000)
		
		node.get() => [
			submitMutation(new Topic("Test Topic", #["test", "topic"]))
		]
		
		Thread.sleep(2000)
		
		node.get() => [
			val state = blockchain.mainBranch.lastState as State
			val topics = state.topics
			Assert.assertEquals(1, topics.size())
			Assert.assertEquals("Test Topic", topics.values.get(0).name)
			Assert.assertEquals(#["topic", "test"].toList(), topics.values.get(0).tags)
		]
		
		node.get() => [
			submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "All you're base are belong to us"))
		]
		
		Thread.sleep(2000)
		
		node.get() => [
			val state = blockchain.mainBranch.lastState as State
			val sources = state.sources
			Assert.assertEquals(1, sources.size())
			Assert.assertEquals(SourceType.ARTICLE, sources.values.get(0).value.sourceType)
			Assert.assertEquals("https://github.com/sirolf2009/thewarofwords", sources.values.get(0).value.source.toString())
			Assert.assertEquals("All you're base are belong to us", sources.values.get(0).value.comment)
		]
	}

	@After
	def void cleanup() {
		tracker.get()?.closeSafe()
		node.get()?.closeSafe()
		miner.get()?.closeSafe()
		Thread.sleep(4000) // allow for connections to close
	}

}