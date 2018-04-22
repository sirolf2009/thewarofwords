package com.sirolf2009.thewarofwords.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.sirolf2009.objectchain.common.interfaces.IHashable
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Hash
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

@Data class Reference implements IVerifiable, IHashable {

	val Hash topic
	val Hash source

	override toString() {
		val b = new ToStringBuilder(this)
		b.add("topic", topic)
		b.add("source", source)
		return b.toString()
	}
	
	override verifyStatic() throws VerificationException {
		if(topic.getBytes().isEmpty()) {
			throw new VerificationException("topic is empty")
		}
		if(source.getBytes().isEmpty()) {
			throw new VerificationException("source is empty")
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}

}
