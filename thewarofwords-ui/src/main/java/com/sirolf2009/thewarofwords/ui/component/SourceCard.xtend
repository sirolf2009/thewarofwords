package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.concurrent.Task
import javafx.geometry.Pos
import javafx.scene.Node
import javafx.scene.control.Label
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.layout.HBox
import javafx.scene.layout.Pane
import javafx.scene.layout.Priority
import javafx.scene.web.WebView

class SourceCard extends Card {

	static val emptyImage = new Image("images/heart-empty-16.png")
	static val filledImage = new Image("images/heart-filled-16.png")

	val MainController controller
	val SavedTopic topic
	val SavedSource source

	new(MainController controller, SavedTopic topic, SavedSource source) {
		this.controller = controller
		this.topic = topic
		this.source = source
		setHeader(new HBox() => [ container |
			container.alignment = Pos.TOP_RIGHT
			container.getChildren().add(new Pane() => [
				hasUpvoted.map[it || isOwner()].subscribe [ filled |
					val image = new ImageView(if(filled) filledImage else emptyImage) => [
						fitWidth = 16
						fitHeight = 16
						HBox.setHgrow(it, Priority.ALWAYS)
					]
					getChildren().add(image)
					if(!filled) {
						onMouseClicked = [ e |
							controller.getFacade().upvote(source.getHash(), topic.getHash())
							image.setImage(filledImage)
							onMouseClicked = []
						]
					}
				]
			])
			container.getChildren().add(new Label() => [
				controller.runTask(new Task<String>() {
					override protected call() throws Exception {
						return String.valueOf(controller.getFacade().getCredit(source))
					}
				} => [ task |
					task.onSucceeded = [ evt |
						text = task.getValue()
					]
				])
			])
		])
		switch (source.getSource().getSourceType()) {
			case CITATION: setContent(new CitationPane(source.getSource()))
			case TWEET: setContent(new TweetPane(source.getSource()))
			case VIDEO: setContent(new VideoPane(source.getSource()))
			default: setContent(new ArticlePane(source.getSource()))
		}
	}

	def hasUpvoted() {
		controller.getFacade().hasUpvoted(source.getHash(), topic.getHash())
	}

	def isOwner() {
		source.getOwner().equals(controller.getNode().getKeys().getPublic())
	}

	override setContent(Node node) {
		super.setContent(node)
		node.onMouseClicked = [
			val browser = new WebView()
			val webEngine = browser.getEngine()
			webEngine.load(source.getSource().getSource().toExternalForm())
			controller.setNewsContent(browser)
		]
	}

}
