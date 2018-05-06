package com.sirolf2009.thewarofwords.common.model

import com.sirolf2009.objectchain.common.model.Hash
import org.eclipse.xtend.lib.annotations.Data

@Data class SavedUpvote {
	
	val Hash hash
	val Upvote upvote 
	
}