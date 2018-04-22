package com.sirolf2009.thewarofwords.ui

import javafx.beans.property.BooleanProperty
import org.eclipse.xtend.lib.annotations.Data
import javafx.beans.property.SimpleBooleanProperty

@Data class Settings {
	
	private BooleanProperty useUpnp = new SimpleBooleanProperty(true)
	
}