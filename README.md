# 5# AFL++ suite docker 

American Fuzzy Lop and friends on Docker. An IT security tool aka fuzzer that employs genetic algorithms in order to efficiently increase code coverage of the test cases.

This is not the first AFL docker. This Dockerfile is inspired by:
* Richard Johnson's Dockerfiles for TriforceAFL https://github.com/richinseattle/Dockerfiles
* Richard Johnson's Dockerfile for afl-dyninst https://github.com/talos-vulndev/afl-dyninst/blob/master/Dockerfile

This Docker file was created by Tobias "floyd" Ospelt, Pentagrid AG "https://www.pentagrid.ch" and targets casual AFL++ users.

## TL;DR:

```
docker pull pentagrid/afl-demo
docker run -it --entrypoint=/bin/bash pentagrid/afl-demo
/examples/demo.sh
```

Or if you want to target your own binary, have a look at targets/bogofilter on how to test an open source project

## Goal of these Docker containers:

* Quick start people who have never installed AFL (hello afl-users newcomers)
* Demo some AFL capabilities, useful for demos
* Supply a quick'n'dirty solution for people who don't have a day to do a proper big setup (hello pentesters). After all, a lot of programs break after running a fuzzer less than a minute with the correct corpus.
* Provide ideas on which commands to use to install AFL++ and friends (look at the Dockerfile)
* Provide ideas on how to compile targets and which considerations to make (see demo)
* Reproduce AFL issues with a common setup
* Maybe one step in the direction of more easily to compare "dirty" performance benchmarks (e.g. where you want to debug why *huge* performance differences occur). At least using the same container means you have the same environment.
* Test environment to check if after code refactoring in various projects they are still running properly.
* Bundle helpful, generic, small sister-project tools with AFL so you don't have to fetch/compile them

## Not a goal of these Docker containers:

* Performance or production-grade big-scale fuzzing. However, always trade-off "a simple fuzzer setup could already be running now", "your simple fuzzer setup might be broken", "your complicated fuzzer setup might be broken", "INPUT CORPUS", "a proper setup might run much faster", "are my debug skills good enough to achieve a *really* proper high-performance setup?", "available CPU time compared to time spent on setting up fuzzer", INSERT a billion other considerations why people have a hate-love relationship with fuzzing.

## Building and running

WARNING: Building this Dockerfile can take hours if you want to build all multi-stages:
* afl-base: AFL++ (source-only compile), recidivm, afl-kit download/compilation takes several minutes
* afl-jqf: JQF, maven, openjdk download/compilation takes several minutes
* afl-binary-only: AFL++ (binary-only compile) download/compilation takes *more than* several minutes
* afl-blackbox: Dyninst, afl-dyninst download/compilation takes *hours*
* afl-demo: Binutils download, compilation and instrumentation in various different flavours (afl-clang-fast, vanilla clang, afl-dyninst, ASAN clang, ASAN afl-clang) takes *more than* several minutes. This image also includes the examples from this repository.

It is recommended to pull them from Dockerhub instead of compiling on your own (see TL;DR). If your own compile breaks, look at the commits that worked for the different versions here.

These are not small images. That's simply not possible if QEMU, dyninst and similar huge projects are dependencies. Also, we *want* a full OS, as users will need to compile other things in the Docker container that they want to fuzz. So this is rather the abuse-Docker-as-VM-replacement use case. However, contributions to make images smaller are welcome if there is something on the image we don't need.

Build everything:

```
./build.sh
```

You can also do individual builds up to the image you want, such as:

```
docker build --target afl-base --tag=afl-base ./dockerfiles/base/
```

Similarly, run the images with (mounting in your fuzzing corpus):

```
docker run -it --entrypoint=/bin/bash -v /fuzzing-input-dir:/host afl-base
```

If you run the afl-demo container, execute /examples/demo.sh in the container to see the interactive demo.


## Updating docker containers

* Update FROM and change to a new Ubuntu version if you want to take the long route
* add comments about "git reset --hard" to refer to the newest version that worked for your build. Because next time it breaks, you will be glad to know which last version still worked.
* test if everything works correctly (at least afl-demo), publish

