package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.ui.MainController
import javafx.scene.control.Label
import javafx.scene.text.Font
import javafx.scene.text.FontPosture
import org.tbee.javafx.scene.layout.MigPane

class CitationCard extends SourceCard {

	static val Font ITALIC_FONT = Font.font(
		"Serif",
		FontPosture.ITALIC,
		Font.getDefault().getSize()*1.4
	)

	new(MainController controller, SavedTopic topic, SavedSource source) {
		super(controller, topic, source)
		if(source.getSource().getSourceType() != SourceType.CITATION) {
			throw new IllegalArgumentException('''«source» is not a citation''')
		}

		setContent(new MigPane("aligny center") => [
			add(new Label(source.getSource().getComment()) => [
//				styleClass += "citation"
				font = ITALIC_FONT
			], "wrap, center")
			add(new Label("Citation: "+source.getSource().getSource().toExternalForm()) => [
				styleClass += "description"
			], "right")
		])
	}

}
