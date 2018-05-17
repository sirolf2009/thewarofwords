package com.sirolf2009.thewarofwords.common.model

import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.Hash
import java.util.Date
import org.eclipse.xtend.lib.annotations.Data

@Data class SavedBlock {
	
	val Hash hash
	val long blockNumber
	val Date timestamp
	val Block block 
	
}