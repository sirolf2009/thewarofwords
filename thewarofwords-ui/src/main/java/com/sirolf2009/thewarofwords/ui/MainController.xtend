package com.sirolf2009.thewarofwords.ui

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.node.TheWarOfWordsFacade
import com.sirolf2009.thewarofwords.ui.component.NewTopic
import java.io.File
import java.net.InetSocketAddress
import java.nio.file.Files
import java.nio.file.attribute.PosixFilePermission
import java.security.KeyPair
import javafx.fxml.FXML
import javafx.scene.Node
import javafx.scene.control.Label
import javafx.scene.layout.AnchorPane
import org.apache.logging.log4j.LogManager
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.ui.component.TopicsOverview

class MainController {

	static val log = LogManager.logger
	var UINode node
	var TheWarOfWordsFacade facade
	@FXML var AnchorPane newsContent //turn into stackpane for android style return?
	@FXML var Label lblIsConnected
	@FXML var Label lblLastBlock
	@FXML var Label lblNodeCount

	@FXML
	def void initialize() {
		node = new UINode(#[new InetSocketAddress("thewarofwords.com", 2012)], 4567, getKeys())
		facade = new TheWarOfWordsFacade(node)
		new Thread[node.start()] => [
			daemon = true
			name = "Node"
			start()
		]
		node.getIsSynchronised().addListener[
			if(node.getIsSynchronised().get()) {
				loadTopics()
			}
		]

		lblIsConnected.textProperty().bind(node.getIsConnected().asString())
		lblLastBlock.textProperty().bind(node.getLastBlock())
		lblNodeCount.textProperty().bind(node.getNodes().asString())
	}
	
	def showTopic(String topicHash, Topic topic) {
		//TODO
	}
	
	def showSource(String sourceHash, Source source) {
		//TODO
	}
	
	def loadTopics() {
		setNewsContent(new TopicsOverview(this, facade.getTopics))
	}

	def newTopic() {
		setNewsContent(new NewTopic() [ topic |
			if(topic.verify()) {
				new Thread[facade.postTopic(topic)].start()
			}
		])
	}

	def setNewsContent(Node node) {
		newsContent.getChildren() => [
			clear()
			add(node.maximize())
		]
	}

	def static getKeys() {
		val keyFolder = new File(".keys")
		val publicKey = new File(keyFolder, "public")
		val privateKey = new File(keyFolder, "private")
		if(!keyFolder.exists() || !publicKey.exists() || !privateKey.exists()) {
			log.info("Generating new keys to {}", keyFolder.getAbsolutePath())
			keyFolder.mkdirs()
			val newKeys = Keys.generateAssymetricPair()
			Keys.writeKeyToFile(newKeys.public, publicKey)
			Keys.writeKeyToFile(newKeys.private, privateKey)
			Files.setPosixFilePermissions(publicKey.toPath(), #[PosixFilePermission.OWNER_READ, PosixFilePermission.OWNER_WRITE].toSet())
			Files.setPosixFilePermissions(privateKey.toPath(), #[PosixFilePermission.OWNER_READ, PosixFilePermission.OWNER_WRITE].toSet())
		}
		return new KeyPair(Keys.readPublicKeyFromFile(publicKey), Keys.readPrivateKeyFromFile(privateKey))
	}

	def static maximize(Node node) {
		AnchorPane.setTopAnchor(node, 0d)
		AnchorPane.setRightAnchor(node, 0d)
		AnchorPane.setBottomAnchor(node, 0d)
		AnchorPane.setLeftAnchor(node, 0d)
		return node
	}

}
