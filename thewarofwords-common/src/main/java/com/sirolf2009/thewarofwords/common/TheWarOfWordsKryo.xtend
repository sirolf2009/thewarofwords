package com.sirolf2009.thewarofwords.common

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.Upvote
import com.sirolf2009.thewarofwords.common.serializer.SerializerReference
import com.sirolf2009.thewarofwords.common.serializer.SerializerSource
import com.sirolf2009.thewarofwords.common.serializer.SerializerSourceType
import com.sirolf2009.thewarofwords.common.serializer.SerializerTopic
import com.sirolf2009.thewarofwords.common.serializer.SerializerUpvote

class TheWarOfWordsKryo {
	
	def static kryo() {
		val kryo = new Kryo()
		kryo.register(SourceType, new SerializerSourceType())
		kryo.register(Source, new SerializerSource())
		kryo.register(Topic, new SerializerTopic())
		kryo.register(Reference, new SerializerReference())
		kryo.register(Upvote, new SerializerUpvote())
		return kryo
	}
	
}