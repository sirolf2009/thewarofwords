package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.ui.MainController
import java.util.stream.Collectors
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.geometry.Rectangle2D
import javafx.scene.Node
import javafx.scene.control.ScrollPane
import javafx.scene.image.ImageView
import javafx.scene.layout.AnchorPane
import java.time.Duration

class Home extends ScrollPane {
	
	val MainController controller
	@FXML ImageView bannerImg
	@FXML AnchorPane recentTopics
	@FXML AnchorPane creditTopics
	@FXML AnchorPane sourceTopics

	new(MainController controller) {
		this.controller = controller
		val fxmlLoader = new FXMLLoader(Home.getResource("/fxml/home.fxml"))
		fxmlLoader.setRoot(this)
		fxmlLoader.setController(this)
		fxmlLoader.load()
	}
	
	@FXML
	def void initialize() {
		widthProperty().addListener[
			bannerImg.fitWidth = getWidth()
			val vp = bannerImg.viewport
			bannerImg.viewport = new Rectangle2D(vp.minX, vp.minY, bannerImg.image.width, (bannerImg.image.height/width)*145+145)
		]
		val recentOverview = new TopicsOverview(controller, controller.getFacade().getTopics().stream().limit(10).collect(Collectors.toList()))
		recentTopics.getChildren.add(recentOverview)
		recentOverview.maximize()
		val creditOverview = new TopicsOverview(controller, controller.getFacade().getTopics().sortBy[controller.getFacade().getSources(getHash()).map[controller.getFacade().getCredit(it)].stream().reduce[a,b|a+b].orElse(0d)].reverse().stream().limit(10).collect(Collectors.toList()))
		creditTopics.getChildren.add(creditOverview)
		creditOverview.maximize()
		val sourceOverview = new TopicsOverview(controller, controller.getFacade().getTopics().sortBy[controller.getFacade().getSources(getHash()).size()].reverse().stream().limit(10).collect(Collectors.toList()))
		sourceTopics.getChildren.add(sourceOverview)
		sourceOverview.maximize()
		val a = controller.getSettings().getSubscriptions().map[controller.getFacade().getSourcesForTopicSince(getTopicHash(), System.currentTimeMillis()-Duration.ofDays(7).toMillis())].map[
			map[controller.getFacade().getBlock(controller.getFacade().getBlockNumberForSource(getHash()))] //TODO SavedBlock 
		]
	}
	
	def void maximize(Node node) {
		AnchorPane.setTopAnchor(node, 0d)
		AnchorPane.setRightAnchor(node, 0d)
		AnchorPane.setBottomAnchor(node, 0d)
		AnchorPane.setLeftAnchor(node, 0d)
	}

}
