package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.miner.TheWarOfWordsMiner
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import com.sirolf2009.thewarofwords.node.TheWarOfWordsTracker
import java.net.URL
import java.util.concurrent.atomic.AtomicReference
import org.junit.After
import org.junit.Before
import org.junit.Test

import static java.lang.Thread.sleep
import static junit.framework.Assert.*

import static extension com.sirolf2009.thewarofwords.tests.Util.*

class TestTopicSource {

	val AtomicReference<TheWarOfWordsTracker> tracker = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node1 = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node2 = new AtomicReference()
	val AtomicReference<TheWarOfWordsMiner> miner = new AtomicReference()

	@Before
	def void setup() {
		tracker.createTracker()
		sleep(3000)
		node1.createNode()
		sleep(2000)
		node2.createNode(4568)
		sleep(2000)
		miner.createMiner()
		sleep(2000)
	}

	@Test
	def void testTopicSource() {
		node1.submitMutation(new Topic("Test Topic", "description", #["test", "topic"].toSet()))
		node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "All you're base are belong to us"))
		
		node2.awaitNewBlock()

		node2.getLastState() => [
			assertEquals(topics.toString(), 1, topics.size())
			assertEquals(topics.toString(), "Test Topic", topics.values.get(0).name)
			assertEquals(topics.toString(), "description", topics.values.get(0).description)
			val tags = topics.values.get(0).tags
			assertEquals(tags.toString(), 2, tags.size())
			assertTrue(tags.toString(), tags.contains("test"))
			assertTrue(tags.toString(), tags.contains("topic"))

			assertEquals(sources.toString(), 1, sources.size())
			assertEquals(sources.toString(), SourceType.ARTICLE, sources.get(0).getSource().sourceType)
			assertEquals(sources.toString(), "https://github.com/sirolf2009/thewarofwords", sources.get(0).getSource().getSource().toString())
			assertEquals(sources.toString(), "All you're base are belong to us", sources.get(0).getSource().getComment())
		]
	}
	
	@After
	def void cleanup() {
		tracker.get()?.closeSafe()
		node1.get()?.closeSafe()
		node2.get()?.closeSafe()
		miner.get()?.closeSafe()
		Thread.sleep(4000) // allow for connections to close
	}

}
