package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.ui.MainController
import java.util.Map
import javafx.scene.layout.FlowPane
import javafx.geometry.Insets

class TopicsOverview extends FlowPane {
	
	new(MainController controller, Map<String, Topic> topics) {
		styleClass += "newsContentItem"
		padding = new Insets(4)
		topics.forEach[hash, topic|
			getChildren().add(new TopicCard(controller, hash, topic) => [
				margin = new Insets(4)
			])
		]
	}
	
}