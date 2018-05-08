package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.scene.control.Label
import org.tbee.javafx.scene.layout.MigPane

class TopicCard extends Card {

	new(MainController controller, SavedTopic topic) {
		setContent(new MigPane() => [
			styleClass += "card-content"
			add(new Label(topic.getTopic().getName()) => [
				styleClass += "title"
			], "wrap")
			add(new Label(topic.getTopic().getTags().join(", ")) => [
				styleClass += "description"
			])
		])

		onMouseClicked = [
			controller.showTopic(topic)
		]
	}

}
