package com.sirolf2009.thewarofwords.common.model

import java.security.PublicKey
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block

@Data class Upvote implements IVerifiable {
	
	val PublicKey voter
	val List<Byte> sourceHash
	val List<Byte> topicHash
	
	override verifyStatic() throws VerificationException {
		if(voter === null) {
			throw new VerificationException("voter is null")
		}
		if(sourceHash.isEmpty()) {
			throw new VerificationException("sourceHash is empty")
		}
		if(topicHash.isEmpty()) {
			throw new VerificationException("topicHash is empty")
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}
	
}