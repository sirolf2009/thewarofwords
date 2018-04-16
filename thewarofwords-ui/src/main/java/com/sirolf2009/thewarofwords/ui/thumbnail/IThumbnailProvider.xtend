package com.sirolf2009.thewarofwords.ui.thumbnail

import java.util.Optional
import org.jsoup.nodes.Document
import org.jsoup.select.Elements

interface IThumbnailProvider {
	
	def Optional<Thumbnail> getThumbnail(Document doc)
	
	def findElementWithAttr(Elements list, String attribute, String value) {
		list.stream().filter[hasAttr(attribute)].filter[attr(attribute).equals(value)].findAny()
	}
	
}