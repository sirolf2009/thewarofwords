package com.sirolf2009.thewarofwords.common.datomic

import com.sirolf2009.objectchain.common.crypto.CryptoHelper
import com.sirolf2009.objectchain.common.model.Block
import com.sirolf2009.objectchain.common.model.BlockHeader
import com.sirolf2009.objectchain.common.model.Hash
import com.sirolf2009.thewarofwords.common.model.Account
import com.sirolf2009.thewarofwords.common.model.SavedBlock
import com.sirolf2009.thewarofwords.common.model.SavedSource
import com.sirolf2009.thewarofwords.common.model.SavedTopic
import com.sirolf2009.thewarofwords.common.model.SavedUpvote
import com.sirolf2009.thewarofwords.common.model.Source
import com.sirolf2009.thewarofwords.common.model.SourceType
import com.sirolf2009.thewarofwords.common.model.Topic
import com.sirolf2009.thewarofwords.common.model.Upvote
import datomic.Database
import java.math.BigInteger
import java.net.URL
import java.util.Date
import java.util.Set
import java.util.TreeSet

import static extension com.sirolf2009.objectchain.common.crypto.Hashing.*

class ParseExtensions {

	def static parseAccount(Object blockID, Database database) {
		val entity = database.entity(blockID)
		val key = CryptoHelper.publicKey((entity.get(":account/key") as String).toByteArray())
		val username = entity.get(":account/username") as String
		val credibility = entity.get(":account/credibility") as Double
		return new Account(key, username, credibility)
	}

	def static parseBlock(Object blockID, Database database) {
		val entity = database.entity(blockID)
		val hash = new Hash(entity.get(":block/hash") as String)
		val number = entity.get(":block/number") as Long
		val timestamp = new Date(entity.get("block/time") as Long)
		val previousBlock = entity.get(":block/previous-block") as String
		val merkleroot = entity.get(":block/merkleroot") as String
		val time = entity.get(":block/time") as Long
		val target = entity.get(":block/target") as String
		val nonce = entity.get(":block/nonce") as Long
		val sources = entity.get(":block/added-sources") as Set<String>
		val topics = entity.get(":block/added-topics") as Set<String>

		val header = new BlockHeader(new Hash(previousBlock), new Hash(merkleroot), new Date(time), new BigInteger(target.toByteArray()), nonce.intValue())
		return new SavedBlock(hash, number, timestamp, new Block(header, new TreeSet(#[sources.map[parseSource(database).getSource()], topics.map[parseTopic(database).getTopic()]])))
	}

	def static parseTopic(Object blockID, Database database) {
		val entity = database.entity(blockID)
		val hash = new Hash(entity.get(":topic/hash") as String)
		val name = entity.get(":topic/name") as String
		val description = entity.get(":topic/description") as String
		val tags = entity.get(":topic/tags") as Set<String>
		val image = new URL(entity.get(":topic/image") as String)
		return new SavedTopic(hash, new Topic(name, description, tags, image))
	}

	def static parseUpvote(Object blockID, Database database) {
		val entity = database.entity(blockID)
		val hash = new Hash(entity.get(":upvote/hash") as String)
		val voter = CryptoHelper.publicKey((entity.get(":upvote/voter") as String).toByteArray())
		val source = new Hash(entity.get(":upvote/source") as String)
		val topic = new Hash(entity.get(":upvote/topic") as String)
		return new SavedUpvote(hash, new Upvote(voter, source, topic))
	}

	def static parseSource(Object sourceHash, Database database) {
		val entity = database.entity(sourceHash)
		val hash = new Hash(entity.get(":source/hash") as String)
		val owner = CryptoHelper.publicKey((entity.get(":source/owner") as String).toByteArray())
		val source = entity.get(":source/source") as String
		val comment = entity.get(":source/comment") as String
		val type = entity.get(":source/type") as String
		return new SavedSource(hash, owner, new Source(SourceType.valueOf(type), new URL(source), comment))
	}
	
}