package com.sirolf2009.thewarofwords.common.exception

import com.sirolf2009.objectchain.common.exception.VerificationException
import com.sirolf2009.thewarofwords.common.model.Source
import org.eclipse.xtend.lib.annotations.Data

@Data class SourceVerificationException extends VerificationException {
	
	val Source source
	
	new(String message, Source source) {
		super(message)
		this.source = source
	}
	
	new(String message, Throwable cause, Source source) {
		super(message, cause)
		this.source = source
	}
	
}