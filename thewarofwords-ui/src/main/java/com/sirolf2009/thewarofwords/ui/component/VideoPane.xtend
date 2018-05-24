package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import javafx.scene.control.Label
import javafx.scene.media.Media
import javafx.scene.media.MediaPlayer
import javafx.scene.media.MediaView
import javafx.scene.text.TextAlignment
import org.tbee.javafx.scene.layout.MigPane

class VideoPane extends MigPane {

	new(Source source) {
		if(source.getSourceType() != SourceType.VIDEO) {
			throw new IllegalArgumentException('''«source» is not a video''')
		}

		styleClass += "video-card"
		add(new Label(source.getComment()) => [
			styleClass += "title"
			setWrapText(true)
			setTextAlignment(TextAlignment.LEFT)
		], "wrap")
		add(new MediaView(new MediaPlayer(new Media(source.getSource.toExternalForm()))) => [
			styleClass += "video"
		], "")
		maxWidth = 400
	}

}
