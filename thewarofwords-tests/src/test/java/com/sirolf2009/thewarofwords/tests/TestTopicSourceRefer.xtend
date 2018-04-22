package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.thewarofwords.common.model.Reference
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

class TestTopicSourceRefer {

	val AtomicReference<TheWarOfWordsTracker> tracker = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node1 = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node2 = new AtomicReference()
	val AtomicReference<TheWarOfWordsMiner> miner = new AtomicReference()

	@Before
	def void setup() {
		tracker.createTracker()
		sleep(3000)
		node1.createNode()
		node2.createNode(4568)
		miner.createMiner()
		sleep(2000)
	}

	@Test
	def void testTopicSource() {
		node1.submitMutation(new Topic("Test Topic", "description", #["test", "topic"].toSet()))
		node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "All you're base are belong to us"))
		
		node2.awaitNewBlock()

		node2.getLastState() => [
			assertEquals(1, topics.size())
			assertEquals("Test Topic", topics.values.get(0).name)
			assertEquals("description", topics.values.get(0).description)
			val tags = topics.values.get(0).tags
			assertEquals(2, tags.size())
			assertTrue(tags.contains("test"))
			assertTrue(tags.contains("topic"))

			assertEquals(1, sources.size())
			assertEquals(SourceType.ARTICLE, sources.values.get(0).value.sourceType)
			assertEquals("https://github.com/sirolf2009/thewarofwords", sources.values.get(0).value.source.toString())
			assertEquals("All you're base are belong to us", sources.values.get(0).value.comment)
		]
	}

	@Test
	def void testTopicSourceRefer() {
		val genericProject = node1.submitMutation(new Topic("Generic Projects", "description", #["generic", "projects"].toSet()))
		val genericSource = node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/objectchain"), "This allows you to do a lot!"))
		node1.submitMutation(new Reference(node1.get().hash(genericProject), node1.get().hash(genericSource)))
		
		val specificProject = node1.submitMutation(new Topic("Practical Projects", "description", #["practical", "projects"].toSet()))
		val specificSource = node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "This allows you to do one thing very easily!"))
		
		node2.awaitNewBlock()
		
		node1.submitMutation(new Reference(node1.get().hash(specificProject), node1.get().hash(specificSource)))
		
		node2.awaitNewBlock()
		
		node2.getLastState() => [
			val sources = getSources(node2.get().hash(specificProject))
			assertEquals("There is only 1 source in "+sources, 1, sources.size())
			assertEquals("https://github.com/sirolf2009/thewarofwords", sources.values.get(0).value.source.toString())
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
