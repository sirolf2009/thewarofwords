package com.sirolf2009.thewarofwords.website.views

import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI.TheWarOfWordsUIServlet
import com.sirolf2009.thewarofwords.website.components.Banner
import com.sirolf2009.thewarofwords.website.components.Timeline
import com.sirolf2009.thewarofwords.website.components.TopicCard
import com.vaadin.navigator.View
import com.vaadin.server.ExternalResource
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.VerticalLayout
import com.sirolf2009.thewarofwords.common.model.SourceType
import java.net.URL

class HomeView extends VerticalLayout implements View {
	
	new() {
		spacing = false
		margin = false
		
		val body = new HorizontalLayout()
		
		val state = TheWarOfWordsUIServlet.node.blockchain.mainBranch.lastState as State
		
		val topics = state.topics
		topics.forEach[hash, topic|
			body.addComponent(new TopicCard(hash, topic.name, new ExternalResource("https://avatars3.githubusercontent.com/u/3534736?s=460&v=4")))
		]
		
		body.addComponents(new Timeline(#[
			new Source(SourceType.ARTICLE, new URL("http://www.google.com"), "google"),
			new Source(SourceType.ARTICLE, new URL("http://www.youtube.com"), "youtube"),
			new Source(SourceType.ARTICLE, new URL("http://www.asd.com"), "asd"),
			new Source(SourceType.ARTICLE, new URL("http://www.qwerty.com"), "qwerty"),
			new Source(SourceType.ARTICLE, new URL("http://www.potpol.com"), "potpol"),
			new Source(SourceType.ARTICLE, new URL("http://www.aristotle.com"), "aristotle")
		]))
		
		addComponents(new Banner(), body)
	}
	
}