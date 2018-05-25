package com.sirolf2009.thewarofwords.ui

import com.esotericsoftware.kryo.Kryo
import com.esotericsoftware.kryonet.Connection
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.State
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import java.net.InetSocketAddress
import java.net.NetworkInterface
import java.security.KeyPair
import java.util.ArrayList
import java.util.List
import java.util.concurrent.Executors
import java.util.logging.Level
import javafx.application.Platform
import javafx.beans.property.BooleanProperty
import javafx.beans.property.DoubleProperty
import javafx.beans.property.IntegerProperty
import javafx.beans.property.ObjectProperty
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.beans.property.SimpleIntegerProperty
import javafx.beans.property.SimpleObjectProperty
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import org.fourthline.cling.UpnpService
import org.fourthline.cling.UpnpServiceImpl
import org.fourthline.cling.model.message.header.STAllHeader
import org.fourthline.cling.protocol.RetrieveRemoteDescriptors
import org.fourthline.cling.support.igd.PortMappingListener
import org.fourthline.cling.support.model.PortMapping
import com.sirolf2009.thewarofwords.common.model.Reference
import com.sirolf2009.thewarofwords.ui.model.Subscription
import org.controlsfx.control.Notifications
import org.controlsfx.control.action.Action
import com.sirolf2009.thewarofwords.ui.component.TopicOverview
import io.reactivex.Single

@Accessors class UINode extends TheWarOfWordsNode {

	static final Logger log = LogManager.logger

	val List<UpnpService> upnpServices = new ArrayList()
	val MainController controller
	val Settings settings
	val BooleanProperty isConnected
	val BooleanProperty isSynchronised
	val ObjectProperty<Hash> lastBlock
	val IntegerProperty nodes
	val DoubleProperty credibility

	new(MainController controller, List<InetSocketAddress> trackers, int nodePort, KeyPair keys) {
		super(trackers, nodePort, keys)
		this.controller = controller
		settings = controller.getSettings()
		isConnected = new SimpleBooleanProperty(false)
		isSynchronised = new SimpleBooleanProperty(false)
		lastBlock = new SimpleObjectProperty()
		nodes = new SimpleIntegerProperty(0)
		credibility = new SimpleDoubleProperty(0)

		if(settings.useUpnp.get()) {
			upnpPort(nodePort)
		}
		settings.useUpnp.addListener [ obs, oldVal, newVal |
			if(newVal) {
				upnpPort(nodePort)
			} else {
				upnpServices.forEach[shutdown()]
			}
		]
	}

	override synchronized onNewConnection(Kryo kryo, Connection connection) {
		Platform.runLater [
			isConnected.set(true)
			nodes.set(nodes.get() + 1)
		]
		super.onNewConnection(kryo, connection)
	}

	override onDisconnected(Connection connection) {
		Platform.runLater [
			nodes.set(Math.max(0, nodes.get() - 1))
			if(nodes.get() == 0) {
				isConnected.set(false)
			}
		]
	}

	override onBlockchainExpanded() {
		val block = blockchain.mainBranch.getLastBlock()
		val hash = hash(block)
		block.getMutations().map[getObject()].forEach [
			if(it instanceof Reference) {
				val topic = getTopic()
				settings.getSubscriptions().filter[getTopicHash().equals(topic)].toList().forEach [
					settings.getSubscriptions().remove(it)
					settings.getSubscriptions().add(new Subscription(getTopicHash(), hash))

					val state = blockchain.mainBranch.lastState as State
					state.getTopic(getTopicHash()).subscribe([
						Notifications.create().title(getTopic().getName()).text("New source has been submitted").action(new Action("Show", [evt|controller.setNewsContent(new TopicOverview(controller, it))])).show()
					], [printStackTrace()])
				]
			}
		]
		Platform.runLater [
			lastBlock.set(hash)
		]
		(blockchain.mainBranch.getLastState() as State).getAccount(getKeys().public).map[it.getCredibility()].switchIfEmpty(Single.create([onSuccess(0d)])).subscribe [
			Platform.runLater [
				credibility.set(it)
			]
		]
	}

	override onSynchronised() {
		isSynchronised.set(true)
	}

	def upnpPort(int port) {
		val itr = NetworkInterface.getNetworkInterfaces()
		while(itr.hasMoreElements()) {
			val interface = itr.nextElement()
			val addrItr = interface.inetAddresses
			while(addrItr.hasMoreElements()) {
				val address = addrItr.nextElement().toString()
				if(address.startsWith("192.168") || address.startsWith("192.178.") || address.startsWith("10.")) {
					upnpPort(address, port)
				} else if(address.startsWith("/192.168") || address.startsWith("/192.178.") || address.startsWith("/10.")) {
					upnpPort(address.substring(1), port)
				}
			}
		}
	}

	def upnpPort(String host, int port) {
		log.info('''Starting upnp on «host»:«port»''')
		try {
			java.util.logging.Logger.getLogger(RetrieveRemoteDescriptors.getName()).level = Level.SEVERE
			val desiredMapping = new PortMapping(port, host, PortMapping.Protocol.TCP, "The War of Words mapping")
			val upnpService = new UpnpServiceImpl(new PortMappingListener(desiredMapping))
			val executor = Executors.newSingleThreadExecutor()
			upnpServices.add(upnpService)
			executor.submit(upnpService.getProtocolFactory().createSendingSearch(new STAllHeader(), 3))
			Thread.sleep(1000)
			executor.shutdownNow()
			Runtime.getRuntime().addShutdownHook(new Thread[upnpService.shutdown()])
		} catch(Exception e) {
			log.error('''Failed to host upnp on «host»:«port»''', e)
		}
	}

}
