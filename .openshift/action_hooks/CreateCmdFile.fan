
class CreateCmdFile {
	
	static Void main(Str[] args) {
		scriptFileName	:= args[0]
		launchFileName	:= args[1]

		if (launchFileName.toUri.toFile.exists) {
			echo("'${launchFileName}' already exists.")
			return
		}

		buildType 		:= Env.cur.compileScript(`$scriptFileName`.toFile)
		buildClass		:= buildType.make
		podName 		:= buildClass->podName
		
		cmd				:= "fan ${podName}"
		launchOut		:= launchFileName.toUri.toFile.out

		try {
			launchOut.printLine
			launchOut.printLine(cmd)
			launchOut.printLine
			echo(cmd)
		} finally {
			launchOut.close
		}
	}
}
