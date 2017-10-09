package com.sirolf2009.thewarofwords.node

import com.sirolf2009.objectchain.tracker.Tracker

class TheWarOfWordsTracker extends Tracker {
	
	new() {
		super(2012)
	}
	
	def static void main(String[] args) {
		new TheWarOfWordsTracker().start()
	}
	
}