package com.sirolf2009.thewarofwords.common.model

import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block

@Data class Poll implements IVerifiable {
	
	val PollType pollType
	val double newValue
	
	override verifyStatic() throws VerificationException {
		if(pollType === null) {
			throw new VerificationException("pollType is null")			
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}
	
}