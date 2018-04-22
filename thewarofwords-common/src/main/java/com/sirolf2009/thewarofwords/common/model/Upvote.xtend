package com.sirolf2009.thewarofwords.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.sirolf2009.objectchain.common.interfaces.IHashable
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Hash
import java.security.PublicKey
import org.eclipse.xtend.lib.annotations.Data

@Data class Upvote implements IVerifiable, IHashable {
	
	val PublicKey voter
	val Hash sourceHash
	val Hash topicHash
	
	override verifyStatic() throws VerificationException {
		if(voter === null) {
			throw new VerificationException("voter is null")
		}
		if(sourceHash.getBytes().isEmpty()) {
			throw new VerificationException("sourceHash is empty")
		}
		if(topicHash.getBytes().isEmpty()) {
			throw new VerificationException("topicHash is empty")
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}
	
}