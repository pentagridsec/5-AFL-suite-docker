#!/bin/bash

rm -rf /examples/binutils-2.24/build-*/afl_in/*
rm -rf /examples/binutils-2.24/build-*/afl_out

#Intro
read -n 1 -s -r -p $'\033[32mWelcome. This is an interactive tutorial showing how AFL works. You can go ahead to the next step by pressing enter. \n\033[0m'
read -n 1 -s -r -p $'\033[32mThis demo shows how an old version (version 2.24) of readelf of the binutils suite can be fuzzed. This demo shows how the author approaches it. However, keep in mind that fuzzing is a multi-dimension optimization problem, so it is perfectly fine if you disagree with the approach, every fuzzing person has their own strategy. That\'s why fuzzing is such an interesting field. Nearly every recommendation in this demo could be countered with a "but it depends..." discussion or even an outright "but nowadays there is the new tool XYZ that is much more efficient". Fuzzing requires optimizing at least speed, code coverage, the input mutation approach and the instrumentation overhead for bug finding. On the other side it is just super important that you achieve running a fuzzer at all...\n\033[0m'
read -n 1 -s -r -p $'\033[32mreadelf is used as a target because it had issues in the past and the source code is available. However, we also show how it could be fuzzed even if we wouldn\'t have the source code (blackbox binary). Of course that will be a non-real-world approach, don\'t do blackbox fuzzing when you have the source. \n\033[0m'
read -n 1 -s -r -p $'\033[32mBe warned that in real world software, fuzzing can be much harder to setup, especially as many closed-source programs do not read from a file or stdin. But that is not important for now, readelf reads from a file. That is another reason why it was chosen for this demo. \n\033[0m'
read -n 1 -s -r -p $'\033[32mThe demo Dockerfile includes some precompiled useful things for you already (it would take too much time to compile it during the demo): \n
- Regular vanilla clang readelf build (a \'normal\' binary in /examples/binutils-2.24/build-clang/). Build commands were:
  # CC=clang CXX=clang++ CFLAGS="-Wno-error" ./configure
  # CFLAGS="-Wno-error" make\n\033[0m'
read -n 1 -s -r -p $'\033[32m- Regular vanilla clang with Address Sanitizer readelf build (an \'ASAN\' binary in /examples/binutils-2.24/build-clang-asan/). Build commands were: 
  # CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS=\'-fsanitize=address\' ./configure
  # CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make\n\033[0m'
read -n 1 -s -r -p $'\033[32m- An AFL-instrumented build of readelf with afl-clang (a \'source-code-instrumented\' binary in /examples/binutils-2.24/build-afl/). Build commands were:
  # CC=afl-clang CXX=afl-clang++ CFLAGS="-Wno-error" ./configure
  # CFLAGS="-Wno-error" make\n\033[0m'
read -n 1 -s -r -p $'\033[32m- An AFL-instrumented build of readelf with afl-clang with Address Sanitizer (a \'source-code-instrumented-ASAN\' binary in /examples/binutils-2.24/build-afl-asan/). Build commands were: 
  # AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS=\'-fsanitize=address\' ./configure 
  # AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make\n\033[0m'
read -n 1 -s -r -p $'\033[32m- To demonstrate that we can also work if we don\'t have the source code of readelf, an AFL-instrumented readelf binary (an \'afl-dyninst\' binary in /examples/binutils-2.24/build-afl-dyninst/) was created. The input was simply the \'normal\' vanilla clang binary: 
  # /afl-dyninst/afl-dyninst -i readelf -o readelf_ins -s 100\n\033[0m'
read -n 1 -s -r -p $'\033[32mThe commands that will be printed in this tutorial are the ones that you should usually use. However, in reality in this demo additional commands and arguments are used for demonstration purposes, so for example that fuzzing stops after a certain time (usually you have to abort it manually). However, we want to keep the commands simple and the experiments reproducible, so the bloat is not shown to you.\n\033[0m'
read -n 1 -s -r -p $'\033[32mFuzzing in this demo is always aborted after a while, so be patient... Never press Ctrl+C or anything like that. \n\033[0m'
read -n 1 -s -r -p $'\033[32mImportant: you can and should always scroll back up to see previous commands/messages (even if AFL scrolls down automatically). Let\'s finnally start.\n\033[0m'
echo "# /examples/binutils-2.24/build-clang/binutils/readelf -a /bin/ls | head"
/examples/binutils-2.24/build-clang/binutils/readelf -a /bin/ls | head
read -n 1 -s -r -p $'\033[32mThis is our target for this demo and what readelf usually does, printing some details about an elf file. In this case we printed some details about the ls binary located in the bin directory.\n\033[0m';
echo "# afl-fuzz"
afl-fuzz
read -n 1 -s -r -p $'\033[32mYou should be a little familiar with the above, this is the afl-fuzz command that will be used for the actual fuzzing run. \n\033[0m';
echo "# afl-showmap"
afl-showmap
read -n 1 -s -r -p $'\033[32m\nYou should be a little familiar with the above, this is the afl-showmap command that is often used as a first test and debugging step if something doesn\'t work. It allows you to see the paths taken in readelf for a certain input file. \n\033[0m';
echo "# afl-cmin"
afl-cmin
read -n 1 -s -r -p $'\033[32mafl-cmin can be used to minimize a set of input files (called corpus), to only use the ones that lead to new coverage. While it can be time consuming to run it, having a good corpus is important. Choosing the correct starting corpus is one of the most essential decisions of fuzzing. As afl-cmin is currently (there are already plans to change this) only single threaded, which is not efficient if you want to minimize a large corpus. For the moment you can also find afl-cmin.py in /tools/afl-kit in all our Docker images, which allows multi-threading minimization.\n\033[0m';
echo "# afl-tmin"
afl-tmin
read -n 1 -s -r -p $'\033[32mafl-tmin can be used to trim down the file size of an input, while checking that the input file still triggers the same code paths through the binary. In a perfect world you would afl-cmin and afl-tmin your entire corpus before starting a fuzzing run.\n\033[0m';
echo "# afl-dyninst"
afl-dyninst
read -n 1 -s -r -p $'\033[32mAnd there are various more... this is just an example for afl-dyninst, used to instrument binaries where you don\'t have the source code for. And I already hear other fuzzing people screaming "but dyninst\'s instrumentation is not the best!" and I agree. But also QEMU mode has it\'s quirks. While one of them might be faster, the question is as well which one will produce better instrumentation? Let\'s put this aside for a moment. \n\033[0m';

#Unclever approach
read -n 1 -s -r -p $'\033[32mLet\'s do a very unclever approach of fuzzing first - never do this in real life: Doing a fuzzing rung by using only a seed (input) of a singe file that includes "hello". readelf is a program that reads elf binaries and "hello" is definitely no elf binary. Inputs are specified with -i for afl-fuzz and in our case here that is the directory afl_in.\n\033[0m';
echo "# cd /examples/binutils-2.24/build-afl/"
cd /examples/binutils-2.24/build-afl/ 
echo '# echo "hello" > afl_in/i_have_no_clue_what_Im_doing';
echo "hello" > afl_in/i_have_no_clue_what_Im_doing;
read -n 1 -s -r -p $'\033[32mHowever, let\'s try to fuzz with this very poor starting corpus and start the first fuzzing run. After the AFL UI shows up, scroll back up to read all messages that were printed.\n\033[0m';
echo "# afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.24/build-afl/binutils/readelf -a @@"
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mNo crashes and around 1600 exec/s here. The unclever approach did not get us very far and we found 0 crashes and only very little total paths, check the output above. Please remember the total paths number (for example 18) and the last current speed (for example 1600/sec) for now. Do not be unclever, use good corpus data, or at least one input that makes sense. Also look at the messages that were printed before the UI was shown. Those are important messages. \n\033[0m';
echo "# rm -rf afl_out afl_in/*"
rm -rf afl_out afl_in/*

# Smart approach
read -n 1 -s -r -p $'\033[32mThe smart approach - using a small elf file as an input. Let\'s do that. Luckily the AFL repository has a small elf that can be used as a starting corpus in its installation directory. \n\033[0m';
echo "# cd /examples/binutils-2.24/build-afl/"
cd /examples/binutils-2.24/build-afl/ 
echo "# cp /afl/testcases/others/elf/small_exec.elf afl_in/"
cp /afl/testcases/others/elf/small_exec.elf afl_in/
read -n 1 -s -r -p $'\033[32mPress any key to continue (and scroll up again after UI started)\n\033[0m';
echo "# afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.24/build-afl/binutils/readelf -a @@"
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mStill no crash and around 1400 exec/s, right? However, please keep in mind that now we got a lot more total paths (for example 182 or 900). Also look at the execution speed now, everything is pretty fast (for example 1400 exec/s). You might say "that\'s slower than the unclever approach!" but keep in mind that the readelf parser now actually processes different elf binaries rather than just rejecting "hello" and variants of it very early. So in this case trading some speed (exec/s) with better code coverage was the right choice.\n\033[0m';
rm -rf afl_out afl_in/*
read -n 1 -s -r -p $'\033[32mSo far the readelf binary didn\'t crash. One of the reasons is because even if we would have triggered a memory corruption, there is no guarantee that binaries will crash. That\'s why we can write memory corruption exploits at all and also why you were able to cheat in Pokemon on the Gameboy to duplicate your items (but that\'s another story that should be told another time).\n\033[0m';

# With libdislocator
read -n 1 -s -r -p $'\033[32mLet\'s additionally use libdislocator. It is an LD_PRELOAD library that allocates memory in a way that crashes are more likely if memory corruptions occur. If you know Address Sanitizer (ASAN), libdislocator is not as powerful, but as it tries to trigger crashes (SIGABRT, SEGFAULT, etc.) in programs that have memory-safety problems, this is sufficient for fuzzing sometimes. And most importantly, while it adds a runtime overhead, it does not add the large ASAN runtime performance overhead. But don\'t take my word, we will proof that shortly (as in "proof" that it works, not "proof" that it is better for fuzzing than ASAN).\n\033[0m';
echo "# cd /examples/binutils-2.24/build-afl/"
cd /examples/binutils-2.24/build-afl/ 
echo "# cp /afl/testcases/others/elf/small_exec.elf afl_in/"
cp /afl/testcases/others/elf/small_exec.elf afl_in/
read -n 1 -s -r -p $'\033[32mPress any key to continue (and scroll up again after UI started)\n\033[0m';
echo "# AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.24/build-afl/binutils/readelf -a @@"
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mHorray, a crash, a crash! And around 1150 exec/s. But you need to proof the crash, this is a fuzzing setup, so maybe we just have a broken fuzzing setup? Let\'s proof that is not the case. First step is usually to run it with afl-showmap, which will print the program output as well. So what happens if we run the crash with afl-showmap and the same AFL-instrumented binary?\n\033[0m';
echo "# afl-showmap -o /dev/null /examples/binutils-2.24/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*"
afl-showmap -o /dev/null /examples/binutils-2.24/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*
read -n 1 -s -r -p $'\033[32mWait, that is not a crash. readelf only did what it is supposed to. The problem is that we didn\'t use libdislocator. But what about if we run again but with libdislocator?\n\033[0m';
echo "# AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-showmap -o /dev/null /examples/binutils-2.24/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*"
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-showmap -o /dev/null /examples/binutils-2.24/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*
read -n 1 -s -r -p $'\033[32mInteresting, so it seems to be a crash... or is it not? Maybe it is a bug in libdislocator/AFL-instrumentation? It is not, but you can\'t know yet. There are not many easy ways to know without going the (sometimes hard) route of compiling readelf with ASAN or making a test case that crashes the vanilla binary (the one without any AFL-instrumentation or other special compile settings). An alternative would be to run it with valgrind (similar to ASAN). Is building with ASAN easy? In practice it is not impossible that you are one of the few people that ever try to compile a program with ASAN. Not for mainstream projects, but especially for niche projects and non-OpenSource code. Depening on the build chain it might be very tricky to compile with ASAN. But here were are lucky. This was already done in the Docker container (scroll up to the start to see the compile instructions again). So the next run is a stock clang compile of readelf but with ASAN. Btw. do not run libdislocator and ASAN at the same time, they do not work well together (apparently). Remember, ASAN and libdislocator serve similar purposes during fuzzing runs (notice memory corruptions).\n\033[0m';
echo "# /examples/binutils-2.24/build-clang-asan/binutils/readelf -a /examples/binutils-2.24/build-afl/afl_out/main/crashes/id\:000000*"
/examples/binutils-2.24/build-clang-asan/binutils/readelf -a /examples/binutils-2.24/build-afl/afl_out/main/crashes/id\:000000*
read -n 1 -s -r -p $'\033[32mNice. This is the power of ASAN, which we need for root cause analysis. So we *really* found a bug it seems, a heap-buffer overflow in readelf. Keep in mind that this analytic power is important for root cause analysis (which libdislocator doesn\'t provide), which is something completely different than fuzzing runtime. So now we saw that libdislocator can be really worth it during fuzzing runtime, as it found the crash, which we later confirmed with ASAN. But what about performance? If you check the last exec speed it was around 1150/sec for me, so again a little down from without libdislocator but again a trade-off (less speed better crash detection) that seems to be worth it. Another option (that comes with a larger performance overhead) is using AFL with ASAN directly during fuzzing runtime. Let\'s show why performance-wise libdislocator is better than ASAN.\n\033[0m';
# We remove the crashes later at [1]

# Demonstrate the same but with AFL ASAN
echo "# cd /examples/binutils-2.24/build-afl-asan/"
cd /examples/binutils-2.24/build-afl-asan/ 
echo "# cp /afl/testcases/others/elf/small_exec.elf afl_in/"
cp /afl/testcases/others/elf/small_exec.elf afl_in/
read -n 1 -s -r -p $'\033[32mLet\'s use the afl-ASAN binary instead of libdislocator. ASAN though has a larger performance overhead...\n\033[0m';
echo "# afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.24/build-afl-asan/binutils/readelf -a @@"
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl-asan/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mOh no, what was that?! Well, it\'s very well documented in that file AFL points us to... go read it on https://github.com/AFLplusplus/AFLplusplus/blob/master/docs/notes_for_asan.txt ! Always carefully read the output of AFL. It is saying that it crashed and there could be several reasons. The most obvious one is that AFL didn\'t give enough memory to readelf. But how much memory is necessary? We want to keep the value pretty low (close to what it really needs) for performance reasons. Let\'s use recidivm as described in that document. Luckily, recidivm comes preinstalled in the Docker.\n\033[0m';
echo '# ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" /tools/recidivm/recidivm -u M /examples/binutils-2.24/build-afl-asan/binutils/readelf -a /afl/testcases/others/elf/small_exec.elf'
ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" /tools/recidivm/recidivm -u M /examples/binutils-2.24/build-afl-asan/binutils/readelf -a /afl/testcases/others/elf/small_exec.elf
read -n 1 -s -r -p $'\033[32mSo hopefully this just outputted something like 20971582. Anyway, the above recidivm should output roughly 20971582 and therefore we can use -m 22000000 as an argument to afl-fuzz for the memory limit. Let\'s try to start that fuzzing run with the AFL-instrumented ASAN binary again:\n\033[0m';
echo "# afl-fuzz -i afl_in -o afl_out -m 22000000 -M main /examples/binutils-2.24/build-afl-asan/binutils/readelf -a @@"
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -m 22000000 -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl-asan/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mWe got crashes again, but as you could hopefully see, the execution speed was much slower with around 300 exec/s for me... that was the ASAN overhead. So if you can, better use libdislocator... right? Yes and no, this is just another optimization problem. ASAN might be more thorough in finding memory corruptions than libdislocator, but maybe you can just run your libdislocator queue through the ASAN binary afterwards and find those crashes as well? In general it seems more important at this stage to discover more code paths than being more thorough with ASAN. What the best strategy is, is the one that finds the most bugs/crashes. But that strategy is only known once you found the bugs/crashes, which kind of defeats the point. So it\'s hard to tell, you will have to go your optimized way in practice... \n\033[0m';
echo "# rm -rf afl_out afl_in/*"
rm -rf afl_out afl_in/*

# Demonstrate the same but with QEMU mode (blackbox/no source code binary)
read -n 1 -s -r -p $'\033[32mNow what about if we don\'t have the source code of a binary? That\'s a very important question, what do we do with closed source binaries? QEMU mode to the rescue (-Q for afl-fuzz), the -Q option allows to fuzz closed source binaries without doing any instrumentation before starting afl-fuzz. By now, QEMU even has libdislocator support. We can not use ASAN because we are not compiling the binary (although that\'s also not entirely true anymore, there are projects injecting ASAN instrumentation into closed source projects, but let\'s forget about that for now). Moreover, closed-source or not has still nothing to do with how the binary takes input, it sill needs to read from file or from stdin (which is often one of the bigger problems to tackle in the real world). Let\'s assume we wouldn\'t have readelf\'s source code from now on. The following invocation uses a non-instrumented binary (vanilla readelf compiled).\n\033[0m';
echo "# cd /examples/binutils-2.24/build-clang/"
cd /examples/binutils-2.24/build-clang/
echo "# cp /afl/testcases/others/elf/small_exec.elf afl_in/"
cp /afl/testcases/others/elf/small_exec.elf afl_in/
echo "# afl-fuzz -Q -i afl_in -o afl_out -M main /examples/binutils-2.24/build-clang/binutils/readelf -a @@"
timeout -s SIGINT 40 afl-fuzz -Q -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-clang/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mNo crash, right? But the speed should be okish (for example 500 execs/s). However, without ASAN or libdislocator, this is not much fun. We have to get creative. Imagine that we would like to fuzz ELF reading implementation of a close-source product. However, as there is also the open-source ELF reading product readelf, we could first do a fuzzing run with readelf and then use the corpus (whatever is put in the queue folder by AFL) as an input for the closed-source binary fuzzing run.\n\033[0m';
echo "# rm -rf afl_out afl_in/*"
rm -rf afl_out afl_in/*

# QEMU mode + good corpus
read -n 1 -s -r -p $'\033[32mSo let\'s see what happens if we would already have the good corpus (from afl_out/main/queue) from the last libdislocator run with the open-source version. We can then use it as an input when fuzzing the closed-source version with QEMU mode.\n\033[0m';
echo "# cd /examples/binutils-2.24/build-clang/ "
cd /examples/binutils-2.24/build-clang/ 
echo "# cp /examples/binutils-2.24/build-afl/afl_out/main/queue/* afl_in/"
cp /examples/binutils-2.24/build-afl/afl_out/main/queue/* afl_in/
echo "# afl-fuzz -Q -i afl_in -o afl_out -M main /examples/binutils-2.24/build-clang/binutils/readelf -a @@"
timeout -s SIGINT 40 afl-fuzz -Q -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-clang/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mStill no crash, still roughly 500 exec/s. However, I hope you could see that it\'s worth having a good corpus by looking at the number of total paths that went up right away at the start of afl-fuzz. You could also run the queue directory through an ASAN enabled binary now (as said, if you have the source) and maybe find a crash that ASAN can find, but does not result in a crash (SIGABRT, SEGFAULT, etc.) for AFL without ASAN or libdislocator. There\'s a lot of mix and match you can do. Exactly like the last crash we analyzed with ASAN.\n\033[0m';
echo "# rm -rf afl_out afl_in/*"
rm -rf afl_out afl_in/*

# libdislocator + QEMU + good corpus
read -n 1 -s -r -p $'\033[32mNow that QEMU mode also has libdislocator support, let\'s try that again with our good corpus.\n\033[0m';
echo "# cd /examples/binutils-2.24/build-clang/ "
cd /examples/binutils-2.24/build-clang/ 
echo "# cp /examples/binutils-2.24/build-afl/afl_out/main/queue/* afl_in/"
cp /examples/binutils-2.24/build-afl/afl_out/main/queue/* afl_in/
echo "# AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -Q -i afl_in -o afl_out -M main /examples/binutils-2.24/build-clang/binutils/readelf -a @@"
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so timeout -s SIGINT 40 afl-fuzz -Q -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-clang/binutils/readelf -a @@
read -n 1 -s -r -p $'\033[32mCrashes and still roughly 400 execs/s for me. Nice, libdislocator + QEMU + good corpus rocks.\n\033[0m';
echo "# rm -rf afl_out afl_in/*"
rm -rf afl_out afl_in/*

# Demonstrate the same but with afl-dyninst (blackbox/no source code binary)
read -n 1 -s -r -p $'\033[32mQEMU had an overhead. You might ask if there is something more efficient for closed source binaries than QEMU? Yes, if it works that\'s afl-dyninst, which is still not perfect (the instrumentation is different) but has the smallest performance overhead. The Docker container includes an afl-dyninst binary, it\'s nothing else than a "closed-source" binary that was run through afl-dyninst. Let\'s try to use that.\n\033[0m';
echo "# cd /examples/binutils-2.24/build-afl-dyninst/"
cd /examples/binutils-2.24/build-afl-dyninst/
echo "# cp /examples/binutils-2.24/build-afl/afl_out/main/queue/* afl_in/"
cp /examples/binutils-2.24/build-afl/afl_out/main/queue/* afl_in/
echo "# LD_LIBRARY_PATH=/afl-dyninst/ AFL_SKIP_BIN_CHECK=1 AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.24/build-afl-dyninst/binutils/readelf_ins -a @@"
LD_LIBRARY_PATH=/afl-dyninst/ AFL_SKIP_BIN_CHECK=1 AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl-dyninst/binutils/readelf_ins -a @@
read -n 1 -s -r -p $'\033[32mCrashes and around 1000 exec/s. So why do we have such good results again and find crashes with AFL? Maybe you want to tell me, now that you mastered AFL fuzzing? You have to scroll up and check the commands up there... Press enter to get the answer\n\033[0m';
read -n 1 -s -r -p $'\033[32mafl-dyninst supports libdislocator as well and it was used, because afl-dyninst just instruments the binary as if it was built with afl-clang. The speed was also remarkably good, so this is the perfect combination for this fuzzing target if we wouldn\'t have the source code: 1. fast fuzzing, 2. a mechanism that provokes crashes if memory is handled unsafe (libdislocator) and 3. a good corpus. Or isn\'t it? Maybe we could... Yes. For sure. Just remember a smart hacky approach is better than perfect.\n\033[0m';
echo "# rm -rf afl_out afl_in/*"
rm -rf afl_out afl_in/*
# [1] Now remove the crashes from above
echo "# rm -rf /examples/binutils-2.24/build-afl/afl_out /examples/binutils-2.24/build-afl/afl_in/*"
rm -rf /examples/binutils-2.24/build-afl/afl_out /examples/binutils-2.24/build-afl/afl_in/*

echo -e "\033[32mWe are by far not done here. There are various other optimizations and tweaks that are possible. For some you need to understand some reverse-engineering, for others you only need strace.\033[0m"
echo -e "\033[32mWe haven't even looked at the readelf binary yet and we should probably optimize its startup time if possible (the forkserver already takes care of parts of it).\033[0m"
echo -e "\033[32mSo what is the best approach in the end? Well, that is the secret sauce of every single person running a fuzzer. But it certainly boils down to optimizing the corpus at one point (see afl-tmin and afl-cmin).\033[0m"
echo -e "\033[32mThe results here do not apply to every software. Some software will happily crash without ASAN and libdislocator, meaning that especially the performance overhead of ASAN is undesired.\033[0m"
echo -e "\033[32mRunning afl-fuzz instances with different approaches that collaborate is also possible with the -M -S command line options...\033[0m"
echo -e "\033[32mRemember: You can go and run everything without ASAN and libdislocator and then run the entire queue with an ASAN binary in afl-fuzz afterwards...\033[0m"
echo -e "\033[32mSo there you go... another step in the world of fuzzing with AFL\n\033[0m";
