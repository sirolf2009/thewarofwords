package com.sirolf2009.thewarofwords.website.util

import com.sirolf2009.thewarofwords.common.model.Source
import java.net.URL
import org.jsoup.Jsoup

class Favicon {

	def static getFavicon(Source source) {
		source.source.favicon
	}

	def static getFavicon(URL url) {
		val ref =  {
			val doc = Jsoup.parse(url, 10000)
			val icons = doc.getElementsByTag("link").filter[hasAttr("rel") && attr("rel").equals("icon")].toList
			if(!icons.isEmpty) {
				icons.get(0).attr("href")
			}
			val shortcutIcons = doc.getElementsByTag("link").filter[hasAttr("rel") && attr("rel").equals("shortcut icon")].toList
			if(!shortcutIcons.isEmpty) {
				shortcutIcons.get(0).attr("href")
			}
		}
		return new URL(url, ref)
	}
	
}