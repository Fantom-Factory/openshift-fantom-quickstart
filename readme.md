# Fantom Quickstart for OpenShift
---
[![Written for: Fantom](http://img.shields.io/badge/written%20for-Fantom-lightgray.svg)](http://fantom.org/)
![Licence: ISC](http://img.shields.io/badge/licence-ISC-blue.svg)



This is a simple [BedSheet][afBedSheet] web application for OpenShift.

Use it as a template to help bootstrap your own [Fantom][fantom] web applications on the [OpenShift][openShift] platform.

The quickstart application serves static files from the `html/` directory.

Contents:

[TOC]



## Quickstart - One-liner

Assuming you've installed the [OpenShift client tools][openShiftClientTools] and run [setup][openShiftClientSetup], you can create and deploy to live, the quickstart example in one line:

```
#!bash
C:\> rhc create-app quickstart diy-0.1 --from-code https://bitbucket.org/AlienFactory/openshift-fantom-quickstart.git

Application Options
-------------------
Domain:     <domain>
Cartridges: diy-0.1
Gear Size:  default
Scaling:    no

Creating application 'quickstart' ... done

Waiting for your DNS name to be available ... done

Cloning into 'quickstart'...

Your application 'quickstart' is now available.

  URL:        http://quickstart-<domain>.rhcloud.com/
  SSH to:     xxxx@quickstart-<domain>.rhcloud.com
  Git remote: ssh://xxxx@quickstart-<domain>.rhcloud.com/~/git/quickstart.git/
  Cloned to:  C:/quickstart

Run 'rhc show-app quickstart' for more details about your app.
```

You should now be able to view your application on a public URL:

```
http://quickstart-<domain>.rhcloud.com/index.html
```

![Quickstart in Action](https://bitbucket.org/repo/jByan7/images/852575017-quickstartInAction.png)

Congratulations!

Next I would reccomend reading the manual setup below, to more fully understand what's just happened!



## Quickstart - Manual

### 1. Create a DIY application

Assuming you've installed the [OpenShift client tools][openShiftClientTools] and run [setup][openShiftClientSetup], create a fresh OpenShift application with the DIY cartridge.

This example will create an application called `quickstart`:

```
C:\> rhc app create quickstart diy-0.1
```

This creates a fresh application in the `quickstart` directory. We don't actually want any of the files as we're going to replace the entire application with our own. So delete everything, but make sure you keep the hidden `.git` directory - we need this!

```
C:\> rmdir /S /Q quickstart\.openshift
C:\> rmdir /S /Q quickstart\diy
C:\> rmdir /S /Q quickstart\misc
C:\> del      /Q quickstart\README.md
```

Download the [Fantom Quickstart for OpenShift][openShiftFantomDownload] and unzip it to the `quickstart` directory. Next, add all the files to Git:

```
C:\quickstart> git add -A
```

The Quickstart directory should then look like this:

![quickstart directory listing](https://bitbucket.org/repo/jByan7/images/3800185121-quickstartDirList.png)

The `.openshift/action_hooks/` directory are where the OpenShift scripts are kept:

 - `deploy` - run when changes are pushed to the OpenShift Git repository
 - `start` - run to start the application
 - `stop` - run to stop the application

The `deploy` script is used to install fantom and build your application.

Note that the scripts need execute rights. Linux users can use the standard `chmod` cmd. Windows users can use the following:

```
C:\> cd quickstart
C:\quickstart> git update-index --chmod=+x .openshift\action_hooks\deploy
C:\quickstart> git update-index --chmod=+x .openshift\action_hooks\start
C:\quickstart> git update-index --chmod=+x .openshift\action_hooks\stop
```

Finally, commit the quickstart application to git:

```
C:\quickstart> git commit -m "Git is!"
```



### 2. Build the Fantom pod

When this application deploys, it downloads a fresh copy of Fantom (v1.0.67 at time of writing) and installs it in the directory `$OPENSHIFT_DATA_DIR/.fantom/`. 

The `.openshift/action_hooks/deploy` script then compiles your application from source by running the following 2 commands:

```
#!bash
$ fan build.fan openShiftPreCompile

$ fan build.fan compile
```

This typically builds a pod and installs it to the Fantom environment.

Because the Fantom installation is a fresh one, before your source can compile, it needs to download and install all external pods dependencies (such as the most excellent [BedSheet][afBedSheet]) into your Fantom environment. This is what the (optional) `openShiftPreCompile` build target is for.



### 3. Start the application

The `.openshift/action_hooks/start` script requires a file called `openShiftCmd.txt` in the root of your project dir. It executes this as a script passing in the `$OPENSHIFT_DIY_PORT` and `$OPENSHIFT_DIY_IP` environment variables. Your web application should use these to open a socket.

If `openShiftCmd.txt` does not exist then the 'deploy' script will create one for you, it will contain the one line: 

```
fan <podName>
```

Where `<podName>` is taken from `build.fan`.

The above one-liner would call `<podName>::Main.main(Str[] args)` passing in the port number and IP address your web app should listen on. Make sure both the class and method exist to successfully launch your application.

Note that `openShiftCmd.txt` is a plain text file and does not need execution rights.



### 4. Git push your code

To deploy and run your application on OpenShift, simply `git push` your code as normal and hopefully you should see something like this:

```
#!bash

C:\> git push origin

Counting objects: 23, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (15/15), done.
Writing objects: 100% (17/17), 8.01 KiB, done.
Total 17 (delta 0), reused 0 (delta 0)
remote: Stopping DIY cartridge
remote: Building git ref 'master', commit 3c2d44c
remote: Preparing build for deployment
remote: Deployment id is bd2c4c17
remote: Activating deployment
remote:
remote: -----> Downloading https://bitbucket.org/fantom/fan-1.0/downloads/fantom-1.0.67.zip ... done
remote: -----> Installing Fantom 1.0.67... done
remote:
remote:        Fantom Launcher
remote:        Copyright (c) 2006-2013, Brian Frank and Andy Frank
remote:        Licensed under the Academic Free License version 3.0
remote:
remote:        Java Runtime:
remote:          java.version:    1.7.0_85
remote:          java.vm.name:    OpenJDK Server VM
remote:          java.vm.vendor:  Oracle Corporation
remote:          java.vm.version: 24.85-b03
remote:          java.home:       /usr/lib/jvm/java-1.7.0-openjdk-1.7.0.85/jre
remote:          fan.platform:    linux-x86
remote:          fan.version:     1.0.67
remote:          fan.env:         sys::BootEnv
remote:          fan.home:        /var/lib/openshift/xxxx/app-root/data/.fantom
remote:
remote: -----> Calling Build Target: openShiftPreCompile...
remote:
remote:        Installing pods...
remote:          > fanr install -y -r http://pods.fantomfactory.org/fanr "afIoc 2.0,afBedSheet 1.4"
remote:
remote:        afBeanUtils   [install]  not-installed => 1.0.4
remote:        afBedSheet    [install]  not-installed => 1.4.14
remote:        afConcurrent  [install]  not-installed => 1.0.8
remote:        afIoc         [install]  not-installed => 2.0.10
remote:        afIocConfig   [install]  not-installed => 1.0.16
remote:        afIocEnv      [install]  not-installed => 1.0.18
remote:        afPlastic     [install]  not-installed => 1.0.18
remote:
remote:
remote:        Downloading afConcurrent ... Complete
remote:        Downloading afIocEnv ... Complete
remote:        Downloading afPlastic ... Complete
remote:        Downloading afBeanUtils ... Complete
remote:        Downloading afIocConfig ... Complete
remote:        Downloading afIoc ... Complete
remote:        Downloading afBedSheet ... Complete
remote:
remote:        Download successful (7 pods)
remote:
remote:        Installing afConcurrent ... Complete
remote:        Installing afIocEnv ... Complete
remote:        Installing afPlastic ... Complete
remote:        Installing afBeanUtils ... Complete
remote:        Installing afIocConfig ... Complete
remote:        Installing afIoc ... Complete
remote:        Installing afBedSheet ... Complete
remote:
remote:        Installation successful (7 pods)
remote:
remote: -----> Calling Build Target: compile...
remote:        compile [openShiftDemo]
remote:          Compile [openShiftDemo]
remote:            FindSourceFiles [2 files]
remote:            WritePod [file:/var/lib/openshift/xxxx/app-root/data/.fantom/lib/fan/openShiftDemo.pod]
remote:        BUILD SUCCESS [665ms]!
remote:
remote: -----> Creating openShiftCmd.txt ...
remote:        fan openShiftDemo
remote:
remote: Starting DIY cartridge
remote: -----> Launching: fan openShiftDemo 8080 127.11.244.129
remote: [info] [afBedSheet] Found mod 'openShiftDemo::AppModule'
remote: [info] [afIoc] Adding module definitions from pod 'openShiftDemo'
remote: [info] [afIoc] Adding module definition for afBedSheet::BedSheetModule
remote: [info] [afIoc] Adding module definition for afIocConfig::ConfigModule
remote: [info] [afIoc] Adding module definition for afBedSheet::BedSheetEnvModule
remote: [info] [afIoc] Adding module definition for afIocEnv::IocEnvModule
remote: [info] [afIoc] Adding module definition for openShiftDemo::AppModule
remote: [info] [afBedSheet] Starting Bed App 'OpenShift Demo' on port 8080
remote: [info] [web] WispService started on port 8080
remote: [info] [afIocEnv] Environment has not been configured. Defaulting to 'PRODUCTION'
remote:
remote: 42 IoC Services:
remote:   10 Builtin
remote:   28 Defined
remote:    0 Proxied
remote:    4 Created
remote:
remote: 66.67% of services are unrealised (28/42)
remote:    ___    __                 _____        _
remote:   / _ |  / /_____  _____    / ___/__  ___/ /_________  __ __
remote:  / _  | / // / -_|/ _  /===/ __// _ \/ _/ __/ _  / __|/ // /
remote: /_/ |_|/_//_/\__|/_//_/   /_/   \_,_/__/\__/____/_/   \_, /
remote:          Alien-Factory BedSheet v1.4.14, IoC v2.0.10 /___/
remote:
remote: IoC Registry built in 799ms and started up in 117ms
remote:
remote: Bed App 'OpenShift Demo' listening on http://localhost:8080/
remote:
remote: -------------------------
remote: Git Post-Receive Result: success
remote: Activation status: success
remote: Deployment completed with status: success
To ssh://xxxx@quickstart-<domain>.rhcloud.com/~/git/quickstart.git/
   4d6982b..3c2d44c  master -> master
```

You should then be able to view your application on a public URL:

```
http://quickstart-<domain>.rhcloud.com/index.html
```

![Quickstart in Action](https://bitbucket.org/repo/jByan7/images/852575017-quickstartInAction.png)



## Installing Fantom pods

More than likely, your application has dependencies on external Fantom pods such as [BedSheet][afBedSheet] and [IoC][afIoc]. These pods need to be installed by the `openShiftPreCompile()` build task. The easiest means of doing so, is by programmatically calling `fanr`.



### From a local repository

You can install pods from a local `fanr` repository as long as it is checked into your OpenShift Git repository. For example, if your project had the following directory structure:

```
|-fan/
|  |...
|-lib-fanr/
|  `-afBedSheet/
|     `-afBedSheet-1.4.x.pod
`-build.fan
```

You could then install BedSheet like this:

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

Most external pods are available publicly, usually from the [Fantom Repository][fantom-repo]. Here is a modified script that downloads and installs IoC from there:

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



### Example build script

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

OpenShift comes with Java 1.7 pre-installed by default. If you wish for a different version of Java, you'll need to update the `deploy' script. Try [this link][openShiftJava] for Java 1.8 - for anything else, Google is your friend!

To download and use a different version of Fantom, change the `FAN_VERSION` variable in the `deploy` script. Note you'll have to delete the current `FAN_HOME` directory to force the script to download a new version of Fantom.



## Licence

The Openshift Fantom Quickstart is licensed under the ISC Licence. See `licence.txt` for details.



Have fun!

[fantom]: http://fantom.org/
[openShift]: https://www.openshift.com/
[afBedSheet]: http://pods.fantomfactory.org/pods/afBedSheet/
[afIoc]: http://pods.fantomfactory.org/pods/afIoc/
[fantom-repo]: http://pods.fantomfactory.org/
[openShiftClientTools]: https://developers.openshift.com/en/getting-started-overview.html
[openShiftClientSetup]: https://developers.openshift.com/en/managing-client-tools.html#rhc-setup
[openShiftFantomDownload]: https://bitbucket.org/AlienFactory/openshift-fantom-quickstart/downloads
[openShiftJava]: https://pbaris.wordpress.com/2015/08/14/install-java-8-to-openshift-diy-cartridge/