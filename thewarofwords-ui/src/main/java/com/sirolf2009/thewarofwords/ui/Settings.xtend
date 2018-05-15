package com.sirolf2009.thewarofwords.ui

import com.moandjiezana.toml.TomlWriter
import java.io.File
import java.io.FileOutputStream
import javafx.beans.property.BooleanProperty
import javafx.beans.property.IntegerProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleIntegerProperty
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.StringProperty
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data
import com.moandjiezana.toml.Toml

@Data class Settings {
	
	private IntegerProperty hostPort = new SimpleIntegerProperty(4567)
	private StringProperty trackerIP = new SimpleStringProperty("thewarofwords.com")
	private IntegerProperty trackerPort = new SimpleIntegerProperty(2012)
	private BooleanProperty useUpnp = new SimpleBooleanProperty(true)
	
	def static Settings read(File file) {
		val flat = new Toml().read(file).to(Simple)
		val settings = new Settings()
		settings.getHostPort().set(flat.getHostPort())
		settings.getTrackerIP().set(flat.getTrackerIP())
		settings.getTrackerPort().set(flat.getTrackerPort())
		settings.getUseUpnp().set(flat.isUseUpnp())
		return settings
	}
	
	def void write(File file) {
		val out = new FileOutputStream(file)
		val writer = new TomlWriter()
		writer.write(new Simple(hostPort.get(), trackerIP.get(), trackerPort.get(), useUpnp.get()), out)
		out.close()
	}
	
	@Accessors static class Simple {
		int hostPort
		String trackerIP
		int trackerPort
		boolean useUpnp
		
		new() {
		}
		
		new(int hostPort, String trackerIP, int trackerPort, boolean useUpnp) {
			this.hostPort = hostPort
			this.trackerIP = trackerIP
			this.trackerPort = trackerPort
			this.useUpnp = useUpnp
		}
	}
	
}