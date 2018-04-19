package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import javafx.scene.control.Label
import org.tbee.javafx.scene.layout.MigPane
import javafx.scene.effect.DropShadow
import javafx.scene.paint.Color

class TopicCard extends MigPane {

	new(Topic topic) {
		effect = new DropShadow() => [
			setRadius(5.0)
			setOffsetX(3.0)
			setOffsetY(3.0)
			setColor(Color.color(0.4, 0.5, 0.5))
		]
		add(new Label(topic.name), "wrap")
		add(new Label(topic.tags.join(", ")))
	}

}
