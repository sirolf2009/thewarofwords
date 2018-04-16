package com.sirolf2009.thewarofwords.ui.thumbnail

import org.jsoup.nodes.Document
import org.jsoup.select.Elements

class ThumbnailProviderOpenGraph implements IThumbnailProvider {
	
	override getThumbnail(Document doc) {
		val metaTags = doc.getElementsByTag("meta")
		return getUrl(metaTags).map[
			new Thumbnail(it, getTitle(metaTags).orElse(""), getDescription(metaTags).orElse(""))
		]
	}
	
	def getUrl(Elements metaTags) {
		return findElementWithAttr(metaTags, "property", "og:image").map[attr("content")]
	}
	def getTitle(Elements metaTags) {
		return findElementWithAttr(metaTags, "property", "og:title").map[attr("content")]
	}
	def getDescription(Elements metaTags) {
		return findElementWithAttr(metaTags, "property", "og:description").map[attr("content")]
	}
	
}