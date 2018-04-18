package com.sirolf2009.thewarofwords.node

import com.sirolf2009.objectchain.common.crypto.Keys
import java.net.InetSocketAddress
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Source
import java.net.URL
import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Upvote
import java.util.List

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
	
	def getSources(String topicHash) {
		return state.getSources(topicHash)
	}
	
	def postTopic(String topic, String description, String... tags) {
		postTopic(new Topic(topic, description, tags))
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
	
	def upvote(Reference reference) {
		upvote(reference.source, reference.topic)
	}

	def upvote(List<Byte> sourceHash, List<Byte> topicHash) {
		node.submitMutation(new Upvote(node.keys.public, sourceHash, topicHash))
	}
	
	def private getState() {
		return node.blockchain.mainBranch.getLastState() as State
	}
	
}