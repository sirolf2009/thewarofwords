package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.MainController
import com.sirolf2009.thewarofwords.ui.tweet.Tweet
import com.sirolf2009.thewarofwords.ui.tweet.TweetFetcher
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.concurrent.Task
import javafx.scene.control.Label
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.text.TextAlignment
import org.eclipse.xtend.lib.annotations.Data
import org.tbee.javafx.scene.layout.MigPane

class TweetCard extends SourceCard {
	
	val ReadOnlyObjectProperty<Tweet> tweetProperty
	
	new(MainController controller, Hash topicHash, SavedSource source) {
		super(controller, topicHash, source)
		if(source.getSource().getSourceType() != SourceType.TWEET) {
			throw new IllegalArgumentException('''«source» is not a tweet''')
		}

		val tweetTask = new TweetTask(source.getSource())
		tweetProperty = controller.runTask(tweetTask)

		setContent(new MigPane() => [
			styleClass += "tweet-card"
			add(new Label(source.getSource().getComment()) => [
				styleClass += "title"
				setWrapText(true)
				setTextAlignment(TextAlignment.LEFT)
			], "span 5, wrap")
			add(new ImageView() => [
				tweetProperty.addListener[obs,oldVal,newVal|
					image = new Image(newVal.getAvatar(), true)
				]
				styleClass += "avatar"
				fitWidth = 48
				fitHeight = 48
			], "span 2 2")
			add(new Label() => [
				styleClass += "name"
				tweetProperty.addListener[obs,oldVal,newVal|
					text = newVal.getName()
				]
			], "wrap, span")
			add(new Label() => [
				styleClass += "handle"
				tweetProperty.addListener[obs,oldVal,newVal|
					text = newVal.getHandle()
				]
			], "wrap, span")
			add(new Label() => [
				styleClass += "tweet"
				setWrapText(true)
				setTextAlignment(TextAlignment.LEFT)
				tweetProperty.addListener[obs,oldVal,newVal|
					text = newVal.getTweet()
				]
			], "span 5")
			maxWidth = 400
		])
	}
	
	@Data static class TweetTask extends Task<Tweet> {
		
		val Source source
		
		override protected call() throws Exception {
			return TweetFetcher.fetchTweet(source.getSource().toExternalForm())
		}
		
	}

}
