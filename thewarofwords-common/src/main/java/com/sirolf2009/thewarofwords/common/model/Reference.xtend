package com.sirolf2009.thewarofwords.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.sirolf2009.objectchain.common.model.Block
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class Reference implements IVerifiable {

	val List<Byte> topic
	val List<Byte> source

	override toString() {
		val b = new ToStringBuilder(this)
		b.add("topic", this.topic.toHexString())
		b.add("source", this.source.toHexString())
		return b.toString()
	}
	
	override verifyStatic() throws VerificationException {
		if(topic.isEmpty()) {
			throw new VerificationException("topic is empty")
		}
		if(source.isEmpty()) {
			throw new VerificationException("source is empty")
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}

}
