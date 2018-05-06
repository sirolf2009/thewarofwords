package com.sirolf2009.thewarofwords.ui.component

import com.esotericsoftware.kryo.io.ByteBufferOutput
import com.sirolf2009.objectchain.common.model.Mutation
import com.sirolf2009.thewarofwords.common.model.IVerifiable
import com.sirolf2009.thewarofwords.ui.MainController
import java.nio.ByteBuffer
import java.util.ArrayList
import java.util.List
import java.util.function.Consumer
import javafx.application.Platform
import javafx.beans.property.SimpleStringProperty
import javafx.scene.control.ProgressBar
import org.tbee.javafx.scene.layout.MigPane
import javafx.scene.control.Label
import javafx.scene.control.Button

abstract class MutationForm<T> extends MigPane {

	val List<Runnable> onChangedListeners = new ArrayList()
	val compileMutationError = new SimpleStringProperty()
	val ProgressBar sizeProgressBar
	val MainController controller
	
	new(MainController controller) {
		super("fillx")
		this.controller = controller
		
		sizeProgressBar = sizeProgressBar(controller)
		compileListener(controller)
	}
	
	def T getMutation()
	
	def addFooter(Consumer<T> onSubmitted) {
		add(new Label() => [
			textProperty().bind(compileMutationError)
		], "skip 1, split 2, growx")
		add(new Button("Submit") => [
			onAction = [onSubmitted.accept(this.getMutation())]
			disableProperty.bind(sizeProgressBar.progressProperty().greaterThanOrEqualTo(1).or(sizeProgressBar.progressProperty().lessThanOrEqualTo(0)).or(compileMutationError.isNotEqualTo("")))
		], "right, wrap")

		add(new Label("Size"))
		add(sizeProgressBar, "span, growx")
	}
	
	def notifyChanged() {
		onChangedListeners.forEach[controller.run(it)]
	}

	def compileListener(MainController controller) {
		onValueChange [
			try {
				getMutation() => [
					if(it instanceof IVerifiable) {
						verifyStatic()
						controller.getNode().getKryoPool().run [ kryo |
							verifyBytes(kryo)
							return null
						]
					}
				]
				Platform.runLater[compileMutationError.set("")]
			} catch(Exception e) {
				Platform.runLater[compileMutationError.set(e.getMessage())]
			}
		]
	}

	def sizeProgressBar(MainController controller) {
		new ProgressBar() => [
			val maxSize = controller.getNode().getConfiguration().getMaxSizePerMutation()
			progress = 0
			onValueChange [
				try {
					val node = controller.getNode()
					val size = node.getKryoPool().run [ kryo |
						val buffer = new ByteBufferOutput(ByteBuffer.allocate(maxSize.intValue()))
						kryo.writeObject(buffer, new Mutation(getMutation(), kryo, node.getKeys()))
						return buffer.getByteBuffer().position
					]
					Platform.runLater[progress = size.doubleValue() / maxSize.doubleValue()]
				} catch(Exception e) {
				}
			]
		]
	}

	def onValueChange(Runnable runnable) {
		onChangedListeners.add(runnable)
	}

}
