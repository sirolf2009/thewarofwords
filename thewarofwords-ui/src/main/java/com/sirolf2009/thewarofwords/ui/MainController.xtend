package com.sirolf2009.thewarofwords.ui

import com.sirolf2009.objectchain.common.crypto.Keys
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.node.TheWarOfWordsFacade
import com.sirolf2009.thewarofwords.ui.component.ArticleCard
import java.io.File
import java.net.InetSocketAddress
import java.net.URL
import java.nio.file.Files
import java.nio.file.attribute.PosixFilePermission
import java.security.KeyPair
import javafx.fxml.FXML
import javafx.scene.control.Label
import javafx.scene.layout.AnchorPane
import org.apache.logging.log4j.LogManager

class MainController {
	
	static val log = LogManager.logger
	var UINode node
	var TheWarOfWordsFacade facade
	
	@FXML var AnchorPane newsAnchor
	@FXML var Label lblIsConnected
	@FXML var Label lblLastBlock
	@FXML var Label lblNodeCount
	
	@FXML
	def void initialize() {
		node = new UINode(#[new InetSocketAddress("thewarofwords.com", 2012)], 4567, getKeys())
		facade = new TheWarOfWordsFacade(node)
		new Thread[node.start()].start()
		
		newsAnchor.getChildren().add(new ArticleCard(new Source(SourceType.ARTICLE, new URL("https://www.bloomberg.com/news/articles/2018-04-06/george-soros-prepares-to-trade-cryptocurrencies-as-prices-plunge"), "comment")))
		
		lblIsConnected.textProperty().bind(node.getIsConnected().asString())
		lblLastBlock.textProperty().bind(node.getLastBlock())
		lblNodeCount.textProperty().bind(node.getNodes().asString())
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

}