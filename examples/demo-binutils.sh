#!/bin/bash

shopt -s expand_aliases
alias 'xx={
  case $- in
    (*x*) set +x;;
    (*) set -x
  esac
} 2> /dev/null'

rm -rf /examples/binutils-2.24/build-*/afl_in/*
rm -rf /examples/binutils-2.24/build-*/afl_out


echo -e "\033[32mWelcome. This is an interactive tutorial where you can go ahead by pressing enter. \
It shows how an old version (2.24) of readelf of binutils can be fuzzed. \
Even if we wouldn't have the source code. \
Having said that, be warned that in real world software, fuzzing can be hard to setup, especially as many closed-source programs do not read from a file or stdin. But that is not important for now, readelf reads from a file. \
The demo Dockerfile has compiled some useful things: \n\
- Regular vanilla clang readelf build (a 'normal' binary in /examples/binutils-2.24/build-clang/) \n\
- Regular vanilla clang with Address Sanitizer readelf build (an 'ASAN' binary in /examples/binutils-2.24/build-clang-asan/) \n\
- An AFL-instrumented build of readelf with afl-clang (a 'source-code-instrumented' binary in /examples/binutils-2.24/build-afl/) \n\
- An AFL-instrumented build of readelf with afl-clang with Address Sanitizer (a 'source-code-instrumented-ASAN' binary in /examples/binutils-2.24/build-afl-asan/) \n\
- To demonstrate that we can also work if we don't have the source code of readelf, an AFL-instrumented readelf binary (an 'afl-dyninst' binary in /examples/binutils-2.24/build-afl-dyninst/) \n\
Fuzzing in this demo is always aborted after a while, so be patient... if it doesn't abort after 2 mins, press Ctrl+C *once*.\n\033[0m"
read -n 1 -s -r -p $'\033[32mBtw. you can always scroll back up to see previous commands/messages (even if AFL scrolls down automatically)... Press any key to continue\n\033[0m'
set -x
/examples/binutils-2.24/build-clang/binutils/readelf -a /bin/ls | head
xx; read -n 1 -s -r -p $'\033[32mThis is what readelf usually does, printing some details about an elf file. Press any key to continue\n\033[0m'; xx;
afl-fuzz
xx; read -n 1 -s -r -p $'\033[32mYou should be a little familiar with the above... Press any key to continue\n\033[0m'; xx;
afl-dyninst
xx; read -n 1 -s -r -p $'\033[32mAnd there are various more... this is just an example for afl-dyninst. But there are afl-cmin, afl-tmin, etc. It is not too bad if you do not know them all by heart for now.\n\033[0m'; xx;

