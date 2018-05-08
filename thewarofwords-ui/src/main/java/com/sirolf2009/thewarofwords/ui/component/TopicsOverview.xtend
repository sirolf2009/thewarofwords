package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.ui.MainController
import java.util.List
import javafx.geometry.Insets
import javafx.scene.layout.FlowPane

class TopicsOverview extends FlowPane {
	
	new(MainController controller, List<SavedTopic> topics) {
		styleClass += "newsContentItem"
		padding = new Insets(4)
		topics.forEach[topic|
			getChildren().add(new TopicCard(controller, topic) => [
				margin = new Insets(4)
			])
		]
	}
	
}