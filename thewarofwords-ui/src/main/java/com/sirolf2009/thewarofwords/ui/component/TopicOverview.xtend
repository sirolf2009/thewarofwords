package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import java.util.Map
import javafx.scene.layout.FlowPane
import javafx.scene.control.Label

class TopicOverview extends FlowPane {
	
	new(Map<String, Topic> topics) {
		topics.forEach[hash, topic|
			getChildren().add(new Label(topic.getName()))
		]
	}
	
}