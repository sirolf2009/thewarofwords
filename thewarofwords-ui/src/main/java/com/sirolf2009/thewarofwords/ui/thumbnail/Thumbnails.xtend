package com.sirolf2009.thewarofwords.ui.thumbnail

import java.util.stream.Stream
import org.jsoup.Jsoup
import org.jsoup.nodes.Document

class Thumbnails {
	
	static val openGraph = new ThumbnailProviderOpenGraph()
	static val twitter = new ThumbnailProviderTwitter()
	static val shareaholic = new ThumbnailProviderShareaholic()
	static val parsely = new ThumbnailProviderParsely()
	
	def static getThumbnail(String url) {
		return getThumbnail(Jsoup.connect(url).get())
	}
	
	def static getThumbnail(Document doc) {
		return Stream.of(openGraph.getThumbnail(doc), twitter.getThumbnail(doc), shareaholic.getThumbnail(doc), parsely.getThumbnail(doc)).filter[isPresent()].map[get].findFirst()
	}
	
}