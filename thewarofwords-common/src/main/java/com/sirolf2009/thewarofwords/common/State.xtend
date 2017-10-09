package com.sirolf2009.thewarofwords.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.interfaces.IState
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.Topic
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Data

@Data class State implements IState {

	val Map<List<Byte>, Topic> topics
	val Map<List<Byte>, Source> sources
	val Map<List<Byte>, Reference> references

	override apply(Kryo kryo, Block block) {
		val Map<List<Byte>, Topic> newTopics = new HashMap()
		newTopics.putAll(topics)
		block.mutations.filter[object instanceof Topic].forEach[newTopics.put(hash(kryo), object as Topic)]

		val Map<List<Byte>, Source> newSources = new HashMap()
		newSources.putAll(sources)
		block.mutations.filter[object instanceof Source].forEach[newSources.put(hash(kryo), object as Source)]

		val Map<List<Byte>, Reference> newReferences = new HashMap()
		newReferences.putAll(references)
		block.mutations.filter[object instanceof Reference].forEach[newReferences.put(hash(kryo), object as Reference)]

		return new State(newTopics, newSources, newReferences)
	}

}
