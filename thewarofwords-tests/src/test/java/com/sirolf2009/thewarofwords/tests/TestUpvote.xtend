package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.Upvote
import com.sirolf2009.thewarofwords.miner.TheWarOfWordsMiner
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import com.sirolf2009.thewarofwords.node.TheWarOfWordsTracker
import java.net.URL
import java.util.concurrent.atomic.AtomicReference
import org.junit.Before
import org.junit.Test

import static java.lang.Thread.sleep
import static junit.framework.Assert.*

import static extension com.sirolf2009.thewarofwords.tests.Util.*

class TestUpvote {
	
	val AtomicReference<TheWarOfWordsTracker> tracker = new AtomicReference()
	val AtomicReference<TheWarOfWordsMiner> miner = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node1 = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node2 = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node3 = new AtomicReference()
	
	@Before
	def void setup() {
	}
	
	@Test
	def void testGetUpvote() {
		tracker.createTracker()
		sleep(3000)
		miner.createMiner()
		sleep(3000)
		node1.createNode()
		sleep(3000)
		node2.createNode(3456)
		sleep(3000)
		node3.createNode(2345)
		
		val topic = node1.submitMutation(new Topic("Test Topic", #["test", "topic"]))
		val source = node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "All you're base are belong to us"))
		sleep(5000)
		
		val topicHash = node2.get().hash(topic)
		val sourceHash = node2.get().hash(source)
		node2.submitMutation(new Upvote(node2.get().keys.public, sourceHash, topicHash))
		node3.submitMutation(new Upvote(node3.get().keys.public, sourceHash, topicHash))
		sleep(5000)
		
		node1.get() => [
			val state = blockchain.mainBranch.lastState as State
			assertEquals(2, state.getUpvotes(node1.get().keys.public).size())
		]
	}
	
}