package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.ui.MainController
import com.sirolf2009.thewarofwords.ui.model.Subscription
import java.util.ArrayList
import java.util.LinkedList
import javafx.beans.binding.Bindings
import javafx.beans.property.SimpleIntegerProperty
import javafx.collections.FXCollections
import javafx.geometry.Orientation
import javafx.geometry.Pos
import javafx.scene.Node
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.Separator
import javafx.scene.control.ToggleButton
import javafx.scene.layout.HBox
import javafx.scene.layout.StackPane
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
		add(new StackPane() => [
			style = '''-fx-background-image: url("«topic.getTopic().getImage().toExternalForm()»");-fx-background-repeat: stretch; -fx-background-position: center ;'''
			prefHeight = 300
			children.add(new Label(topic.getTopic().getName()) => [
				styleClass += "title"
				alignment = Pos.CENTER
			])
		], "span, wrap, growx")
		add(new Separator(Orientation.HORIZONTAL), "span, wrap, growx")
		add(new Label(topic.getTopic().getDescription()) => [
			styleClass += "description"
		], "span 2, growx")
		add(new HBox(8) => [
			getChildren().add(new ToggleButton("Subscribe") => [
				textProperty().bind(Bindings.when(selectedProperty()).then("Subscribed").otherwise("Subscribe"))
				selectedProperty().addListener [ evt |
					if(isSelected()) {
						controller.getSettings().getSubscriptions().add(new Subscription(topic.getHash(), controller.getNode().getLastBlock().get()))
					} else {
						controller.getSettings().getSubscriptions().removeAll(controller.getSettings().getSubscriptions().filter[getTopicHash().equals(topic.getHash())])
					}
				]
			])
			getChildren().add(new Button("Add source") => [
				onAction = [controller.newSource(topic)]
			])
		], "wrap, right")
		add(new Separator(Orientation.HORIZONTAL), "span, wrap, growx")
		add(sourcesContainer, "span, grow")

		controller.getFacade().getSources(topic.getHash()).toList().map[sortBy[controller.getFacade().getCredit(it).blockingGet()].reverse()].subscribe[forEach[sources.add(new SourceCard(controller, topic, it))]]

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
