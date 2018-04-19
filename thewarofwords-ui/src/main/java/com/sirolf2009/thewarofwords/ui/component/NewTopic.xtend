package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import javafx.beans.property.SimpleStringProperty
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField
import javafx.scene.layout.Pane
import org.tbee.javafx.scene.layout.MigPane
import java.util.function.Consumer

class NewTopic extends MigPane {

	val name = new SimpleStringProperty()
	val desc = new SimpleStringProperty()
	val tags = new SimpleStringProperty()

	new(Consumer<Topic> onSubmitted) {
		super("", "[][right]")
		styleClass += "newsContentItem"
		add(new Label("Name"), "shrink 0")
		add(new TextField() => [
			name.bind(textProperty())
		], "growx, wrap")
		add(new Label("Tags"), "shrink 0")
		add(new TextField() => [
			tags.bind(textProperty())
		], "growx, wrap")
		add(new Label("Description"), "shrink 0")
		add(new TextArea() => [
			desc.bind(textProperty())
		], "growx, wrap")
		add(new Pane())
		add(new Button("Submit") => [
			onAction = [onSubmitted.accept(getTopic())]
		])
	}

	def getTopic() {
		return new Topic(name.get(), desc.get(), tags.get().split(",").map[trim()].toSet())
	}

}
