package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.MainController
import java.util.ArrayList
import java.util.LinkedList
import javafx.beans.property.SimpleIntegerProperty
import javafx.collections.FXCollections
import javafx.geometry.Insets
import javafx.geometry.Pos
import javafx.scene.Node
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.layout.FlowPane
import javafx.scene.layout.HBox
import javafx.scene.layout.VBox
import org.tbee.javafx.scene.layout.MigPane

class TopicOverview extends MigPane {

	val sources = FXCollections.<Node>observableArrayList()
	val columnCount = new SimpleIntegerProperty()
	val HBox sourcesContainer = new HBox(8) => [
		alignment = Pos.CENTER
	]

	new(MainController controller, SavedTopic topic) {
		super("fillx")
		styleClass += #["newsContentItem", "topicOverview"]
		add(new Label(topic.getTopic().getName()) => [
			styleClass += "title"
			alignment = Pos.CENTER
		], "span, wrap, growx")
		add(new Label(topic.getTopic().getDescription()) => [
			styleClass += "description"
		], "span 2, growx")
		add(new Button("Add source") => [
			onAction = [controller.newSource(topic)]
		], "wrap, right")
		add(sourcesContainer, "span, grow")

		controller.getFacade().getSources(topic.getHash()).sortBy[controller.getFacade().getCredit(it)].reverse().forEach [ source |
			if(source.getSource().getSourceType() == SourceType.CITATION) {
				sources.add(new CitationCard(controller, topic, source) => [
					FlowPane.setMargin(it, new Insets(4))
				])
			} else if(source.getSource().getSourceType() == SourceType.TWEET) {
				sources.add(new TweetCard(controller, topic, source) => [
					FlowPane.setMargin(it, new Insets(4))
				])
			} else if(source.getSource().getSourceType() == SourceType.VIDEO) {
				sources.add(new VideoCard(controller, topic, source) => [
					FlowPane.setMargin(it, new Insets(4))
				])
			} else {
				sources.add(new ArticleCard(controller, topic, source) => [
					FlowPane.setMargin(it, new Insets(4))
				])
			}
		]

		val prefWidth = 400
		widthProperty().addListener [
			val columnCount = Math.max(1, Math.floor(getWidth() / prefWidth)) as int
			if(columnCount != this.columnCount.get()) {
				this.columnCount.set(columnCount)
			}
		]
		columnCount.addListener [
			layoutSources
		]
	}

	def layoutSources() {
		sourcesContainer.getChildren().clear()
		val columns = new ArrayList()
		(0 ..< columnCount.get()).forEach [
			val column = new VBox()
			sourcesContainer.getChildren().add(column)
			columns.add(column)
		]
		val queue = new LinkedList(columns)
		sources.forEach [
			if(queue.isEmpty()) {
				queue.addAll(columns)
			}
			val column = queue.pop()
			column.getChildren().add(it)
		]
	}

}
