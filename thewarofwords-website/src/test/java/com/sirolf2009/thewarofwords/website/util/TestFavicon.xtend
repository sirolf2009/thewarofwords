package com.sirolf2009.thewarofwords.website.util

import org.junit.Test
import java.net.URL

import static extension junit.framework.Assert.*

class TestFavicon {
	
	@Test
	def void test() {
		assertEquals(new URL("http://www.google.com/images/branding/product/ico/googleg_lodp.ico"), Favicon.getFavicon(new URL("http://www.google.com")))
		assertEquals(new URL("https://cdn.sstatic.net/Sites/stackoverflow/img/favicon.ico?v=4f32ecc8f43d"), Favicon.getFavicon(new URL("https://stackoverflow.com/questions/15447102/setting-favicon-in-html")))
		assertEquals(new URL("http://search.maven.org/favicon.ico"), Favicon.getFavicon(new URL("http://search.maven.org/#search%7Cga%7C1%7Csirolf2009")))
	}
	
}