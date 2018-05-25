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
import org.junit.Test

import static java.lang.Thread.sleep
import static junit.framework.Assert.*

import static extension com.sirolf2009.thewarofwords.tests.Util.*

class TestTopicSourceRefer {

	val AtomicReference<TheWarOfWordsTracker> tracker = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node1 = new AtomicReference()
	val AtomicReference<TheWarOfWordsNode> node2 = new AtomicReference()
	val AtomicReference<TheWarOfWordsMiner> miner = new AtomicReference()

	@Test
	def void testTopicSourceRefer() {
		try {
			tracker.createTracker()
			sleep(3000)
			node1.createNode()
			sleep(2000)
			node2.createNode(4568)
			sleep(2000)
			miner.createMiner()
			sleep(2000)

			val genericProject = node1.submitMutation(new Topic("Generic Projects", "description", #["generic", "projects"].toSet(), new URL("http://www.thewarofwords.com")))
			val genericSource = node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/objectchain"), "This allows you to do a lot!"))
			node1.submitMutation(new Reference(node1.get().hash(genericProject), node1.get().hash(genericSource)))

			val specificProject = node1.submitMutation(new Topic("Practical Projects", "description", #["practical", "projects"].toSet(), new URL("http://www.thewarofwords.com")))
			val specificSource = node1.submitMutation(new Source(SourceType.ARTICLE, new URL("https://github.com/sirolf2009/thewarofwords"), "This allows you to do one thing very easily!"))

			node2.awaitNewBlock()

			node1.submitMutation(new Reference(node1.get().hash(specificProject), node1.get().hash(specificSource)))

			node2.awaitNewBlock()

			node2.getLastState() => [
				val sources = getSources(node2.get().hash(specificProject))
				assertEquals("There is only 1 source in " + sources, 1, sources.count().blockingGet())
				assertEquals("https://github.com/sirolf2009/thewarofwords", sources.firstOrError().blockingGet().getSource().getSource().toString())
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
