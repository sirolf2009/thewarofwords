package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.ui.MainController
import java.net.MalformedURLException
import java.net.URL
import java.util.function.Consumer
import javafx.application.Platform
import javafx.beans.property.SimpleStringProperty
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox

class NewTopic extends MutationForm<Topic> {

	val name = new SimpleStringProperty()
	val desc = new SimpleStringProperty()
	val tags = new SimpleStringProperty()
	val url = new SimpleStringProperty()

	new(MainController controller, Consumer<Topic> onSubmitted) {
		super(controller)
		styleClass += "newsContentItem"

		add(new Label("Name"), "growx, wrap, spanx 2")
		add(new TextField() => [
			name.bind(textProperty())
			textProperty().addListener[notifyChanged()]
		], "growx, wrap, spanx 2")
		add(new Label("Tags"), "growx, wrap, spanx 2")
		add(new TextField() => [
			tags.bind(textProperty())
			textProperty().addListener[notifyChanged()]
		], "growx, wrap, spanx 2")
		add(new Label("Description"), "growx, wrap, spanx 2")
		add(new TextArea() => [
			desc.bind(textProperty())
			textProperty().addListener[notifyChanged()]
		], "growx, wrap, spanx 2")
		add(new Label("Image"), "growx, wrap, spanx 2")
		add(new TextField() => [
			url.bind(textProperty())
			textProperty().addListener[notifyChanged()]
			textProperty().addListener [ obs, oldVal, newVal |
				try {
					new URL(newVal)
					styleClass -= "error"
				} catch(MalformedURLException e) {
					if(!styleClass.contains("error")) {
						styleClass += "error"
					}
				}
			]
		], "growx, wrap, spanx 2")
		addFooter(onSubmitted)
		add(new VBox() => [
			getChildren().add(new Label("Preview:"))
			getChildren().add(new StackPane() => [
				onValueChange [
					try {
						val topic = getTopic()
						Platform.runLater [
							getChildren().clear()
							getChildren().add(new TopicCard(topic))
						]
					} catch(Exception e) {
					}
				]
			])
		], "growx, wrap, spanx 2")
	}

	override getMutation() {
		return getTopic()
	}

	def getTopic() {
		return new Topic(name.get(), desc.get(), tags.get().split(",").map[trim()].toSet(), new URL(url.getValue()))
	}

}
