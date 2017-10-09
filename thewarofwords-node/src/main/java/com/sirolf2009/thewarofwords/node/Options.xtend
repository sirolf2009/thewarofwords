package com.sirolf2009.thewarofwords.node

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import picocli.CommandLine.Option
import org.eclipse.xtend.lib.annotations.ToString

@Accessors @ToString class Options {
	
	@Option(names=#["-t", "--trackers"], description="A list of trackers to connect to", paramLabel="IP:PORT")
	var List<String> trackers = #["localhost:2012"]
	
	@Option(names=#["-p", "--port"], description="The port to host on", paramLabel="PORT")
	var int port = 4567
	
	@Option(names=#["-k", "--keys"], description="The keys to use for signing mutations", paramLabel="KEY_PATH:PUB_KEY_PATH")
	var String keys = "keys/private.key:keys/public.key"
	
	
}