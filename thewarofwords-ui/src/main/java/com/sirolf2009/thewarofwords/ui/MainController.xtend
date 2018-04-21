package com.sirolf2009.thewarofwords.ui

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.node.TheWarOfWordsFacade
import com.sirolf2009.thewarofwords.ui.component.NewSource
import com.sirolf2009.thewarofwords.ui.component.NewTopic
import com.sirolf2009.thewarofwords.ui.component.TopicOverview
import com.sirolf2009.thewarofwords.ui.component.TopicsOverview
import java.io.File
import java.net.InetSocketAddress
import java.nio.file.Files
import java.nio.file.attribute.PosixFilePermission
import java.security.KeyPair
import javafx.application.Platform
import javafx.fxml.FXML
import javafx.scene.Node
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.StackPane
import org.apache.logging.log4j.LogManager
import org.eclipse.xtend.lib.annotations.Accessors
import javafx.beans.binding.Bindings
import com.sirolf2009.objectchain.common.crypto.Hashing

class MainController {

	static val log = LogManager.logger
	@Accessors var UINode node
	@Accessors var TheWarOfWordsFacade facade
	@FXML var Button popButton
	@FXML var StackPane newsContent
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
		node.getIsSynchronised().addListener [
			if(node.getIsSynchronised().get()) {
				Platform.runLater [
					loadTopics()
				]
			}
		]
		
		popButton.disableProperty().bind(Bindings.lessThan(Bindings.size(newsContent.getChildren()), 2))

		lblIsConnected.textProperty().bind(node.getIsConnected().asString())
		lblLastBlock.textProperty().bind(node.getLastBlock())
		lblNodeCount.textProperty().bind(node.getNodes().asString())
	}

	def showTopic(String topicHash, Topic topic) {
		setNewsContent(new TopicOverview(this, topicHash, topic))
	}

	def showSource(String sourceHash, Source source) {
		// TODO
	}


	def loadTopics() {
		setNewsContent(new TopicsOverview(this, facade.getTopics))
	}
	
	def newSource(String topicHash, Topic topic) {
		setNewsContent(new NewSource() [ source |
			try {
				source.verifyStatic()
				new Thread[
					val newSource = facade.postSource(source)
					facade.refer(topicHash, Hashing.toHexString(node.hash(newSource)))
				].start()
				pop()
			} catch(Exception e) {
			}
		])
	}
	
	def newTopic() {
		setNewsContent(new NewTopic() [ topic |
			if(topic.verify()) {
				new Thread[facade.postTopic(topic)].start()
			}
		])
	}
	
	@FXML def pop() {
		newsContent.getChildren().remove(newsContent.getChildren().last())
	}

	def setNewsContent(Node node) {
		newsContent.getChildren().add(node)
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
