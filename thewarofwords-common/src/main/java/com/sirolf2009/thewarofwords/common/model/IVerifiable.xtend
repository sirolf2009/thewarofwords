package com.sirolf2009.thewarofwords.common.model

import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.sirolf2009.objectchain.common.model.Block

interface IVerifiable {
	
	def void verifyStatic() throws VerificationException
	def void verifyBytes(Kryo kryo) throws VerificationException
	def void verifyInBlock(Block block, Kryo kryo) throws VerificationException
	
}