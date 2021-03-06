package com.sirolf2009.thewarofwords.ui

import javafx.application.Application
import javafx.fxml.FXMLLoader
import javafx.scene.Parent
import javafx.scene.Scene
import javafx.stage.Stage
import org.apache.logging.log4j.LogManager
import javafx.scene.text.Font

class TheWarOfWords extends Application {

	static val log = LogManager.logger
	
	var MainController controller

	override start(Stage stage) throws Exception {
		Font.loadFont(TheWarOfWords.getResource("/fonts/Aurella.ttf").toExternalForm(), 10)		
		
		val fxmlFile = "/fxml/main.fxml"
		log.debug("Loading FXML for main view from: {}", fxmlFile)
		val loader = new FXMLLoader()
		val rootNode = loader.load(getClass().getResourceAsStream(fxmlFile)) as Parent
		controller = loader.getController() as MainController

		log.debug("Showing JFX scene")
		val scene = new Scene(rootNode)
		scene.getStylesheets().add("/styles/styles.css")

		stage.setTitle("The War of Words")
		stage.setScene(scene)
		stage.show()
	}
	
	override stop() throws Exception {
		controller.getNode().getUpnpServices().forEach [
			shutdown()
		]
	}
	
	def static void main(String[] args) throws Exception {
		launch(args)
	}
	
}