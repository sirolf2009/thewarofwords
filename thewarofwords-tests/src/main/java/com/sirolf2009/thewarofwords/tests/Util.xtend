package com.sirolf2009.thewarofwords.tests

import com.sirolf2009.thewarofwords.node.TheWarOfWordsTracker
import com.sirolf2009.thewarofwords.node.TheWarOfWordsNode
import com.sirolf2009.thewarofwords.miner.TheWarOfWordsMiner

class Util {

	def static closeSafe(TheWarOfWordsTracker tracker) {
		try {
			tracker.close()
		} catch(Exception e) {
		}
	}

	def static closeSafe(TheWarOfWordsNode node) {
		try {
			node.close()
		} catch(Exception e) {
		}
	}

	def static closeSafe(TheWarOfWordsMiner miner) {
		try {
			miner.close()
		} catch(Exception e) {
		}
	}
	
}