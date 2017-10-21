package com.sirolf2009.thewarofwords.website.views

import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI
import com.sirolf2009.thewarofwords.website.components.SourceCard
import com.sirolf2009.thewarofwords.website.components.SubmitSource
import com.vaadin.navigator.View
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent
import com.vaadin.ui.CssLayout
import com.vaadin.ui.GridLayout
import com.vaadin.ui.HorizontalLayout
import com.vaadin.ui.Label
import com.vaadin.ui.Panel
import com.vaadin.ui.VerticalLayout

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class TopicView extends VerticalLayout implements View {

	new() {
	}

	override enter(ViewChangeEvent event) {
		if(event.parameters === null || event.parameters.isEmpty) {
			throw new IllegalArgumentException("A topic param is required")
		} else {
			val state = TheWarOfWordsUI.TheWarOfWordsUIServlet.node.blockchain.mainBranch.lastState as State
			val sources = state.getSources(event.parameters)

			addComponent(new HorizontalLayout() => [
				setSizeFull()
				addComponent(new Panel("Submit source", new SubmitSource(event.parameters)))
				addComponent(new Panel("Stats", new GridLayout(2, 2) => [
					addComponent(new Label("Total sources linked"), 0, 0)
					addComponent(new Label(sources.size().toString()), 1, 0)
					addComponent(new Label("Unique posters"), 0, 1)
					addComponent(new Label(sources.values.stream.map[key.encoded.toHexString()].distinct().count().toString()), 1, 1)
				]))
			])

			addComponent(new CssLayout() => [
				spacing = true
				sources.forEach [ hash, source |
					addComponent(new SourceCard(hash, source.key, source.value.comment, source.value.source))
				]
			])
		}
	}

}
