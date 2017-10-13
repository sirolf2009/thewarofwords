package com.sirolf2009.thewarofwords.website.components

import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.Label

class Banner extends HorizontalLayout {
	
	new() {
		val title = new Label("The War of Words")
		addComponent(title)
		addStyleName("banner")
		setWidth(100, Unit.PERCENTAGE)
	}
	
}