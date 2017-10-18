package com.sirolf2009.thewarofwords.website.components

import com.sirolf2009.thewarofwords.common.model.Source
import com.vaadin.ui.Label
import com.vaadin.ui.VerticalLayout
import java.util.List
import com.vaadin.ui.CustomComponent

class Timeline extends VerticalLayout {
	
	new(List<Source> sources) {
		val line = new CustomComponent()
		line.addStyleName("timeline-line")
		
		val sourcesContainer = new VerticalLayout()
		sourcesContainer.addStyleName("timeline-container")
		sources.forEach[source|
			sourcesContainer.addComponent(new Label(source.source.toString) => [
				addStyleName("timeline-source")
			])
		]
		
		addComponents(line, sourcesContainer)
		addStyleName("timeline")
		spacing = false
		margin = false
	}
	
}