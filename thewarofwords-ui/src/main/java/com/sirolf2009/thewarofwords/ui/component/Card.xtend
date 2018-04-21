package com.sirolf2009.thewarofwords.ui.component

import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.value.ChangeListener
import javafx.beans.value.ObservableValue
import javafx.scene.Node
import javafx.scene.layout.Pane
import javafx.scene.layout.StackPane

class Card extends StackPane {

	val ObjectProperty<Node> content = new SimpleObjectProperty()

	new() {
		styleClass += "card"

		getChildren().add(new Pane() => [
			styleClass += "border"
		])
		
		content.addListener(new ChangeListener<Node>() {
			override changed(ObservableValue<? extends Node> observable, Node oldValue, Node newValue) {
				if(oldValue !== null) {
					oldValue.styleClass -= "card-content"
					getChildren().remove(oldValue)
				}
				newValue.styleClass += "card-content"
				getChildren().add(newValue)
			}
		})
	}
	
	def setContent(Node node) {
		content.set(node)
	}
	
	def getContent() {
		return content.get()
	}
	
	def contentProperty() {
		return content
	}

}
