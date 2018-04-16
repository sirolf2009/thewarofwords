package com.sirolf2009.thewarofwords.ui.thumbnail

import java.io.File
import org.jsoup.Jsoup
import org.junit.Test
import org.junit.Assert
import java.util.Optional

class TestThumbnailProvider {
	
	@Test
	def void testThumbnail() {
		val expected = Optional.of(new Thumbnail("https://assets.bwbx.io/images/users/iqjWHBFdfxIU/iojcYJ4Iu5KE/v1/1200x869.jpg", "George Soros Prepares to Trade Cryptocurrencies", "George Soros called cryptocurrencies a bubble in January. Now his $26 billion family office is planning to trade digital assets."))
		val actual = Thumbnails.getThumbnail(Jsoup.parse(new File("src/test/resources/bloomberg.html"), "UTF-8"))
		Assert.assertEquals(expected, actual)
	}
	
}