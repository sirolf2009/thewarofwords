package com.sirolf2009.thewarofwords.common.model

import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class Topic {
	
	val String name
	val List<String> tags
	
}