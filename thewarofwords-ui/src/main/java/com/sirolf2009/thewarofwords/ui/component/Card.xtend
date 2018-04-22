package com.sirolf2009.thewarofwords.ui.component

import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.value.ChangeListener
import javafx.beans.value.ObservableValue
import javafx.scene.Node
import javafx.scene.layout.Pane
import javafx.scene.layout.StackPane
import javafx.scene.layout.VBox

class Card extends StackPane {

	val ObjectProperty<Node> header = new SimpleObjectProperty()
	val ObjectProperty<Node> content = new SimpleObjectProperty()

	new() {
		styleClass += "card"

		getChildren().add(new Pane() => [
			styleClass += "border"
		])
		val container = new VBox() => [
			styleClass += "card-body"
		]
		getChildren().add(container)
		
		header.addListener(new ChangeListener<Node>() {
			override changed(ObservableValue<? extends Node> observable, Node oldValue, Node newValue) {
				if(oldValue !== null) {
					oldValue.styleClass -= "card-header"
					container.getChildren().remove(oldValue)
				}
				newValue.styleClass += "card-header"
				container.getChildren().add(0, newValue)
			}
		})
		content.addListener(new ChangeListener<Node>() {
			override changed(ObservableValue<? extends Node> observable, Node oldValue, Node newValue) {
				if(oldValue !== null) {
					oldValue.styleClass -= "card-content"
					container.getChildren().remove(oldValue)
				}
				newValue.styleClass += "card-content"
				container.getChildren().add(newValue)
			}
		})
	}
	
	def setHeader(Node node) {
		header.set(node)
	}
	
	def getHeader() {
		header.get()
	}
	
	def headerProperty() {
		return header
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
