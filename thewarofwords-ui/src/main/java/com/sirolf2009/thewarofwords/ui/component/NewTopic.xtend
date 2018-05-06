package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.ui.MainController
import java.util.function.Consumer
import javafx.beans.property.SimpleStringProperty
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

class NewTopic extends MutationForm<Topic> {

	val name = new SimpleStringProperty()
	val desc = new SimpleStringProperty()
	val tags = new SimpleStringProperty()

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
		addFooter(onSubmitted)
	}
	
	override getMutation() {
		return getTopic()
	}
	
	def getTopic() {
		return new Topic(name.get(), desc.get(), tags.get().split(",").map[trim()].toSet())
	}

}
