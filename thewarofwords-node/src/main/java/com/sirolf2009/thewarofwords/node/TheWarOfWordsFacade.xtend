package com.sirolf2009.thewarofwords.node

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.Upvote
import java.net.InetSocketAddress
import java.net.URL
import com.sirolf2009.thewarofwords.common.model.SavedSource

class TheWarOfWordsFacade {
	
	private final TheWarOfWordsNode node
	
	new() {
		this(new TheWarOfWordsNode(#[new InetSocketAddress("localhost", 2012)], 4567, Keys.generateAssymetricPair()))
	}
	
	new(TheWarOfWordsNode node) {
		this.node = node
	}
	
	def getTopics() {
		return state.getTopics()
	}
	
	def getSources() {
		return state.getSources()
	}
	
	def getSources(Hash topicHash) {
		return state.getSources(topicHash)
	}
	
	def hasUpvoted(Hash sourceHash, Hash topicHash) {
		return state.hasUpvoted(node.keys.public, sourceHash, topicHash)
	}
	
	def postTopic(String topic, String description, URL image, String... tags) {
		postTopic(new Topic(topic, description, tags.toSet(), image))
	}
	
	def postTopic(Topic topic) {
		node.submitMutation(topic)
	}
	
	def postSource(SourceType type, String url, String comment) {
		postSource(new Source(type, new URL(url), comment))
	}
	
	def postSource(Source source) {
		node.submitMutation(source)
	}
	
	def refer(Hash topicHash, Hash sourceHash) {
		node.submitMutation(new Reference(topicHash, sourceHash))
	}
	
	def upvote(Reference reference) {
		upvote(reference.source, reference.topic)
	}

	def upvote(Hash sourceHash, Hash topicHash) {
		node.submitMutation(new Upvote(node.keys.public, sourceHash, topicHash))
	}
	
	def getUpvoteCount(Hash sourceHash) {
		return state.getUpvotes(sourceHash).size()
	}
	
	def getCredit(SavedSource source) {
		return state.getCredit(source)
	}
	
	def private getState() {
		return node.blockchain.mainBranch.getLastState() as State
	}
	
}