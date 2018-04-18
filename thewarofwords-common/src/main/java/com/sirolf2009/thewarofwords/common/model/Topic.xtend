package com.sirolf2009.thewarofwords.common.model

import java.util.List
import org.eclipse.xtend.lib.annotations.Data

@Data class Topic {
	
	val String name
	val String description
	val List<String> tags
	
}