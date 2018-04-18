package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.thewarofwords.common.State
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

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import static extension com.sirolf2009.thewarofwords.tests.Util.*

class TestTopicSourceRefer {

	val AtomicReference<TheWarOfWordsTracker> tracker = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node = new AtomicReference()
	val AtomicReference<TheWarOfWordsMiner> miner = new AtomicReference()

	@Before
	def void setup() {
		tracker.createTracker()
		sleep(3000)
		node.createNode()
		miner.createMiner()
		sleep(2000)
	}

	@Test
	def void testTopicSource() {
		node.submitMutation(new Topic("Test Topic", "description", #["test", "topic"]))
		node.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "All you're base are belong to us"))
		sleep(2000)

		node.get() => [
			val state = blockchain.mainBranch.lastState as State
			val topics = state.topics
			assertEquals(1, topics.size())
			assertEquals("Test Topic", topics.values.get(0).name)
			assertEquals("description", topics.values.get(0).description)
			val tags = topics.values.get(0).tags
			assertEquals(2, tags.size())
			assertTrue(tags.contains("test"))
			assertTrue(tags.contains("topic"))

			val sources = state.sources
			assertEquals(1, sources.size())
			assertEquals(SourceType.ARTICLE, sources.values.get(0).value.sourceType)
			assertEquals("https://github.com/sirolf2009/thewarofwords", sources.values.get(0).value.source.toString())
			assertEquals("All you're base are belong to us", sources.values.get(0).value.comment)
		]
	}

	@Test
	def void testTopicSourceRefer() {
		val genericProject = node.submitMutation(new Topic("Generic Projects", "description", #["generic", "projects"]))
		val genericSource = node.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/objectchain"), "This allows you to do a lot!"))
		node.submitMutation(new Reference(node.get().hash(genericProject), node.get().hash(genericSource)))
		
		val specificProject = node.submitMutation(new Topic("Practical Projects", "description", #["practical", "projects"]))
		val specificSource = node.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "This allows you to do one thing very easily!"))
		node.submitMutation(new Reference(node.get().hash(specificProject), node.get().hash(specificSource)))
		
		sleep(2000)

		node.get() => [
			val state = blockchain.mainBranch.lastState as State
			val sources = state.getSources(node.get().hash(genericProject).toHexString())
			assertEquals(1, sources.size())
			assertEquals("https://github.com/sirolf2009/objectchain", sources.values.get(0).value.source.toString())
		]
		node.get() => [
			val state = blockchain.mainBranch.lastState as State
			val sources = state.getSources(node.get().hash(specificProject).toHexString())
			assertEquals(1, sources.size())
			assertEquals("https://github.com/sirolf2009/thewarofwords", sources.values.get(0).value.source.toString())
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
