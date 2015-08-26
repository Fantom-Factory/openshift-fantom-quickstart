#Fantom Web Application for OpenShift
---
[![Written for: Fantom](http://img.shields.io/badge/written%20for-Fantom-lightgray.svg)](http://fantom.org/)
![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)



## Overview

This is a simple [BedSheet][afBedSheet] web application for OpenShift.

Use it as a template to help bootstrap your own [Fantom][fantom] web applications on the [OpenShift][openShift] platform.

Contents:

[TOC]

##OpenShift Deployment

Steps to OpenShift Fantom fulfillment:

1. Create a fresh OpenShift application
2. Create your Fantom environment
3. Start your web app
4. Git push your code



### 1. Create a fresh OpenShift application

Create a fresh OpenShift web app with the DIY cartridge.

Delete the standard files

Copy this project

mention `.openshift/action_hooks` scripts

TODO: xxxx



### 2. Create your Fantom environment

When this application deploys, it downloads a fresh copy of Fantom (v1.0.67 at time of writing) and installs it in the directory `$OPENSHIFT_DATA_DIR/.fantom/`. 

The 'deploy' script then compiles your application from source by running the following 2 commands:

```
#!bash
C:\> fan build.fan openShiftPreCompile

C:\> fan build.fan compile
```

Because the Fantom installation is a fresh one, before your source can compile, it needs to download and install all external pods dependencies (such as the most excellent [BedSheet][afBedSheet]) into your Fantom environment. This is what the (optional) `openShiftPreCompile` build target is for.



### 3. Start your web app

The `start` script requires a file called `openShiftCmd.txt` in the root of your project dir. It executes this as a script passing in the `$OPENSHIFT_DIY_PORT` and `$OPENSHIFT_DIY_IP` environement varaibles that your web app should bind to and listen on.

```
#!bash
|-fan/
|  |...
|-build.fan
`-openShiftCmd.txt
```

If `openShiftCmd.txt` does not exist then the 'deploy' script will create one for you, that contains the one line: 

```
#!bash
fan <podName>
```

Where `<podName>` is taken from `build.fan`.

The above one-liner would call `<podName>::Main.main(Str[] args)` passing in the port number and IP address your web app should listen on. Make sure this class and method exists to successfully launch your application.

Note that `openShiftCmd.txt` is a plain text file and does not need execution rights.



### 4. Git push your code

To deploy and run your application on OpenShift, simply `git push` your code as normal and hopefully you should see something like this:

```
#!bash

C:\> git push master

remote: Building git ref 'master', commit b0de02b
remote: Preparing build for deployment
remote: Deployment id is f78cfc59
remote: Activating deployment
remote:
remote: -----> Calling Build Target: openShiftPreCompile...
remote: -----> Calling Build Target: compile...
remote:        compile [openShiftDemo]
remote:          Compile [openShiftDemo]
remote:            FindSourceFiles [2 files]
remote:            WritePod [file:/var/lib/openshift/xxxx/app-root/data/.fantom/lib/fan/openShiftDemo.pod]
remote:        BUILD SUCCESS [2586ms]!
remote: -----> Creating openShiftCmd.txt ...
remote: Starting DIY cartridge
remote: -----> Launching: fan openShiftDemo  8080 127.6.218.1
remote:
remote: Bed App 'OpenShift Demo' listening on http://localhost:8080/
remote:
remote: -------------------------
remote: Git Post-Receive Result: success
remote: Activation status: success
remote: Deployment completed with status: success
```



## Installing Fantom pods

More than likely, your application has dependencies on external Fantom pods such as [BedSheet][afBedSheet] and [IoC][afIoc]. These pods need to be installed by the `herokuPreCompile()` build task. The easiest means of doing so, is by programmatically calling `fanr`.



### From a local repository

You can install pods from a local `fanr` repository as long as it is checked into your OpenShift Git repository. For example, if your project had the following directory structure:

```
#!bash
|-fan/
|  |...
|-lib-fanr/
|  `-afBedSheet/
|     `-afBedSheet-1.4.x.pod
`-build.fan
```

You could then install [BedSheet][afBedSheet] like this:

```
#!java
@Target { help = "OpenShift pre-compile hook, use to install dependencies" }
Void openShiftPreCompile() {

    // install pods from a local fanr repository
    fanr("install -y -r file:lib-fanr/ afBedSheet")
}

private Void fanr(Str args) {
    fanr::Main().main(args.split)
}
```

This is useful when you're using pods developed by yourself, or ones that are not publicly available.



### From a remote repository

Most external pods are available publicly, usually from the [Fantom Repository][fantom-repo]. Here is a modified script that downloads and installs pods from there:

```
#!java
@Target { help = "OpenShift pre-compile hook, use to install dependencies" }
Void openShiftPreCompile() {

    // install pods from a remote fanr repository
    fanr("install -y -r http://pods.fantomfactory.org/ afIoc")
}

private Void fanr(Str args) {
    fanr::Main().main(args.split)
}
```



### Example Script

If *ALL* your dependant pods are available from the same repository (probably [Fantom Repository][fantom-repo]), then here is a useful script that installs everything for you:

```
#!java
@Target { help = "OpenShift pre-compile hook, use to install dependencies" }
Void openShiftPreCompile() {

    // find all non-installed dependant pods
    pods := depends.findAll |Str dep->Bool| {
        depend := Depend(dep)
        pod := Pod.find(depend.name, false)
        return (pod == null) ? true : !depend.match(pod.version)
    }
    installFromRepo(pods, "http://pods.fantomfactory.org/")
}

private Void installFromRepo(Str[] pods, Str repo) {
    if (pods.isEmpty) return
    cmd := "install -errTrace -y -r ${repo}".split.add(pods.join(","))
    log.info("")
    log.info("Installing pods...")
    log.info("> fanr " + cmd.join(" ") { it.containsChar(' ') ? "\"$it\"" : it })
    status := fanr::Main().main(cmd)
    // abort build if something went wrong
    if (status != 0) Env.cur.exit(status)
}
```

Output from a successful install should look like:

```
#!bash

Installing pods...
> fanr install -errTrace -y -r http://repo.status302.com/fanr/ "..."

afBedSheet         [install]  not-installed => 1.3.4
afIoc              [install]  not-installed => 1.5.4
afIocConfig        [install]  not-installed => 1.0.4
afIocEnv           [install]  not-installed => 1.0.2.1
afPlastic          [install]  not-installed => 1.0.10

Downloading afIocConfig ... Complete
Downloading afIoc ... Complete
Downloading afIocEnv ... Complete
Downloading afPlastic ... Complete
Downloading afBedSheet ... Complete

Download successful (5 pods)

Installing afIocConfig ... Complete
Installing afIoc ... Complete
Installing afIocEnv ... Complete
Installing afPlastic ... Complete
Installing afBedSheet ... Complete

Installation successful (5 pods)
```



## Installing Java libraries

Sometimes you have a dependency on a Java library. To install these, again make sure they are checked into your OpenShift Git repository. Assuming the jars are in the following directory structure:

```
#!bash
|-fan/
|  |...
|-lib-java/
|  `-wotever-1.7.2.jar
`-build.fan
```

You can install them like this:

```
#!java
@Target { help = "OpenShift pre-compile hook, use to install dependencies" }
Void openShiftPreCompile() {
   
    // install jar files from local
    installJar(`lib/java/wotever-1.7.2.jar`)
}

private Void installJar(Uri jarFile) {
    (scriptDir + jarFile).copyInto(devHomeDir + `lib/java/ext/`, ["overwrite" : true])		
}
```



## Installing specific versions of Java and Fantom

Currently, OpenShift applications have access to Java 1.7 by default.

Google OpenShift+ java 1.8, modify deploy script to install

Fantom-1.0.67 is specified in deploy script - change it there.

TODO: xxxx



## Licence

Licensed under the ISC Licence. See `licence.txt` for details.



Have fun!

[fantom]: http://fantom.org/
[openShift]: https://www.openshift.com/
[afBedSheet]: http://pods.fantomfactory.org/pods/afBedSheet/
[afIoc]: http://pods.fantomfactory.org/pods/afIoc/
[fantom-repo]: http://pods.fantomfactory.org/
