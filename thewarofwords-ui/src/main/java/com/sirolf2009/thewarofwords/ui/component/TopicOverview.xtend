package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.layout.FlowPane
import org.tbee.javafx.scene.layout.MigPane

class TopicOverview extends MigPane {

	new(MainController controller, String topicHash, Topic topic) {
		super("fillx")
		add(new Label(topic.getName()), "span, center, wrap")
		add(new Label(topic.getDescription()), "span 2")
		add(new Button("Add source") => [
			onAction = [controller.newSource()]
		], "wrap, right")
		add(new FlowPane() => [
			controller.getFacade().getSources(topicHash).forEach [hash, sourceAndKey|
				getChildren().add(new ArticleCard(sourceAndKey.getValue()))
			]
		], "growy")
	}

}
