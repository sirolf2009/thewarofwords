package com.sirolf2009.thewarofwords.common.model

import java.util.Set
import org.eclipse.xtend.lib.annotations.Data

@Data class Topic {
	
	val String name
	val String description
	val Set<String> tags
	
	def verify() {
		return !name.isEmpty() && !description.isEmpty()
	}
	
}