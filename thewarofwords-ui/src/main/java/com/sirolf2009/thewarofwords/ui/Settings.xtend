package com.sirolf2009.thewarofwords.ui

import javafx.beans.property.BooleanProperty
import org.eclipse.xtend.lib.annotations.Data
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.StringProperty
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.IntegerProperty
import javafx.beans.property.SimpleIntegerProperty

@Data class Settings {
	
	private IntegerProperty hostPort = new SimpleIntegerProperty(4567)
	private StringProperty trackerIP = new SimpleStringProperty("thewarofwords.com")
	private IntegerProperty trackerPort = new SimpleIntegerProperty(2012)
	private BooleanProperty useUpnp = new SimpleBooleanProperty(true)
	
}