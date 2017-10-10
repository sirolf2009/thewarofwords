package com.sirolf2009.thewarofwords.common.serializer

import com.esotericsoftware.kryo.Serializer
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output

class SerializerSourceType extends Serializer<SourceType> {
	
	override read(Kryo kryo, Input input, Class<SourceType> type) {
		return SourceType.values.get(input.readShort)
	}
	
	override write(Kryo kryo, Output output, SourceType object) {
		output.writeShort(SourceType.values.indexOf(object) as short)
	}
	
}