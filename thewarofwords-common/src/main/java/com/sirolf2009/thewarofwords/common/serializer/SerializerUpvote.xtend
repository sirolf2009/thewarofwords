package com.sirolf2009.thewarofwords.common.serializer

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryo.Serializer
import com.esotericsoftware.kryo.io.Input
import com.esotericsoftware.kryo.io.Output
import com.sirolf2009.thewarofwords.common.model.Upvote

import static extension com.sirolf2009.objectchain.common.crypto.CryptoHelper.*
import com.sirolf2009.objectchain.common.model.Hash

class SerializerUpvote extends Serializer<Upvote> {
	
	override read(Kryo kryo, Input input, Class<Upvote> type) {
		return new Upvote(kryo.readObject(input, typeof(Byte[])).publicKey, kryo.readObject(input, Hash), kryo.readObject(input, Hash))
	}
	
	override write(Kryo kryo, Output output, Upvote object) {
		kryo.writeObject(output, object.voter.encoded.toArray(newArrayOfSize(object.voter.encoded.size())))
		kryo.writeObject(output, object.sourceHash)
		kryo.writeObject(output, object.topicHash)
	}
}