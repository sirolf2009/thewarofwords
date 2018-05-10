package com.sirolf2009.thewarofwords.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.thewarofwords.common.model.Topic
import java.net.URL

class SerializerTopic extends Serializer<Topic> {
	
	override read(Kryo kryo, Input input, Class<Topic> type) {
		val name = input.readString()
		val description = input.readString()
		val tags = (0 ..< input.readShort).map[input.readString()].toSet()
		val image = new URL(input.readString())
		return new Topic(name, description, tags, image)
	}
	
	override write(Kryo kryo, Output output, Topic object) {
		output.writeString(object.name)
		output.writeString(object.description)
		output.writeShort(object.tags.length as short)
		object.tags.forEach[output.writeString(it)]
		output.writeString(object.getImage().toExternalForm())
	}
	
}