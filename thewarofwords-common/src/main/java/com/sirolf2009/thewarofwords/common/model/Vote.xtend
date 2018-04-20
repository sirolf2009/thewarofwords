package com.sirolf2009.thewarofwords.common.model

import java.security.PublicKey
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block

@Data class Vote implements IVerifiable {
	
	val List<Byte> poll
	val PublicKey voter
	
	override verifyStatic() throws VerificationException {
		if(poll.isEmpty()) {
			throw new VerificationException("poll is empty")
		}
		if(voter === null) {
			throw new VerificationException("voter is empty")
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}
	
}