## TODOs and contributions

We are happy to see pull requests or other contributions:

* Keep the images up to date
* Look into building ARM images (but from what I understand it should be fairly easy to build your own ARM images)
* RAM-disc implementation for .cur_input
* more examples/demos/tests
* more small tools useful for fuzzing see https://github.com/vanhauser-thc/AFLplusplus/blob/master/docs/sister_projects.txt
* more images for other tools to fuzz python, ruby, etc. see https://github.com/vanhauser-thc/AFLplusplus/blob/master/docs/sister_projects.txt
* better defaults for environment variables etc.

## Version 0.2

```
Ubuntu 20.04
Built May 2020
Covid-19-is-annoying release
```

Desock is now part of AFL++, no more need for preeny

###AFL++ https://github.com/vanhauser-thc/AFLplusplus
```
commit c7de368dc20078116bcb2e34b0f2237127802841
Merge: a5d4c8d fbd9994
Author: van Hauser <vh@thc.org>
```

###recidivm https://github.com/jwilk/recidivm
```
commit 6d0a8d06c22031c8a791d9b28c35a9dbf9b3d3de
Author: Jakub Wilk <jwilk@jwilk.net>
Date:   Sat May 25 22:21:17 2019 +0200
```

###afl-kit https://github.com/kcwu/afl-kit
```
commit 4a1de78a68ec192c4ec2370ebaf5b6afe2380553
Author: Denis Kasak <dkasak@users.noreply.github.com>
Date:   Thu Mar 28 07:38:19 2019 +0000
```

###dyninst https://github.com/dyninst/dyninst
```
10.1.0
```

###afl-dyninst https://github.com/vanhauser-thc/afl-dyninst
```
commit 5361d6a303ee987b933f4851e2dc78e6084083ab
Author: van Hauser <vh@thc.org>
Date:   Thu Apr 16 10:43:13 2020 +0200
```

###JQF
```
commit 10955e72aeb463b24b7c2d11e869a7fab62fb488
Merge: 008432b fc1933b
Author: vasumv <vasumv@berkeley.edu>
```

## Version 0.1

```
Ubuntu 19.10
Built December 2019
36C3 release
```

### AFL++ https://github.com/vanhauser-thc/AFLplusplus
```
commit b91000fc9e2b86ffe96bef7a30d30b7e0f1f66fc
Author: van Hauser <vh@thc.org>
Date:   Thu Dec 19 01:53:32 2019 +0100
```

### recidivm https://github.com/jwilk/recidivm
```
commit 6d0a8d06c22031c8a791d9b28c35a9dbf9b3d3de
Author: Jakub Wilk <jwilk@jwilk.net>
Date:   Sat May 25 22:21:17 2019 +0200
```

### preeny https://github.com/zardus/preeny
```
commit 4a67ed98baf97216fc4ab162ed48edb4665f7030
Author: Calle Svensson <calle.svensson@zeta-two.com>
Date:   Tue Oct 29 10:57:52 2019 +0100
```

### afl-kit https://github.com/kcwu/afl-kit
```
commit 4a1de78a68ec192c4ec2370ebaf5b6afe2380553
Author: Denis Kasak <dkasak@users.noreply.github.com>
Date:   Thu Mar 28 07:38:19 2019 +0000
```

### dyninst https://github.com/dyninst/dyninst
```
10.1.0
```

### afl-dyninst https://github.com/vanhauser-thc/afl-dyninst
```
commit 77f20d8e4d855fa9585e786ad879aeebdb3fb5d0
Author: van Hauser <vh@thc.org>
Date:   Fri Sep 20 14:49:36 2019 +0200
```

### JQF https://github.com/rohanpadhye/jqf
```
commit 5e9346440b43a341537064efd6c74d434f42fc63
Author: Rohan Padhye <rohanpadhye@cs.berkeley.edu>
Date:   Mon Oct 14 14:02:07 2019 -0700
```
