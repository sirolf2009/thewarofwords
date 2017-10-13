package com.sirolf2009.thewarofwords.website.components

import com.vaadin.server.Resource
import com.vaadin.ui.Image
import com.vaadin.ui.Label
import com.vaadin.ui.VerticalLayout

class TweetCard extends VerticalLayout {
	
	new(String topicName, Resource image) {
		val img = new Image()
		img.source = image
		img.addStyleName("card-preview-image")
		val imgContainer = new VerticalLayout()
		imgContainer.addStyleNames("card-preview", "tweet-card-preview")
		imgContainer.addComponents(img)
		imgContainer.margin = false
		
		val title = new Label(topicName)
		title.addStyleNames("card-title", "tweet-card-title")
		val stats = new Label("0 sources linked")
		stats.addStyleNames("card-stats", "tweet-card-stats")
		
		val textContainer = new VerticalLayout()
		textContainer.addComponents(title, stats)
		textContainer.addStyleNames("card-text", "tweet-card-text")
		
		val card = new VerticalLayout()
		card.addComponents(imgContainer, textContainer)
		card.addStyleNames("card", "tweet-card")
		
		addComponent(card)
		addStyleNames("card-outer", "tweet-card-outer")
		
		margin = false
		spacing = false
	}
	
}