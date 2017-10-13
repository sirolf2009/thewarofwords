package com.sirolf2009.thewarofwords.website.views

import com.sirolf2009.thewarofwords.website.components.TopicCard
import com.vaadin.navigator.View
import com.vaadin.server.ExternalResource
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.VerticalLayout
import com.sirolf2009.thewarofwords.website.components.Banner
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI.TheWarOfWordsUIServlet
import com.sirolf2009.thewarofwords.common.State

class HomeView extends VerticalLayout implements View {
	
	new() {
		val body = new HorizontalLayout()
		
		val state = TheWarOfWordsUIServlet.node.blockchain.mainBranch.lastState as State
		
		val topics = state.topics
		topics.forEach[hash, topic|
			body.addComponent(new TopicCard(hash, topic.name, new ExternalResource("https://avatars3.githubusercontent.com/u/3534736?s=460&v=4")))
		]
		
		addComponents(new Banner(), body)
	}
	
}