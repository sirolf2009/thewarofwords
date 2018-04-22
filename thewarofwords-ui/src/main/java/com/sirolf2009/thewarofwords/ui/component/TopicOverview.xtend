package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.layout.FlowPane
import org.tbee.javafx.scene.layout.MigPane
import com.sirolf2009.thewarofwords.common.model.SourceType
import javafx.geometry.Insets
import javafx.geometry.Pos
import com.sirolf2009.objectchain.common.model.Hash

class TopicOverview extends MigPane {

	new(MainController controller, Hash topicHash, Topic topic) {
		super("fillx")
		styleClass += #["newsContentItem", "topicOverview"]
		add(new Label(topic.getName()) => [
			styleClass += "title"
			alignment = Pos.CENTER
		], "span, wrap, growx")
		add(new Label(topic.getDescription()) => [
			styleClass += "description"
		], "span 2, growx")
		add(new Button("Add source") => [
			onAction = [controller.newSource(topicHash, topic)]
		], "wrap, right")
		add(new FlowPane() => [
			controller.getFacade().getSources(topicHash).forEach [ hash, sourceAndKey |
				if(sourceAndKey.getValue().getSourceType() == SourceType.CITATION) {
					getChildren().add(new CitationCard(controller, topicHash, hash, sourceAndKey.getValue()) => [
						FlowPane.setMargin(it, new Insets(4))
					])
				} else {
					getChildren().add(new ArticleCard(sourceAndKey.getValue()) => [
						FlowPane.setMargin(it, new Insets(4))
					])
				}
			]
		], "span, grow")
	}

}