# TODO: The afl-fuzz -E and -V switches seem to behave differently sometimes...
# e.g. if no is specified, then after -V time passed the fuzzing run is still not stopped...
xx; read -n 1 -s -r -p $'\033[32mThe unclever approach first - never do this in real life: using only a seed (input) of a singe file that includes "hello". Inputs are specified with -i and in our case here that is the directory afl_in. readelf is a program that reads elf binaries and "hello" is definitely no elf binary. Press any key to continue\n\033[0m'; xx;
cd /examples/binutils-2.24/build-afl/ 
xx; echo '+ echo "hello" > afl_in/i_have_no_clue_what_Im_doing'; xx;
xx; echo "hello" > afl_in/i_have_no_clue_what_Im_doing; xx;
xx; read -n 1 -s -r -p $'\033[32mHowever, let\'s try to fuzz with that. Press any key to continue and start the first fuzzing run. After the AFL UI shows up, scroll back up to read all messages that were printed.\n\033[0m'; xx;
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl/binutils/readelf -a @@
xx; read -n 1 -s -r -p $'\033[32mThe unclever approach did not get us very far and we found 0 crashes and only very little total paths. Please remember the total paths number for now (for example 18). Do not be unclever, use good corpus data, or at least one input that makes sense. Also look at the messages that were printed before the UI was shown. Those are important messages. \n\033[0m'; xx;
rm -rf afl_out afl_in/*

xx; read -n 1 -s -r -p $'\033[32mThe smart approach - using a small elf file as an input. Let\'s do that. Luckily AFL has a small elf in its installation directory. \n\033[0m'; xx;
cd /examples/binutils-2.24/build-afl/ 
cp /afl/testcases/others/elf/small_exec.elf afl_in/
xx; read -n 1 -s -r -p $'\033[32mPress any key to continue (and scroll up again after UI started)\n\033[0m'; xx;
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl/binutils/readelf -a @@
xx; read -n 1 -s -r -p $'\033[32mStill no crash, right? However, please keep in mind that now we got a lot more total paths (for example 900). Also look at the execution speed now, everything is pretty fast (for example 750 exec/s).\n\033[0m'; xx;
rm -rf afl_out afl_in/*

# Full power, an example that uses an elf, libdislocator, finds crashes and then shows the ASAN output
xx; read -n 1 -s -r -p $'\033[32mLet\'s additionally use libdislocator (an LD_PRELOAD library that allocates memory so that crashes are more likely)... If you know Address Sanitizer (ASAN), libdislocator is not as powerful, but as it often leads to crashes (SIGABRT, SEGFAULT, etc.) in programs that have memory-safety problems, this is sufficient for fuzzing sometimes and most importantly, does not add the ASAN runtime performance overhead. But don\'t take my word, we will proof that shortly.\n\033[0m'; xx;
cd /examples/binutils-2.24/build-afl/ 
cp /afl/testcases/others/elf/small_exec.elf afl_in/
xx; read -n 1 -s -r -p $'\033[32mPress any key to continue (and scroll up again after UI started)\n\033[0m'; xx;
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl/binutils/readelf -a @@
xx; read -n 1 -s -r -p $'\033[32mHorray, a crash, a crash! But you need to proof that, this is a fuzzing setup, so maybe we just have a broken fuzzing setup? Let\'s proof that is not the case. First step is usually to run it wiht afl-showmap, which will print the program output as well. So what happens if we run the crash with afl-showmap and the same AFL-instrumented binary, but first without libdislocator?\n\033[0m'; xx;
afl-showmap -o /dev/null /examples/binutils-2.24/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*
xx; read -n 1 -s -r -p $'\033[32mWait, that is not a crash. readelf only did what it is supposed to. But what about if we run again but with libdislocator?\n\033[0m'; xx;
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-showmap -o /dev/null /examples/binutils-2.24/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*
xx; read -n 1 -s -r -p $'\033[32mInteresting, so it seems to be a crash... or is it not? Maybe it is a bug in libdislocator/AFL-instrumentation? It is not, but you can\'t know yet. There are not many easy ways to know without going the (sometimes hard) route of compiling readelf with ASAN and without any AFL-instrumentation. In practice it is not impossible that you are one of the very few people that ever try to compile a program with ASAN. Luckily this was already done in the Docker container. So the next run is a stock clang compile of readelf but with ASAN. Btw. do not run libdislocator and ASAN at the same time, they do not work well together.\n\033[0m'; xx;
/examples/binutils-2.24/build-clang-asan/binutils/readelf -a /examples/binutils-2.24/build-afl/afl_out/main/crashes/id\:000000*
xx; read -n 1 -s -r -p $'\033[32mNice. This is the power of ASAN, which we need for root cause analysis. So we *really* found a bug, a heap-buffer overflow in readelf. So now we saw that libdislocator can be really worth it. Another option (that comes with a performance overhead) is using AFL with ASAN directly. Let\'s show why performance-wise libdislocator is better than ASAN.\n\033[0m'; xx;
# We remove the crashes later at [1]

# Demonstrate the same but with AFL ASAN
cd /examples/binutils-2.24/build-afl-asan/ 
cp /afl/testcases/others/elf/small_exec.elf afl_in/
xx; read -n 1 -s -r -p $'\033[32mLet\'s use ASAN instead of libdislocator. ASAN though has a performance overhead...\n\033[0m'; xx;
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl-asan/binutils/readelf -a @@
xx; read -n 1 -s -r -p $'\033[32mOh no, what was that?! Well, it\'s very well documented in that file AFL points us to... go read it on https://github.com/vanhauser-thc/AFLplusplus/blob/master/docs/notes_for_asan.txt ! Always carefully read the output of AFL. It is saying that it crashed and there could be several reasons. The most obvious one is that AFL didn\'t give enough memory to readelf. But how much memory is necessary? We want to keep the value pretty low (close to what it really needs) for performance reasons. Let\'s use recidivm as described in that document. Luckily, recidivm comes preinstalled in the Docker.\n\033[0m'; xx;
ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" /tools/recidivm/recidivm -u M /examples/binutils-2.24/build-afl-asan/binutils/readelf -a /afl/testcases/others/elf/small_exec.elf
xx; read -n 1 -s -r -p $'\033[32mSo hopefully this just outputted something like 20971589. Anyway, the above recidivm should output roughly 20971589 and therefore we can use -m 22000000 as an argument to afl-fuzz for the memory limit. Let\'s try to start that fuzzing run with the AFL-instrumented ASAN binary again:\n\033[0m'; xx;
# We know from /tools/recidivm/recidivm -u M /examples/binutils-2.24/build-afl-asan/binutils/readelf -a /afl/testcases/others/elf/small_exec.elf it is:
# 20971589
timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -m 22000000 -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl-asan/binutils/readelf -a @@
xx; read -n 1 -s -r -p $'\033[32mGood, we got crashes again, but as you could hopefully see, the execution speed was much slower... that was the ASAN overhead. So if you can, better use libdislocator... right? Yes and no, this is just another trade-off. ASAN might be more thorough in finding memory corruptions than libdislocator, but maybe you can just run your libdislocator queue through the ASAN binary afterwards and find those crashes as well? It\'s hard to tell, you will have to go your way... \n\033[0m'; xx;
rm -rf afl_out afl_in/*

# Demonstrate the same but with QEMU mode (blackbox/no source code binary)
xx; read -n 1 -s -r -p $'\033[32mNow what about if we don\'t have the source code of a binary? That\'s a very important question, what do we do with closed source binaries? QEMU mode to the rescue (-Q for afl-fuzz), the -Q option allows to fuzz closed source binaries without doing any instrumentation before starting afl-fuzz. But there are certain problems, for example QEMU has no libdislocator support. And we can not use ASAN because we are not compiling the binary. Moreover, closed-source or not has still nothing to do with how the binary takes input, it sill needs to read from file or from stdin (which is often the biggest problem to tackle in the real world). Let\'s assume we wouldn\'t have readelf\'s source code from now on. The following invocation uses a non-instrumented binary (vanilla readelf compiled).\n\033[0m'; xx;
cd /examples/binutils-2.24/build-clang/ 
cp /afl/testcases/others/elf/small_exec.elf afl_in/
timeout -s SIGINT 40 afl-fuzz -Q -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-clang/binutils/readelf -a @@
xx; read -n 1 -s -r -p $'\033[32mStill no crash, right? But the speed should be ok (for example 370 execs/s). However, without ASAN or libdislocator, this is not much fun. We have to get creative. Imagine that we would like to fuzz ELF reading implementation of a close-source product. However, as there is also the open-source ELF reading product readelf, we could first do a fuzzing run with readelf and then use the corpus (whatever is put in the queue folder by AFL) as an input for the closed-source binary fuzzing run.\n\033[0m'; xx;
rm -rf afl_out

# Demonstrate the same but with QEMU mode (blackbox/no source code binary)
xx; read -n 1 -s -r -p $'\033[32mSo let\'s see what happens if we would already have the good corpus (from afl_out/main/queue) from the libdislocator run with the open-source version. We can then use it as an input when fuzzing the closed-source version with QEMU mode.\n\033[0m'; xx;
cd /examples/binutils-2.24/build-clang/ 
cp /examples/binutils-2.24/build-afl/afl_out/main/queue/* afl_in/
timeout -s SIGINT 40 afl-fuzz -Q -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-clang/binutils/readelf -a @@
xx; read -n 1 -s -r -p $'\033[32mStill no crash, right? However, I hope you could see that it\'s worth having a good corpus by looking at the number of total paths that went up right away at the start of afl-fuzz. You could also run the queue directory through the ASAN enabled binary now (as said, if you have the source) and maybe find a crash that ASAN can find, but does not result in a crash (SIGABRT, SEGFAULT, etc.) for AFL without ASAN. Exactly like the last crash we analyzed with ASAN.\n\033[0m'; xx;
rm -rf afl_out
# [1] Now remove the crashes from above
rm -rf /examples/binutils-2.24/build-afl/afl_out /examples/binutils-2.24/build-afl/afl_in/*

# Demonstrate the same but with afl-dyninst (blackbox/no source code binary)
xx; read -n 1 -s -r -p $'\033[32mQEMU had an overhead. You might ask if there is something more efficient for closed source binaries than QEMU? Yes, if it works that\'s afl-dyninst, which is still not perfect but has the smallest overhead. The Docker container includes an afl-dyninst binary, it\'s nothing else than a "closed-source" binary that was run through afl-dyninst. Let\'s try to use that.\n\033[0m'; xx;
cd /examples/binutils-2.24/build-afl-dyninst/
cp /afl/testcases/others/elf/small_exec.elf afl_in/
LD_LIBRARY_PATH=/afl-dyninst/ AFL_SKIP_BIN_CHECK=1 AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so timeout -s SIGINT 40 afl-fuzz -i afl_in -o afl_out -M main -s 1 -E 100000 -V 60 /examples/binutils-2.24/build-afl-dyninst/binutils/readelf_ins -a @@
xx; read -n 1 -s -r -p $'\033[32mSo why do we have such good results again and find crashes with AFL? Maybe you want to tell me, now that you mastered AFL fuzzing? You have to scroll up and check the commands up there... Press enter to get the answer\n\033[0m'; xx;
xx; read -n 1 -s -r -p $'\033[32mafl-dyninst supports libdislocator! The speed was also remarkably good, so this is the perfect combination for this fuzzing target if we wouldn\'t have the source code, fast fuzzing and a mechanism that provokes crashes if memory is handled unsafe.\n\033[0m'; xx;
rm -rf afl_out

xx; echo -e "\033[32mWe are by far not done here. There are various other optimizations and tweaks that are possible. For some you need to understand some reverse-engineering, for others you only need strace.\033[0m"
echo -e "\033[32mSo what is the best approach in the end? Well, that is the secret sauce of every single person running a fuzzer. But it certainly boils down to optimizing the corpus at one point (see afl-tmin and afl-cmin).\033[0m"
echo -e "\033[32mThe results here do not apply to every software. Some software will happily crash without ASAN and libdislocator, meaning that especially the performance overhead of ASAN is undesired.\033[0m"
echo -e "\033[32mRunning afl-fuzz instances with different approaches that collaborate is also possible with the -M -S command line options...\033[0m"
echo -e "\033[32mRemember: You can go and run everything without ASAN and libdislocator and then run the entire queue with an ASAN binary in afl-fuzz afterwards...\033[0m"
echo -e "\033[32mSo there you go... another step in the world of fuzzing with AFL\n\033[0m"; xx;
