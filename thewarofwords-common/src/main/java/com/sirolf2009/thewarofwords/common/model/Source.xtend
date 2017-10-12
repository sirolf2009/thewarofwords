package com.sirolf2009.thewarofwords.common.model

import java.net.URL
import org.eclipse.xtend.lib.annotations.Data
import com.sirolf2009.thewarofwords.common.exception.SourceVerificationException

@Data class Source {

	val SourceType sourceType
	val URL source
	val String comment

	def verify() {
		if(sourceType == SourceType.TWEET && !source.host.equals("twitter.com")) {
			throw new SourceVerificationException("SourceType is a tweet, but does not come from twitter", this)
		}
	}

}
