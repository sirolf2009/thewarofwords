package com.sirolf2009.thewarofwords.restnode

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString
import picocli.CommandLine.Option

@Accessors @ToString class Options {
	
	@Option(names=#["-t", "--trackers"], description="A list of trackers to connect to", paramLabel="IP:PORT")
	var List<String> trackers = #["localhost:2012"]
	
	@Option(names=#["-p", "--port"], description="The port to host on", paramLabel="PORT")
	var int port = 4567
	@Option(names=#["-rp", "--rest-port"], description="The port to host the rest api on", paramLabel="PORT")
	var int restPort = 4568
	
	@Option(names=#["-k", "--keys"], description="The keys to use for signing mutations", paramLabel="KEY_PATH:PUB_KEY_PATH")
	var String keys = "keys/private.key:keys/public.key"
	
	
}