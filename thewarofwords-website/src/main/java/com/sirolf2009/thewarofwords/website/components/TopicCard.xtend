package com.sirolf2009.thewarofwords.website.components

import com.vaadin.server.Resource
import com.vaadin.ui.Image
import com.vaadin.ui.Label
import com.vaadin.ui.VerticalLayout
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI

class TopicCard extends VerticalLayout {
	
	new(String hash, String topicName, Resource image) {
		val img = new Image()
		img.source = image
		img.addStyleName("card-preview-image")
		val imgContainer = new VerticalLayout()
		imgContainer.addStyleNames("card-preview", "topic-card-preview")
		imgContainer.addComponents(img)
		imgContainer.margin = false
		
		val title = new Label(topicName)
		title.addStyleNames("card-title", "topic-card-title")
		val stats = new Label("0 sources linked")
		stats.addStyleNames("card-stats", "topic-card-stats")
		
		val textContainer = new VerticalLayout()
		textContainer.addComponents(title, stats)
		textContainer.addStyleNames("card-text", "topic-card-text")
		
		val card = new VerticalLayout()
		card.addComponents(imgContainer, textContainer)
		card.addStyleNames("card", "topic-card")
		
		addComponent(card)
		addStyleNames("card-outer", "topic-card-outer")
		
		margin = false
		spacing = false
		
		addLayoutClickListener[
			TheWarOfWordsUI.navigator.navigateTo("topic/"+hash)
		]
	}
	
}