package com.sirolf2009.thewarofwords.common.model

import com.sirolf2009.objectchain.common.model.Hash
import org.eclipse.xtend.lib.annotations.Data
import java.security.PublicKey

@Data class SavedSource {
	
	val Hash hash
	val PublicKey owner
	val Source source
	
}