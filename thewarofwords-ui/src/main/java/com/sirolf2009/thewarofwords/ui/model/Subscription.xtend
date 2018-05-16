package com.sirolf2009.thewarofwords.ui.model

import com.sirolf2009.objectchain.common.model.Hash
import org.eclipse.xtend.lib.annotations.Data

@Data class Subscription {
	
	val Hash topicHash
	val Long lastT
	
}