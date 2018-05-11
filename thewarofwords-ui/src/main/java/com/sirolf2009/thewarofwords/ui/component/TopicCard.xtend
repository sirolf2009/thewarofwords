package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import javafx.scene.control.Label
import javafx.scene.image.ImageView
import org.tbee.javafx.scene.layout.MigPane

class TopicCard extends Card {

	new(Topic topic) {
		setContent(new MigPane() => [
			styleClass += "card-content"
			add(new ImageView(topic.getImage().toExternalForm()) => [
				preserveRatio = true
				fitWidth = 64
			], "span 2 2")
			add(new Label(topic.getName()) => [
				styleClass += "title"
			], "wrap")
			add(new Label(topic.getTags().join(", ")) => [
				styleClass += "description"
			])
		])
	}

}
