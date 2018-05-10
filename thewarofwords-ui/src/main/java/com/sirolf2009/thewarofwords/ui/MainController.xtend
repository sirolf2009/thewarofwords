package com.sirolf2009.thewarofwords.ui

import com.dooapp.fxform.FXForm
import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.node.TheWarOfWordsFacade
import com.sirolf2009.thewarofwords.ui.component.Home
import com.sirolf2009.thewarofwords.ui.component.NewSource
import com.sirolf2009.thewarofwords.ui.component.NewTopic
import com.sirolf2009.thewarofwords.ui.component.TopicOverview
import java.io.File
import java.net.InetSocketAddress
import java.nio.file.Files
import java.nio.file.attribute.PosixFilePermission
import java.security.KeyPair
import java.util.concurrent.Executors
import javafx.animation.TranslateTransition
import javafx.application.Platform
import javafx.beans.binding.Bindings
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.concurrent.Task
import javafx.fxml.FXML
import javafx.scene.Node
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.control.Tab
import javafx.scene.layout.AnchorPane
import javafx.scene.layout.StackPane
import javafx.util.Duration
import org.apache.logging.log4j.LogManager
import org.eclipse.xtend.lib.annotations.Accessors

class MainController {

	static val log = LogManager.logger
	val executor = Executors.newWorkStealingPool()
	val settings = new Settings()
	@Accessors var UINode node
	@Accessors var TheWarOfWordsFacade facade
	@FXML var Button popButton
	@FXML var StackPane newsContent
	@FXML var Tab settingsTab
	@FXML var Label lblIsConnected
	@FXML var Label lblLastBlock
	@FXML var Label lblNodeCount
	@FXML var Label lblCredibility

	@FXML
	def void initialize() {
		node = new UINode(settings, #[new InetSocketAddress("thewarofwords.com", 2012)], 4567, getKeys())
		facade = new TheWarOfWordsFacade(node)
		new Thread[node.start()] => [
			daemon = true
			name = "Node"
			start()
		]
		node.getIsSynchronised().addListener [
			if(node.getIsSynchronised().get()) {
				Platform.runLater [
//					loadTopics()
					newsContent = new Home(this)
				]
			}
		]

		settingsTab.setContent(new FXForm(settings))

		popButton.disableProperty().bind(Bindings.lessThan(Bindings.size(newsContent.getChildren()), 2))

		lblIsConnected.textProperty().bind(node.getIsConnected().asString())
		lblLastBlock.textProperty().bind(node.getLastBlock().asString())
		lblNodeCount.textProperty().bind(node.getNodes().asString())
		lblCredibility.textProperty().bind(node.getCredibility().asString())
	}

	def void run(Runnable runnable) {
		executor.execute(runnable)
	}

	def <T> ReadOnlyObjectProperty<T> runTask(Task<T> task) {
		executor.execute(task)
		return task.valueProperty()
	}

	def showTopic(SavedTopic topic) {
		setNewsContent(new TopicOverview(this, topic))
	}

	def showSource(String sourceHash, Source source) {
		// TODO
	}

	def loadTopics() {
		setNewsContent(new Home(this))
	}

	def newSource(SavedTopic topic) {
		setNewsContent(new NewSource(this) [ source |
			try {
				source.verifyStatic()
				new Thread [
					val newSource = facade.postSource(source)
					facade.refer(topic.getHash(), node.hash(newSource))
				].start()
				pop()
			} catch(Exception e) {
			}
		])
	}

	def newTopic() {
		setNewsContent(new NewTopic(this) [ topic |
			if(topic.verify()) {
				new Thread[facade.postTopic(topic)].start()
			}
		])
	}

	@FXML def pop() {
		val popped = newsContent.getChildren().last()
		new TranslateTransition(new Duration(100), popped) => [
			fromX = 0
			toX = newsContent.getWidth()
			onFinished = [newsContent.getChildren().remove(popped)]
			play()
		]
		return popped
	}

	def setNewsContent(Node node) {
		newsContent.getChildren().add(node)
		new TranslateTransition(new Duration(350), node) => [
			fromX = newsContent.getWidth()
			toX = 0
			play()
		]
	}

	def static getKeys() {
		val keyFolder = new File(".keys")
		val publicKey = new File(keyFolder, "public.key")
		val privateKey = new File(keyFolder, "private.key")
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
