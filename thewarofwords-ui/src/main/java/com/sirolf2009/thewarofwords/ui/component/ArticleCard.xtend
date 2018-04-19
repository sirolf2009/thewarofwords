package com.sirolf2009.thewarofwords.ui.component

import org.tbee.javafx.scene.layout.MigPane
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.ui.thumbnail.Thumbnails
import javafx.scene.image.ImageView
import javafx.scene.control.Label
import javafx.scene.control.Button
import com.sirolf2009.thewarofwords.common.model.SourceType

class ArticleCard extends MigPane {
	
	new(Source source) {
		if(source.getSourceType() != SourceType.ARTICLE) {
			throw new IllegalArgumentException('''«source» is not an article''')
		}
		
		styleClass += "card"
		maxWidth = 400
		
		add(new Label(source.getComment()), "wrap")
		val thumbnailOpt = Thumbnails.getThumbnail(source.getSource().toString())
		if(thumbnailOpt.isPresent()) {
			add(new ImageView(thumbnailOpt.get().getUrl()) => [
				styleClass += "image"
				preserveRatio = true
				maxWidthProperty().bind(ArticleCard.this.widthProperty())
				fitWidthProperty().bind(maxWidthProperty)
				fitHeightProperty().bind(maxWidthProperty.multiply(0.5d))
			], "wrap")
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