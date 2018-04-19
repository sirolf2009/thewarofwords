package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import java.net.URL
import java.util.function.Consumer
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.collections.FXCollections
import javafx.scene.control.Button
import javafx.scene.control.ComboBox
import javafx.scene.control.Label
import javafx.scene.control.TextField
import org.tbee.javafx.scene.layout.MigPane
import javafx.scene.control.TextArea

class NewSource extends MigPane {

	val url = new SimpleStringProperty()
	val type = new SimpleObjectProperty<SourceType>()
	val comment = new SimpleStringProperty()

	new(Consumer<Source> onSubmitted) {
		super("fillx")
		add(new Label("URL"))
		add(new TextField() => [
			url.bind(textProperty())
		], "growx, wrap")
		add(new Label("Comment"))
		add(new TextArea() => [
			comment.bind(textProperty())
		], "growx, wrap")
		add(new Label("Type"))
		add(new ComboBox(FXCollections.observableArrayList(SourceType.values)) => [
			type.bind(valueProperty())
		], "growx, wrap")
		add(new Button("Submit") => [
			onAction = [onSubmitted.accept(this.getSource())]
		], "span, right")
	}

	def getSource() {
		return new Source(type.get(), new URL(url.get()), comment.get())
	}

}
