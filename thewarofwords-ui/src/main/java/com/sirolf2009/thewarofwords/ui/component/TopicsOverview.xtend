package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.ui.MainController
import java.util.List
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.layout.FlowPane

class TopicsOverview extends FlowPane {

	new(MainController controller, List<SavedTopic> topics) {
		alignment = Pos.CENTER
		topics.forEach [ topic |
			getChildren().add(new TopicCard(topic.getTopic()) => [
				margin = new Insets(4)
				onMouseClicked = [
					controller.showTopic(topic)
				]
			])
		]
	}

}
