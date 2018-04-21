package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import javafx.scene.control.Label
import org.tbee.javafx.scene.layout.MigPane
import javafx.scene.text.Font
import javafx.scene.text.FontPosture

class CitationCard extends Card {

	static val Font ITALIC_FONT = Font.font(
		"Serif",
		FontPosture.ITALIC,
		Font.getDefault().getSize()*1.4
	)

	new(Source source) {
		if(source.getSourceType() != SourceType.CITATION) {
			throw new IllegalArgumentException('''«source» is not a citation''')
		}

		setContent(new MigPane("aligny center") => [
			add(new Label(source.getComment()) => [
//				styleClass += "citation"
				font = ITALIC_FONT
			], "wrap, center")
			add(new Label("Citation: "+source.getSource().toExternalForm()) => [
				styleClass += "description"
			], "right")
		])
	}

}
