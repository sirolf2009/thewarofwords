package com.sirolf2009.thewarofwords.ui.component

import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import javafx.scene.control.Label
import javafx.scene.text.Font
import javafx.scene.text.FontPosture
import org.tbee.javafx.scene.layout.MigPane

class CitationPane extends MigPane {

	static val Font ITALIC_FONT = Font.font(
		"Serif",
		FontPosture.ITALIC,
		Font.getDefault().getSize() * 1.4
	)

	new(Source source) {
		super("aligny center")
		if(source.getSourceType() != SourceType.CITATION) {
			throw new IllegalArgumentException('''«source» is not a citation''')
		}

		add(new Label(source.getComment()) => [
			font = ITALIC_FONT
		], "wrap, center")
		add(new Label("Citation: " + source.getSource().toExternalForm()) => [
			styleClass += "description"
		], "right")
	}

}
