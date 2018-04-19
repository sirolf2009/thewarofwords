package com.sirolf2009.thewarofwords.ui.component

import org.tbee.javafx.scene.layout.MigPane
import javafx.scene.control.Label
import javafx.scene.control.TextField

class NewTopic extends MigPane {
	
	new() {
		add(new Label("Topic name"))
		add(new TextField(), "wrap")
		add(new Label("Topic tags"))
		add(new TextField())
	}
	
}