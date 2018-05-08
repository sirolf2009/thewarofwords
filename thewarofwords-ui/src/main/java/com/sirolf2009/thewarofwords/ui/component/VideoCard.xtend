package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.scene.control.Label
import javafx.scene.media.Media
import javafx.scene.media.MediaPlayer
import javafx.scene.media.MediaView
import javafx.scene.text.TextAlignment
import org.tbee.javafx.scene.layout.MigPane

class VideoCard extends SourceCard {
	
	new(MainController controller, SavedTopic topic, SavedSource source) {
		super(controller, topic, source)
		if(source.getSource().getSourceType() != SourceType.VIDEO) {
			throw new IllegalArgumentException('''«source» is not a video''')
		}

		setContent(new MigPane() => [
			styleClass += "video-card"
			add(new Label(source.getSource().getComment()) => [
				styleClass += "title"
				setWrapText(true)
				setTextAlignment(TextAlignment.LEFT)
			], "wrap")
			add(new MediaView(new MediaPlayer(new Media(source.getSource.getSource().toExternalForm()))) => [
				styleClass += "video"
			], "")
			maxWidth = 400
		])
	}

}
