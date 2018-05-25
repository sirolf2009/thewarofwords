package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.miner.TheWarOfWordsMiner
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import com.sirolf2009.thewarofwords.node.TheWarOfWordsTracker
import java.net.URL
import java.util.concurrent.atomic.AtomicReference
import org.junit.Test

import static java.lang.Thread.sleep
import static junit.framework.Assert.*

import static extension com.sirolf2009.thewarofwords.tests.Util.*

class TestTopicSource {

	val AtomicReference<TheWarOfWordsTracker> tracker = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node1 = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node2 = new AtomicReference()
	val AtomicReference<TheWarOfWordsMiner> miner = new AtomicReference()

	@Test
	def void testTopicSource() {
		try {
			tracker.createTracker()
			sleep(3000)
			node1.createNode()
			sleep(2000)
			node2.createNode(4568)
			sleep(2000)
			miner.createMiner()
			sleep(2000)

			node1.submitMutation(new Topic("Test Topic", "description", #["test", "topic"].toSet(), new URL("http://www.thewarofwords.com")))
			node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "All you're base are belong to us"))

			node2.awaitNewBlock()

			node2.getLastState() => [
				assertEquals(topics.toString(), 1, getTopics().count().blockingGet())
				val topic = getTopics().firstOrError().blockingGet()
				assertEquals(topics.toString(), "Test Topic", topic.getTopic().getName())
				assertEquals(topics.toString(), "description", topic.getTopic().getDescription())
				val tags = topic.getTopic().getTags()
				assertEquals(tags.toString(), 2, tags.size())
				assertTrue(tags.toString(), tags.contains("test"))
				assertTrue(tags.toString(), tags.contains("topic"))

				assertEquals(sources.toString(), 1, getSources().count().blockingGet())
				val source = getSources().firstOrError().blockingGet()
				assertEquals(sources.toString(), SourceType.ARTICLE, source.getSource().sourceType)
				assertEquals(sources.toString(), "https://github.com/sirolf2009/thewarofwords", source.getSource().getSource().toString())
				assertEquals(sources.toString(), "All you're base are belong to us", source.getSource().getComment())
			]
		} finally {
			tracker.get()?.closeSafe()
			node1.get()?.closeSafe()
			node2.get()?.closeSafe()
			miner.get()?.closeSafe()
			Thread.sleep(4000) // allow for connections to close
		}
	}

}
