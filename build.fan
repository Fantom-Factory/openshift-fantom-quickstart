using build
using fanr

class Build : BuildPod {

	new make() {
		podName = "openShiftDemo"
		summary = "Simple Fantom web application for OpenShift"
		version = Version("1.0.0")

		meta	= [
			"proj.name"		: "OpenShift Demo",
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"vcs.name"		: "Mercurial",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/openshift-fantom-quickstart",
			"license.name"	: "ISC Licence (ISC)"
		]

		depends = [
			"sys        1.0", 
			"inet       1.0", 
			
			// ---- Core ------------------------
			"afIoc      2.0", 

			// ---- Web -------------------------
			"afBedSheet 1.4"
		]

		srcDirs = [`fan/`]
	}
	
	@Target { help = "OpenShift pre-compile hook, use to install dependencies" }
	Void openShiftPreCompile() {
		pods := depends.findAll |Str dep->Bool| {
			depend := Depend(dep)
			pod := Pod.find(depend.name, false)
			return (pod == null) ? true : !depend.match(pod.version)
		}
		installFromRepo(pods, `http://pods.fantomfactory.org/fanr`)
	}

	private Void installFromRepo(Str[] pods, Uri repo) {
		if (pods.isEmpty) return
		cmd := "install -errTrace -y -r ${repo}".split.add(pods.join(","))
		log.info("")
		log.info("Installing pods...")
		log.indent
		log.info("> fanr " + cmd.join(" ") { it.containsChar(' ') ? "\"$it\"" : it })
		status := fanr::Main().main(cmd)
		log.unindent
		// abort build if something went wrong
		if (status != 0) Env.cur.exit(status)
	}
}
