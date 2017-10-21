package com.sirolf2009.thewarofwords.website.components

import com.vaadin.server.ExternalResource
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.Image
import com.vaadin.ui.Label
import com.vaadin.ui.Link
import com.vaadin.ui.VerticalLayout
import java.net.URL
import java.security.PublicKey

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import static extension com.sirolf2009.thewarofwords.website.util.Favicon.*

class SourceCard extends HorizontalLayout {

	new(String hash, PublicKey publicKey, String comment, URL url) {
		val img = new Image()
		try {
			img.source = new ExternalResource(url.favicon)
		} catch(Exception e) {
		}
		img.addStyleName("card-preview-image")
		val imgContainer = new VerticalLayout()
		imgContainer.addStyleNames("card-preview", "source-card-preview")
		imgContainer.addComponents(img)
		imgContainer.margin = false

		val title = new Label(comment)
		title.addStyleNames("card-title", "source-card-title")

		val stats = new Link(url.toExternalForm(), new ExternalResource(url)) => [
			addStyleNames("card-stats", "source-card-stats")
			spacing = false
			margin = false
		]

		val signature = new Label(publicKey.encoded.toHexString().substring(0, 32)) => [
			addStyleName("signature")
		]

		val textContainer = new VerticalLayout()
		textContainer.addComponents(title, stats, signature)
		textContainer.addStyleNames("card-text", "source-card-text")

		val card = new HorizontalLayout()
		card.addComponents(imgContainer, textContainer)
		card.addStyleNames("card", "source-card")

		addComponent(card)
		addStyleNames("card-outer", "source-card-outer")

		margin = false
		spacing = false
	}

}
