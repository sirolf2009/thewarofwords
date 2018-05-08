package com.sirolf2009.thewarofwords.common.model

import com.sirolf2009.objectchain.common.model.Hash
import org.eclipse.xtend.lib.annotations.Data

@Data class SavedTopic {
	
	val Hash hash
	val Topic topic
	
}