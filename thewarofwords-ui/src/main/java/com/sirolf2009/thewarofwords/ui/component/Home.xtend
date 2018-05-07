package com.sirolf2009.thewarofwords.ui.component

import javafx.scene.layout.VBox
import javafx.fxml.FXMLLoader
import javafx.fxml.FXML
import javafx.scene.image.ImageView
import javafx.geometry.Rectangle2D
import javafx.scene.layout.AnchorPane
import com.sirolf2009.thewarofwords.ui.MainController

class Home extends VBox {
	
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
		val recentOverview = new TopicsOverview(controller, controller.getFacade().getTopics())
		recentTopics.getChildren.add(recentOverview)
		AnchorPane.setTopAnchor(recentOverview, 0d)
		AnchorPane.setRightAnchor(recentOverview, 0d)
		AnchorPane.setBottomAnchor(recentOverview, 0d)
		AnchorPane.setLeftAnchor(recentOverview, 0d)
	}

}
