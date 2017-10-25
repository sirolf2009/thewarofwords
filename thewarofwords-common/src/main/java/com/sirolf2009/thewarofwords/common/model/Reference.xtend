package com.sirolf2009.thewarofwords.common.model

import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtext.xbase.lib.util.ToStringBuilder

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

@Data class Reference {

	val List<Byte> topic
	val List<Byte> source

	override toString() {
		val b = new ToStringBuilder(this)
		b.add("topic", this.topic.toHexString())
		b.add("source", this.source.toHexString())
		return b.toString()
	}

}
