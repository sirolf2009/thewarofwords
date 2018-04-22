package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.geometry.Pos
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.HBox
import javafx.scene.layout.Pane
import javafx.scene.layout.Priority
import javafx.scene.Node
import javafx.scene.web.WebView

class SourceCard extends Card {

	static val emptyImage = new Image("images/heart-empty-16.png")
	static val filledImage = new Image("images/heart-filled-16.png")
	
	val MainController controller
	val Source source

	new(MainController controller, Hash topicHash, Hash sourceHash, Source source) {
		this.controller = controller
		this.source = source
		setHeader(new HBox() => [ container |
			container.alignment = Pos.TOP_RIGHT
			container.getChildren().add(new Pane() => [
				val hasUpvoted = controller.getFacade().hasUpvoted(sourceHash, topicHash)
				val image = new ImageView(if(hasUpvoted) filledImage else emptyImage) => [
					fitWidth = 16
					fitHeight = 16
					HBox.setHgrow(it, Priority.ALWAYS)
				]
				getChildren().add(image)
				if(!hasUpvoted) {
					onMouseClicked = [ e |
						controller.getFacade().upvote(sourceHash, topicHash)
						image.setImage(filledImage)
						onMouseClicked = []
					]
				}
			])
		])
	}
	
	override setContent(Node node) {
		super.setContent(node)
		node.onMouseClicked = [
			val browser = new WebView()
			val webEngine = browser.getEngine()
			webEngine.load(source.getSource().toExternalForm())
			controller.setNewsContent(browser)
		]
	}

}
