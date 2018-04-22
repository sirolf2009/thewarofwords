package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.MainController
import com.sirolf2009.thewarofwords.ui.tweet.TweetFetcher
import javafx.scene.control.Label
import javafx.scene.image.ImageView
import javafx.scene.text.TextAlignment
import org.tbee.javafx.scene.layout.MigPane

class TweetCard extends SourceCard {
	
	new(MainController controller, Hash topicHash, Hash sourceHash, Source source) {
		super(controller, topicHash, sourceHash, source)
		if(source.getSourceType() != SourceType.TWEET) {
			throw new IllegalArgumentException('''«source» is not a tweet''')
		}

		val tweet = TweetFetcher.fetchTweet(source.getSource().toExternalForm())

		setContent(new MigPane() => [
			styleClass += "tweet-card"
			add(new Label(source.getComment()) => [
				styleClass += "title"
				setWrapText(true)
				setTextAlignment(TextAlignment.LEFT)
			], "span 5, wrap")
			add(new ImageView(tweet.getAvatar()) => [
				styleClass += "avatar"
				fitWidth = 48
				fitHeight = 48
			], "span 2 2")
			add(new Label(tweet.getName()) => [
				styleClass += "name"
			], "wrap, span")
			add(new Label(tweet.getHandle()) => [
				styleClass += "handle"
			], "wrap, span")
			add(new Label(tweet.getTweet()) => [
				styleClass += "tweet"
				setWrapText(true)
				setTextAlignment(TextAlignment.LEFT)
			], "span 5")
			maxWidth = 400
		])
	}

}
