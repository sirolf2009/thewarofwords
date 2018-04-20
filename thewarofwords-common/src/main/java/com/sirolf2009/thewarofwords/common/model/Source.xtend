package com.sirolf2009.thewarofwords.common.model

import java.net.URL
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.thewarofwords.common.exception.SourceVerificationException
import com.sirolf2009.objectchain.common.exception.VerificationException
import com.esotericsoftware.kryo.Kryo
import com.sirolf2009.objectchain.common.model.Block

@Data class Source implements IVerifiable {

	val SourceType sourceType
	val URL source
	val String comment
	
	override verifyStatic() throws VerificationException {
		if(source === null) {
			throw new SourceVerificationException("SourceType is null", this)
		}
		if(sourceType == SourceType.TWEET && !source.host.equals("twitter.com")) {
			throw new SourceVerificationException("SourceType is a tweet, but does not come from twitter", this)
		}
	}
	
	override verifyBytes(Kryo kryo) throws VerificationException {
	}
	
	override verifyInBlock(Block block, Kryo kryo) throws VerificationException {
	}

}
