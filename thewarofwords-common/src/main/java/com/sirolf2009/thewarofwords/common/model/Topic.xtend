package com.sirolf2009.thewarofwords.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.sirolf2009.objectchain.common.interfaces.IHashable
import com.sirolf2009.objectchain.common.model.Block
import java.net.URL
import java.util.Set
import org.eclipse.xtend.lib.annotations.Data

@Data class Topic implements IVerifiable, IHashable {
	
	val String name
	val String description
	val Set<String> tags
	val URL image
	
	def verify() {
		return !name.isEmpty() && !description.isEmpty() && image !== null
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