package com.sirolf2009.thewarofwords.website

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import com.sirolf2009.thewarofwords.website.views.HomeView
import com.sirolf2009.thewarofwords.website.views.TopicView
import com.vaadin.annotations.Theme
import com.vaadin.annotations.VaadinServletConfiguration
import com.vaadin.navigator.Navigator
import com.vaadin.server.VaadinRequest
import com.vaadin.server.VaadinServlet
import com.vaadin.ui.UI
import java.net.InetSocketAddress
import javax.servlet.annotation.WebServlet

@Theme("thewarofwordstheme")
class TheWarOfWordsUI extends UI {

	public static var Navigator navigator

	override init(VaadinRequest vaadinRequest) {
		page.title = "The War of Words"

		navigator = new Navigator(this, this)
		navigator.addView("", HomeView)
		navigator.addView("topic", TopicView)
	}
	
	@WebServlet(urlPatterns="/*", name="TheWarOfWordsUIServlet", asyncSupported=true)
	@VaadinServletConfiguration(ui=TheWarOfWordsUI, productionMode=false)
	public static class TheWarOfWordsUIServlet extends VaadinServlet {
		
		public static val node = {
			new TheWarOfWordsNode(#[new InetSocketAddress("localhost", 2012)], 4567, Keys.generateAssymetricPair()) => [
				start()
			]
		}
		
	}

}
