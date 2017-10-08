package com.sirolf2009.thewarofwords.common.model

import java.security.PublicKey
import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class Vote {
	
	val List<Byte> poll
	val PublicKey voter
	
}