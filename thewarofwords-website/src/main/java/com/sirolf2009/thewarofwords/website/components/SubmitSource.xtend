package com.sirolf2009.thewarofwords.website.components

import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.website.TheWarOfWordsUI.TheWarOfWordsUIServlet
import com.vaadin.ui.Button
import com.vaadin.ui.ComboBox
import com.vaadin.ui.FormLayout
import com.vaadin.ui.TextArea
import com.vaadin.ui.TextField
import java.net.URL

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class SubmitSource extends FormLayout {

	new(String topicHash) {
		setSizeFull()
		val node = TheWarOfWordsUIServlet.node
		val comment = new TextArea("Comment")
		comment.setSizeFull()
		val source = new TextField("Source")
		source.setSizeFull()
		val type = new ComboBox("Type", SourceType.values.toList())
		type.setSizeFull()
		val submit = new Button("Submit")
		submit.addClickListener [
			val submittedSource = node.kryoPool.run[node.submitMutation(new Source(type.selectedItem.get(), new URL(source.value), comment.value))]
			node.kryoPool.run[node.submitMutation(new Reference(topicHash.toByteArray(), node.hash(submittedSource)))]
		]
		addComponents(comment, source, type, submit)
	}

}
