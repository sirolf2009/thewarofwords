package com.sirolf2009.thewarofwords.ui.thumbnail

import org.junit.Test
import com.sirolf2009.thewarofwords.ui.tweet.TweetFetcher
import com.sirolf2009.thewarofwords.ui.tweet.Tweet
import org.junit.Assert

class TestTweetFetcher {
	
	@Test
	def void test() {
		val url = "https://twitter.com/wikileaks/status/756217834947088384"
		val expected = new Tweet("https://pbs.twimg.com/profile_images/512138307870785536/Fe00yVS2_bigger.png", "WikiLeaks", "@wikileaks", "It is time @Twitter got out of the censorship/justice game. Let users create communal filter lists if need be.")
		Assert.assertEquals(expected, TweetFetcher.fetchTweet(url))
	}
	
}