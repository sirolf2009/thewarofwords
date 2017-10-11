package com.sirolf2009.thewarofwords.website

import com.vaadin.annotations.Theme
import com.vaadin.annotations.VaadinServletConfiguration
import com.vaadin.server.VaadinRequest
import com.vaadin.server.VaadinServlet
import com.vaadin.ui.Button
import com.vaadin.ui.Label
import com.vaadin.ui.TextField
import com.vaadin.ui.UI
import com.vaadin.ui.VerticalLayout
import javax.servlet.annotation.WebServlet

@Theme("thewarofwordstheme")
class TheWarOfWordsUI extends UI {

	override init(VaadinRequest vaadinRequest) {
		val layout = new VerticalLayout();

		val name = new TextField();
		name.setCaption("Type your name here:");

		val button = new Button("Click Me");
		button.addClickListener [
			layout.addComponent(new Label("Thanks " + name.getValue() + ", it works!"));
		];

		layout.addComponents(name, button);
		layout.addStyleName("banner")

		setContent(layout);
	}

	@WebServlet(urlPatterns="/*", name="TheWarOfWordsUIServlet", asyncSupported=true)
	@VaadinServletConfiguration(ui=TheWarOfWordsUI, productionMode=false)
	public static class TheWarOfWordsUIServlet extends VaadinServlet {
	}

}
