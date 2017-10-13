package com.sirolf2009.thewarofwords.common.serializer

import com.esotericsoftware.kryo.Serializer
import com.sirolf2009.thewarofwords.common.model.Reference
import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output

class SerializerReference extends Serializer<Reference> {
	
	override read(Kryo kryo, Input input, Class<Reference> type) {
		return new Reference(kryo.readObject(input, typeof(Byte[])), kryo.readObject(input, typeof(Byte[])))
	}
	
	override write(Kryo kryo, Output output, Reference object) {
		kryo.writeObject(output, object.topic.toArray(newArrayOfSize(object.topic.size)))
		kryo.writeObject(output, object.source.toArray(newArrayOfSize(object.source.size)))
	}
	
}