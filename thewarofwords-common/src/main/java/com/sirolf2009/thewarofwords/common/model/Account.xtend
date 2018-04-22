package com.sirolf2009.thewarofwords.common.model

import java.security.PublicKey
import org.eclipse.xtend.lib.annotations.Data

@Data class Account {
	
	val PublicKey key
	val String username
	val double credibility
	
}