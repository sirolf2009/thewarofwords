package com.sirolf2009.thewarofwords.common.model

import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block

@Data class Announcement implements IVerifiable {

	val String announcement
	
	override verifyStatic() throws VerificationException {
		if(announcement.isEmpty()) {
			throw new VerificationException("announcement is null")
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}

}