package com.sirolf2009.thewarofwords.node

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import picocli.CommandLine.Option

@Accessors class Options {
	
	@Option(names=#["-t", "--trackers"], description="A list of trackers to connect to", paramLabel="IP:PORT")
	val List<String> trackers = #["localhost:2012"]
	
	@Option(names=#["-p", "--port"], description="The port to host on", paramLabel="PORT")
	val int port = 4567
	
	@Option(names=#["-k", "--keys"], description="The keys to use for signing mutations", paramLabel="KEY_PATH:PUB_KEY_PATH")
	val String keys = "keys/private.key:keys/public.key"
	
	
}