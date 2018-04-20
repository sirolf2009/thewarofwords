package com.sirolf2009.thewarofwords.common.model

import java.util.Set
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block

@Data class Topic implements IVerifiable {
	
	val String name
	val String description
	val Set<String> tags
	
	def verify() {
		return !name.isEmpty() && !description.isEmpty()
	}
	
	override verifyStatic() throws VerificationException {
		if(name.isEmpty()) {
			throw new VerificationException("name may not be empty")
		}
		if(description.isEmpty()) {
			throw new VerificationException("description may not be empty")
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}
	
}