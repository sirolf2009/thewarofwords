package com.sirolf2009.thewarofwords.common.serializer

import com.esotericsoftware.kryo.Serializer
import com.sirolf2009.thewarofwords.common.model.Topic
import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output

class SerializerTopic extends Serializer<Topic> {
	
	override read(Kryo kryo, Input input, Class<Topic> type) {
		val name = input.readString()
		val tags = (0 ..< input.readShort).map[input.readString()].toList()
		return new Topic(name, tags)
	}
	
	override write(Kryo kryo, Output output, Topic object) {
		output.writeString(object.name)
		output.writeShort(object.tags.length as short)
		object.tags.forEach[output.writeString(it)]
	}
	
}