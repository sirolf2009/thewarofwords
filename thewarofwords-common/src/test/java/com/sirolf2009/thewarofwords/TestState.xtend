package com.sirolf2009.thewarofwords

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.thewarofwords.common.Schema
import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import datomic.Peer
import java.math.BigInteger
import java.net.URL
import java.util.Date
import java.util.TreeSet
import java.util.UUID
import org.junit.Test

import static com.sirolf2009.thewarofwords.common.TheWarOfWordsKryo.*
import static junit.framework.Assert.*
import com.sirolf2009.thewarofwords.common.model.Upvote

class TestState {

	@Test
	def void testEmptyBlock() {
		val state = emptyState()
		val block = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet())
		val newState = state.apply(kryo(), block) as State
		assertTrue(newState.getTopics().empty)
		assertTrue(newState.getSources().empty)
	}

	@Test
	def void testEmptyBlocks() {
		val state = emptyState()
		val block1 = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet())
		val block2 = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet())
		val block3 = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet())
		val newState1 = state.apply(kryo(), block1) as State
		val newState2 = newState1.apply(kryo(), block2) as State
		val newState3 = newState2.apply(kryo(), block3) as State
		assertTrue(newState3.getTopics().empty)
		assertTrue(newState3.getSources().empty)
		assertEquals(3, newState3.blockNumber)
	}
	
	@Test
	def void testAddTopic() {
		val state = emptyState()
		val topic = new Mutation(new Topic("Topic", "description", #["a", "b", "c"].toSet()), kryo(), Keys.generateAssymetricPair())
		val block = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet(#[topic]))
		val newState = state.apply(kryo(), block) as State
		assertFalse(newState.getTopics().empty)
		val newStateTopic = newState.getTopics().get(topic.hash(kryo()))
		assertEquals("Topic", newStateTopic.name)
		assertEquals("description", newStateTopic.description)
		assertEquals(#["a", "b", "c"].toSet(), newState.getTopics().get(topic.hash(kryo())).tags)
		assertTrue(newState.getSources().empty)
	}
	
	@Test
	def void testAddSource() {
		val state = emptyState()
		val keys = Keys.generateAssymetricPair()
		val source = new Mutation(new Source(SourceType.ARTICLE, new URL("https://www.github.com/sirolf2009/thewarofwords"), "comment"), kryo(), keys)
		val block = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet(#[source]))
		val newState = state.apply(kryo(), block) as State
		assertTrue(newState.getTopics().empty)
		assertFalse(newState.getSources().empty)
		assertEquals(keys.public, newState.getSource(source.hash(kryo())).get().getOwner())
		assertEquals(SourceType.ARTICLE, newState.getSource(source.hash(kryo())).get().getSource().getSourceType())
		assertEquals("https://www.github.com/sirolf2009/thewarofwords", newState.getSource(source.hash(kryo())).get().getSource().getSource().toExternalForm())
		assertEquals("comment", newState.getSource(source.hash(kryo())).get().getSource().getComment())
	}
	
	@Test
	def void testAddSources() {
		val state = emptyState()
		val keys = Keys.generateAssymetricPair()
		val source1 = new Mutation(new Source(SourceType.ARTICLE, new URL("https://www.github.com/sirolf2009/thewarofwords"), "comment"), kryo(), keys)
		val source2 = new Mutation(new Source(SourceType.ARTICLE, new URL("https://www.github.com/sirolf2009/objectchain"), "comment"), kryo(), keys)
		val block = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet(#[source1, source2]))
		val newState = state.apply(kryo(), block) as State
		assertTrue(newState.getTopics().empty)
		assertFalse(newState.getSources().empty)
		assertEquals(2, newState.getSources().size())
	}
	
	@Test
	def void testRefer() {
		val state = emptyState()
		val keys = Keys.generateAssymetricPair()
		val topic = new Mutation(new Topic("Topic", "description", #["a", "b", "c"].toSet()), kryo(), keys)
		val source = new Mutation(new Source(SourceType.ARTICLE, new URL("https://www.github.com/sirolf2009/thewarofwords"), "comment"), kryo(), keys)
		val block = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet() => [
			addAll(topic, source)
		])
		block.mutations.add(new Mutation(new Reference(topic.hash(kryo()), source.hash(kryo())), kryo(), keys))
		val newState = state.apply(kryo(), block) as State
		assertEquals(source.hash(kryo()), newState.getSources(topic.hash(kryo())).get(0).getHash())
	}
	
	@Test
	def void testUpvote() {
		val state = emptyState()
		val keys = Keys.generateAssymetricPair()
		val topic = new Mutation(new Topic("Topic", "description", #["a", "b", "c"].toSet()), kryo(), keys)
		val source1 = new Mutation(new Source(SourceType.ARTICLE, new URL("https://www.github.com/sirolf2009/thewarofwords"), "comment"), kryo(), keys)
		val source2 = new Mutation(new Source(SourceType.ARTICLE, new URL("https://www.github.com/sirolf2009"), "comment"), kryo(), keys)
		val block = new Block(new BlockHeader(new Hash(#[]), new Hash(#[]), new Date(), BigInteger.ONE, 0), new TreeSet() => [
			addAll(topic, source1, source2)
		])
		block.mutations.add(new Mutation(new Reference(topic.hash(kryo()), source1.hash(kryo())), kryo(), keys))
		block.mutations.add(new Mutation(new Reference(topic.hash(kryo()), source2.hash(kryo())), kryo(), keys))
		block.mutations.add(new Mutation(new Upvote(keys.public, source1.hash(kryo()), topic.hash(kryo())), kryo(), keys))
		val newState = state.apply(kryo(), block) as State
		assertEquals(true, newState.hasUpvoted(keys.public, source1.hash(kryo()), topic.hash(kryo())))
		assertEquals(false, newState.hasUpvoted(keys.public, source2.hash(kryo()), topic.hash(kryo())))
	}

	def emptyState() {
		val uri = "datomic:mem://"+UUID.randomUUID()
		Peer.createDatabase(uri)
		val conn = Peer.connect(uri)
		Schema.addSchema(conn)
		return new State(conn, conn.db, 0)
	}

}
