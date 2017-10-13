package com.sirolf2009.thewarofwords.website

import com.sirolf2009.thewarofwords.website.components.TopicCard
import com.sirolf2009.thewarofwords.website.components.TweetCard
import com.vaadin.annotations.Theme
import com.vaadin.annotations.VaadinServletConfiguration
import com.vaadin.server.ExternalResource
import com.vaadin.server.VaadinRequest
import com.vaadin.server.VaadinServlet
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.Label
import com.vaadin.ui.UI
import com.vaadin.ui.VerticalLayout
import javax.servlet.annotation.WebServlet

@Theme("thewarofwordstheme")
class TheWarOfWordsUI extends UI {

	override init(VaadinRequest vaadinRequest) {
		val banner = new HorizontalLayout();
		val title = new Label("The War of Words")
		banner.addComponents(title);
		banner.addStyleName("banner")
		banner.setWidth(100, Unit.PERCENTAGE)
		
		val body = new HorizontalLayout()
		body.addComponent(new TopicCard("The War of Words", new ExternalResource("https://avatars3.githubusercontent.com/u/3534736?s=460&v=4")))
		body.addComponent(new TopicCard("Object Chain", new ExternalResource("https://avatars3.githubusercontent.com/u/3534736?s=460&v=4")))
		body.addComponent(new TweetCard("Object Chain", new ExternalResource("https://avatars3.githubusercontent.com/u/3534736?s=460&v=4")))
		body.addComponent(new TweetCard("Object Chain", new ExternalResource("https://avatars3.githubusercontent.com/u/3534736?s=460&v=4")))

		setContent(new VerticalLayout(banner, body));
	}

	@WebServlet(urlPatterns="/*", name="TheWarOfWordsUIServlet", asyncSupported=true)
	@VaadinServletConfiguration(ui=TheWarOfWordsUI, productionMode=false)
	public static class TheWarOfWordsUIServlet extends VaadinServlet {
	}

}
