package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.thumbnail.Thumbnails
import javafx.scene.control.Button
import javafx.scene.control.Label
import javafx.scene.image.ImageView
import javafx.scene.text.TextAlignment
import org.tbee.javafx.scene.layout.MigPane

class ArticlePane extends MigPane {

	new(Source source) {
		if(source.getSourceType() != SourceType.ARTICLE) {
			throw new IllegalArgumentException('''«source» is not an article''')
		}
		add(new Label(source.getComment()) => [
			styleClass += "title"
			setWrapText(true)
			setTextAlignment(TextAlignment.JUSTIFY)
		], "wrap")
		val thumbnailOpt = Thumbnails.getThumbnail(source.getSource().toString())
		if(thumbnailOpt.isPresent()) {
			add(new ImageView(thumbnailOpt.get().getUrl()) => [
				styleClass += "image"
				preserveRatio = true
				fitWidthProperty().set(380)
			], "wrap, center")
			add(new Label(thumbnailOpt.get().getTitle()) => [
				styleClass += "title"
			], "wrap")
			add(new Label(thumbnailOpt.get().getDescription()) => [
				styleClass += "description"
			], "wrap")
		} else {
			add(new Button(source.getComment()))
		}
	}

}
