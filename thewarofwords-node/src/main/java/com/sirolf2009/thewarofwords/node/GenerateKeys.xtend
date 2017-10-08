package com.sirolf2009.thewarofwords.node

import com.sirolf2009.objectchain.common.crypto.Keys
import java.io.File
import org.apache.logging.log4j.LogManager
import org.apache.logging.log4j.Logger
import org.eclipse.xtend.lib.annotations.Accessors
import picocli.CommandLine
import picocli.CommandLine.Command
import picocli.CommandLine.Option
import picocli.CommandLine.UnmatchedArgumentException

@Command(description="Generate a public and private key pair")
@Accessors class GenerateKeys {
	
	private static final Logger log = LogManager.logger

	@Option(names=#["--private-key"], paramLabel="FILE", description="The private key location")
	private File privateKey = new File("keys/private.key");

	@Option(names=#["--public-key"], paramLabel="FILE", description="The public key location")
	private File publicKey = new File("keys/public.key");

	def void generate() {
		privateKey.parentFile.mkdirs()
		publicKey.parentFile.mkdirs()
		log.info("Generating keys")
		val keys = Keys.generateAssymetricPair()
		log.info("Writing private key to {}", privateKey)
		Keys.writeKeyToFile(keys.private, privateKey)
		log.info("Writing public key to {}", publicKey)
		Keys.writeKeyToFile(keys.public, publicKey)
	}

	def static void main(String[] args) {
		try {
			val generate = CommandLine.populateCommand(new GenerateKeys(), args)
			generate.generate()
		} catch(UnmatchedArgumentException e) {
			System.err.println(e.message)
			CommandLine.usage(new GenerateKeys(), System.err)
		}
	}

}
