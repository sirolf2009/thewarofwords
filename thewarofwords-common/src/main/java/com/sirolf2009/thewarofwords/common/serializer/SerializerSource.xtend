package com.sirolf2009.thewarofwords.common.serializer

import com.esotericsoftware.kryo.Serializer
import com.sirolf2009.thewarofwords.common.model.Source
import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.thewarofwords.common.model.SourceType

class SerializerSource extends Serializer<Source> {
	
	override read(Kryo kryo, Input input, Class<Source> type) {
		return new Source(kryo.readObject(input, SourceType), input.readString, input.readString)
	}
	
	override write(Kryo kryo, Output output, Source object) {
		kryo.writeObject(output, object.sourceType)
		output.writeString(object.source)
		output.writeString(object.comment)
	}
	
}