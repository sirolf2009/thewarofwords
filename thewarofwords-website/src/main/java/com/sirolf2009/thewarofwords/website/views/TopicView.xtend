package com.sirolf2009.thewarofwords.website.views

import com.vaadin.navigator.View
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent
import com.vaadin.ui.Label
import com.vaadin.ui.VerticalLayout

class TopicView extends VerticalLayout implements View {
	
	new() {
	}
	
	override enter(ViewChangeEvent event) {
		if(event.parameters === null || event.parameters.isEmpty) {
			throw new IllegalArgumentException("A topic param is required")
		} else {
			addComponent(new Label("Watching topic "+event.parameters))
		}
	}
	
}