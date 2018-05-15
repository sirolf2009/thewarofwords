package com.sirolf2009.thewarofwords.ui

import com.moandjiezana.toml.Toml
import com.moandjiezana.toml.TomlWriter
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.ui.model.Subscription
import java.io.File
import java.io.FileOutputStream
import java.util.Optional
import javafx.beans.property.BooleanProperty
import javafx.beans.property.IntegerProperty
import javafx.beans.property.ListProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleIntegerProperty
import javafx.beans.property.SimpleListProperty
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.StringProperty
import javafx.collections.FXCollections
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.Data

@Data class Settings {
	
	private IntegerProperty hostPort = new SimpleIntegerProperty(4567)
	private StringProperty trackerIP = new SimpleStringProperty("thewarofwords.com")
	private IntegerProperty trackerPort = new SimpleIntegerProperty(2012)
	private BooleanProperty useUpnp = new SimpleBooleanProperty(true)
	private ListProperty<Subscription> subscriptions = new SimpleListProperty(FXCollections.observableArrayList())
	
	def static Settings read(File file) {
		val flat = new Toml().read(file).to(Simple)
		val settings = new Settings()
		settings.getHostPort().set(flat.getHostPort())
		settings.getTrackerIP().set(flat.getTrackerIP())
		settings.getTrackerPort().set(flat.getTrackerPort())
		settings.getUseUpnp().set(flat.isUseUpnp())
		Optional.ofNullable(flat.getSubscriptions()).ifPresent[
			map[new Subscription(new Hash(getTopicHash()), new Hash(getLastUpdateBlock()))].forEach[
				settings.getSubscriptions().add(it)
			]
		]
		return settings
	}
	
	def void write(File file) {
		val out = new FileOutputStream(file)
		val writer = new TomlWriter()
		writer.write(new Simple(hostPort.get(), trackerIP.get(), trackerPort.get(), useUpnp.get(), subscriptions.map[new SubscriptionFlat(getTopicHash().toString(), getLastUpdateBlock().toString())].toArray(newArrayOfSize(subscriptions.size()))), out)
		out.close()
	}
	
	@Accessors static class Simple {
		int hostPort
		String trackerIP
		int trackerPort
		boolean useUpnp
		SubscriptionFlat[] subscriptions
		
		new() {
		}
		
		new(int hostPort, String trackerIP, int trackerPort, boolean useUpnp, SubscriptionFlat[] subscriptions) {
			this.hostPort = hostPort
			this.trackerIP = trackerIP
			this.trackerPort = trackerPort
			this.useUpnp = useUpnp
			this.subscriptions = subscriptions
		}
	}
	
	@Accessors static class SubscriptionFlat {
		String topicHash
		String lastUpdateBlock
		
		new() {
		}
		
		new(String topicHash, String lastUpdateBlock) {
			this.topicHash = topicHash
			this.lastUpdateBlock = lastUpdateBlock
		}
	}
	
}