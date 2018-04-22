package com.sirolf2009.thewarofwords.common.serializer

import com.esotericsoftware.kryo.Serializer
import com.sirolf2009.thewarofwords.common.model.Reference
import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.objectchain.common.model.Hash

class SerializerReference extends Serializer<Reference> {
	
	override read(Kryo kryo, Input input, Class<Reference> type) {
		return new Reference(kryo.readObject(input, Hash), kryo.readObject(input, Hash))
	}
	
	override write(Kryo kryo, Output output, Reference object) {
		kryo.writeObject(output, object.topic)
		kryo.writeObject(output, object.source)
	}
	
}