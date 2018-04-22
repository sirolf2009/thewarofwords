package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.scene.control.Label
import org.tbee.javafx.scene.layout.MigPane
import com.sirolf2009.objectchain.common.model.Hash

class TopicCard extends Card {

	new(MainController controller, Hash topicHash, Topic topic) {
		setContent(new MigPane() => [
			styleClass += "card-content"
			add(new Label(topic.name) => [
				styleClass += "title"
			], "wrap")
			add(new Label(topic.tags.join(", ")) => [
				styleClass += "description"
			])
		])

		onMouseClicked = [
			controller.showTopic(topicHash, topic)
		]
	}

}
