package com.sirolf2009.thewarofwords.website.components

import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI
import com.vaadin.ui.Button
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.Label
import com.vaadin.ui.VerticalLayout

class Banner extends VerticalLayout {
	
	new() {
		val title = new Label("The War of Words")
		title.addStyleName("banner-title")
		
		val navigation = new HorizontalLayout()
		navigation.addStyleName("banner-navigation")
		navigation.addComponents(createNavButton("Home", ""), createNavButton("New Topic", "newtopic"))
		
		addComponents(title, navigation)
		addStyleName("banner")
	}
	
	def static createNavButton(String name, String navigation) {
		val button = new Button(name)
		button.addClickListener[
			TheWarOfWordsUI.navigator.navigateTo(navigation)
		]
		return button
	}
	
}