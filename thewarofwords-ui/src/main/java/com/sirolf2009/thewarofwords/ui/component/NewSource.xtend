package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.MainController
import java.net.MalformedURLException
import java.net.URL
import java.util.function.Consumer
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextArea
import javafx.scene.control.TextField

class NewSource extends MutationForm<Source> {

	val url = new SimpleStringProperty()
	val type = new SimpleObjectProperty<SourceType>()
	val comment = new SimpleStringProperty()

	new(MainController controller, Consumer<Source> onSubmitted) {
		super(controller)
		styleClass += "newsContentItem"
		
		add(new Label("URL"))
		add(new TextField() => [
			url.bind(textProperty())
			textProperty().addListener[notifyChanged()]
			textProperty().addListener[obs,oldVal,newVal|
				try {
					new URL(newVal)
					styleClass -= "error"
				} catch(MalformedURLException e) {
					if(!styleClass.contains("error")) {
						styleClass += "error"
					}
				}
			]
		], "growx, wrap")
		add(new Label("Comment"))
		add(new TextArea() => [
			comment.bind(textProperty())
			textProperty().addListener[notifyChanged()]
		], "growx, wrap")
		add(new Label("Type"))
		add(new ComboBox(FXCollections.observableArrayList(SourceType.values)) => [
			type.bind(valueProperty())
			valueProperty().addListener[notifyChanged()]
		], "growx, wrap")
		addFooter(onSubmitted)
	}
	
	override getMutation() {
		return getSource()
	}
	
	def getSource() {
		return new Source(type.get(), new URL(url.get()), comment.get())
	}

}
