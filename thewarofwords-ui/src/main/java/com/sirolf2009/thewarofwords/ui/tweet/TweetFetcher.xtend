package com.sirolf2009.thewarofwords.ui.tweet

import org.jsoup.Jsoup

class TweetFetcher {

	def static fetchTweet(String url) {
		val doc = Jsoup.connect(url).get()
		val tweet = doc.getElementsByClass("permalink-tweet").get(0)
		val avatar = tweet.getElementsByClass("avatar").get(0).attr("src")
		val name = tweet.getElementsByClass("fullname").get(0).text()
		val handle = tweet.getElementsByClass("username").get(0).text()
		val text = tweet.getElementsByClass("tweet-text").get(0).text()
		return new Tweet(avatar, name, handle, text)
	}	
	
}