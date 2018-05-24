package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.tweet.Tweet
import com.sirolf2009.thewarofwords.ui.tweet.TweetFetcher
import javafx.scene.control.Label
import javafx.scene.image.Image
import javafx.scene.image.ImageView
import javafx.scene.text.TextAlignment
import org.tbee.javafx.scene.layout.MigPane

class TweetPane extends MigPane {

	new(Source source) {
		this(source, TweetFetcher.fetchTweet(source.getSource().toExternalForm()))
	}

	new(Source source, Tweet tweet) {
		if(source.getSourceType() != SourceType.TWEET) {
			throw new IllegalArgumentException('''«source» is not a tweet''')
		}

		styleClass += "tweet-card"
		add(new Label(source.getComment()) => [
			styleClass += "title"
			setWrapText(true)
			setTextAlignment(TextAlignment.LEFT)
		], "span 5, wrap")
		add(new ImageView(new Image(tweet.getAvatar(), true)) => [
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
	}

}
