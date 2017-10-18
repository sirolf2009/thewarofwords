package com.sirolf2009.thewarofwords.website.views

import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI.TheWarOfWordsUIServlet
import com.sirolf2009.thewarofwords.website.components.Banner
import com.vaadin.navigator.View
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent
import com.vaadin.ui.Button
import com.vaadin.ui.TextField
import com.vaadin.ui.VerticalLayout

class CreateTopic extends VerticalLayout implements View {
	
	new() {
		spacing = false
		margin = false
		
		val node = TheWarOfWordsUIServlet.node
		val name = new TextField()
		val submit = new Button("Submit")
		submit.addClickListener[
			node.kryoPool.run[node.submitMutation(new Topic(name.value, #[]))]
		]
		
		addComponents(new Banner(), name, submit)
	}
	
	override enter(ViewChangeEvent event) {
		println("create topic")
	}
	
}