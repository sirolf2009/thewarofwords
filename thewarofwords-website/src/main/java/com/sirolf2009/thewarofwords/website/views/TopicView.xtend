package com.sirolf2009.thewarofwords.website.views

import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI.TheWarOfWordsUIServlet
import com.sirolf2009.thewarofwords.website.components.SourceCard
import com.vaadin.navigator.View
import com.vaadin.navigator.ViewChangeListener.ViewChangeEvent
import com.vaadin.ui.Button
import com.vaadin.ui.ComboBox
import com.vaadin.ui.Label
import com.vaadin.ui.TextField
import com.vaadin.ui.VerticalLayout
import java.net.URL

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*
import com.vaadin.ui.FormLayout
import com.vaadin.ui.TextArea
import com.vaadin.ui.Panel

class TopicView extends VerticalLayout implements View {

	new() {
	}

	override enter(ViewChangeEvent event) {
		if(event.parameters === null || event.parameters.isEmpty) {
			throw new IllegalArgumentException("A topic param is required")
		} else {
			addComponent(new Label("Watching topic " + event.parameters))

			{
				val node = TheWarOfWordsUIServlet.node
				val comment = new TextArea("Comment")
				val source = new TextField("Source")
				val type = new ComboBox("Type", SourceType.values.toList())
				val submit = new Button("Submit")
				submit.addClickListener [
					val submittedSource = node.kryoPool.run[node.submitMutation(new Source(type.selectedItem.get(), new URL(source.value), comment.value))]
					node.kryoPool.run[node.submitMutation(new Reference(event.parameters.toByteArray(), node.hash(submittedSource)))]
				]
				addComponent(new Panel("Submit source", new FormLayout(comment, source, type, submit)))
			}

			{
				val state = TheWarOfWordsUI.TheWarOfWordsUIServlet.node.blockchain.mainBranch.lastState as State
				val sources = state.getSources(event.parameters)
				sources.forEach [ hash, source |
					addComponent(new SourceCard(hash, source.key, source.value.comment, source.value.source))
				]
			}
		}
	}

}
