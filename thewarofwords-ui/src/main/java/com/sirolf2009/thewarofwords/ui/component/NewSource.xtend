package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.MainController
import java.net.MalformedURLException
import java.net.URL
import java.util.List
import java.util.Optional
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
		add(new ComboBox(FXCollections.observableArrayList()) => [
			type.bind(valueProperty())
			valueProperty().addListener[notifyChanged()]
			url.addListener [obs,oldVal,newVal|
				items.clear()
				items.addAll(getSourceType().orElse(#[]))
			]
		], "growx, wrap")
		addFooter(onSubmitted)
	}
	
	def Optional<List<SourceType>> getSourceType() {
		try {
			switch(new URL(url.get()).getHost()) {
				case "nature.com": Optional.of(#[SourceType.CITATION, SourceType.ARTICLE, SourceType.TRUSTED])
				case "sciencemag.org": Optional.of(#[SourceType.CITATION, SourceType.ARTICLE, SourceType.TRUSTED])
				case "humanprogress.org": Optional.of(#[SourceType.CITATION, SourceType.ARTICLE, SourceType.TRUSTED])
				case "youtube.com": Optional.of(#[SourceType.CITATION, SourceType.ARTICLE, SourceType.VIDEO])
				case "twitter.com": Optional.of(#[SourceType.CITATION, SourceType.ARTICLE, SourceType.TWEET])
				default: Optional.of(#[SourceType.CITATION, SourceType.ARTICLE])
			}
		} catch(Exception e) {
			return Optional.empty()
		}
	}
	
	override getMutation() {
		return getSource()
	}
	
	def getSource() {
		return new Source(type.get(), new URL(url.get()), comment.get())
	}

}
