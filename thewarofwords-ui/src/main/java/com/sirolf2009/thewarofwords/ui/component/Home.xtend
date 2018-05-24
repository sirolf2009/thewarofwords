package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.ui.MainController
import com.sirolf2009.thewarofwords.ui.model.Subscription
import java.time.Duration
import java.util.Date
import java.util.List
import java.util.stream.Collectors
import javafx.fxml.FXML
import javafx.fxml.FXMLLoader
import javafx.geometry.Rectangle2D
import javafx.scene.Node
import javafx.scene.control.ScrollPane
import javafx.scene.image.ImageView
import javafx.scene.layout.AnchorPane
import org.eclipse.xtend.lib.annotations.Data
import javafx.scene.control.ProgressIndicator

class Home extends ScrollPane {

	val MainController controller
	@FXML ImageView bannerImg
	@FXML AnchorPane recentTopics
	@FXML AnchorPane creditTopics
	@FXML AnchorPane sourceTopics
	@FXML AnchorPane subscribedTopics
	@FXML AnchorPane upvotedSources

	new(MainController controller) {
		this.controller = controller
		val fxmlLoader = new FXMLLoader(Home.getResource("/fxml/home.fxml"))
		fxmlLoader.setRoot(this)
		fxmlLoader.setController(this)
		fxmlLoader.load()
	}

	@FXML
	def void initialize() {
		widthProperty().addListener [
			bannerImg.fitWidth = getWidth()
			val vp = bannerImg.viewport
			bannerImg.viewport = new Rectangle2D(vp.minX, vp.minY, bannerImg.image.width, (bannerImg.image.height / width) * 145 + 145)
		]
		#[recentTopics, creditTopics, sourceTopics, subscribedTopics, upvotedSources].forEach[set(new ProgressIndicator())]
		loadTopicsInto(recentTopics) [
			controller.getFacade().getTopics().stream().limit(10).collect(Collectors.toList())
		]
		loadTopicsInto(creditTopics) [
			controller.getFacade().getTopics().sortBy[controller.getFacade().getSources(getHash()).map[controller.getFacade().getCredit(it)].stream().reduce[a, b|a + b].orElse(0d)].reverse().stream().limit(10).collect(Collectors.toList())
		]
		loadTopicsInto(sourceTopics) [
			controller.getFacade().getTopics().sortBy[controller.getFacade().getSources(getHash()).size()].reverse().stream().limit(10).collect(Collectors.toList())
		]
		loadTopicsInto(subscribedTopics) [
			controller.getSettings().getSubscriptions().stream().map[it -> controller.getFacade().getSourcesForTopicSince(getTopicHash(), System.currentTimeMillis() - Duration.ofDays(7).toMillis())].filter[value.size() > 0].flatMap [
				value.stream().map [ source |
					new SubscribedSource(key, controller.getFacade().getTopic(key.getTopicHash()).get(), source, controller.getFacade().getBlock(controller.getFacade().getBlockNumberForSource(source.getHash())).getTimestamp())
				]
			].sorted[a, b|a.getTimestamp().compareTo(b.getTimestamp())].map[topic].distinct().limit(10).collect(Collectors.toList())
		]
	}

	def loadTopicsInto(AnchorPane pane, ()=>List<SavedTopic> supplier) {
		loadInto(pane) [
			new TopicsOverview(controller, supplier.apply())
		]
	}

	def loadInto(AnchorPane pane, ()=>Node supplier) {
		controller.runTask [
			supplier.apply()
		].addListener [ obs, oldVal, newVal |
			pane.set(newVal)
		]
	}

	def void set(AnchorPane pane, Node child) {
		pane.getChildren().clear()
		pane.getChildren().add(child)
		child.maximize()
	}

	def void maximize(Node node) {
		AnchorPane.setTopAnchor(node, 0d)
		AnchorPane.setRightAnchor(node, 0d)
		AnchorPane.setBottomAnchor(node, 0d)
		AnchorPane.setLeftAnchor(node, 0d)
	}

	@Data static class SubscribedSource {
		val Subscription subscription
		val SavedTopic topic
		val SavedSource source
		val Date timestamp
	}

}
