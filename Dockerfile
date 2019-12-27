
# 
# AFL++ section docker multi-stage build
# - The base image you always need
# 

#FROM ubuntu:18.04 AS afl-base
#means:
#apt-get install llvm-6.0
#symlink to /usr/bin/llvm-config-?.?

FROM ubuntu:19.10 AS afl-base
#means:
#apt-get install llvm-8-dev
#symlink to /usr/bin/llvm-config-?

MAINTAINER Tobias "floyd" Ospelt, Pentagrid AG "https://www.pentagrid.ch"
# Update first
# According to https://docs.docker.com/develop/develop-images/dockerfile_best-practices/ this is not best practice...
#RUN apt-get -y update && apt-get -y upgrade
# Moreover, we do not need to run "apt-get -y autoremove && rm -rf /var/lib/apt/lists/*" or such as the official Ubuntu/Debian images
# do that automatically:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
# https://github.com/moby/moby/blob/03e2923e42446dbb830c654d0eec323a0b4ef02a/contrib/mkimage/debootstrap#L82-L105

# See https://github.com/vanhauser-thc/AFLplusplus/blob/master/docs/env_variables.txt
ENV AFL_PATH=/afl/ \
	AFL_LLVM_LAF_SPLIT_SWITCHES=1 \
	AFL_LLVM_LAF_TRANSFORM_COMPARES=1 \
	AFL_LLVM_LAF_SPLIT_COMPARES=1 \
	AFL_LLVM_LAF_SPLIT_FLOATS=1 \
	AFL_IMPORT_FIRST=1 \
	AFL_FAST_CAL=1 \
	AFL_ALLOW_TMP=1 \
	AFL_ANALYZE_HEX=1
#AFL_TMPDIR=/ramdisc/ \
#AFL_TMIN_EXACT=1 \
#AFL_PRELOAD=libdislocator.so
#AFL_SKIP_BIN_CHECK=1 \
#AFL_DUMB_FORKSRV=1 \
#AFL_LLVM_INSTRIM=1 \
#AFL_LLVM_INSTRIM_LOOPHEAD=1 \
#AFL_LLVM_NOT_ZERO=1 \
#AFL_LLVM_WHITELIST=/afl/list-of-files.txt
#AFL_INST_RATIO=100 \
#AFL_NO_BUILTIN=1 \
#TMPDIR=/afl_tmp/ \
#AFL_KEEP_ASSEMBLY=1 \
#AFL_QUIET=1 \
#AFL_CAL_FAST=1 \
#AFL_HARDEN=1 \
#AFL_DONT_OPTIMIZE=1 \
#AFL_USE_ASAN=1 \
#AFL_USE_MSAN=1 \
#AFL_SKIP_CPUFREQ=1 \
#AFL_NO_FORKSRV=1 \
#AFL_EXIT_WHEN_DONE=1 \
#AFL_NO_AFFINITY=1 \
#AFL_SKIP_CRASHES=1 \
#AFL_HANG_TMOUT=1 \
#AFL_NO_ARITH=1 \
#AFL_SHUFFLE_QUEUE=1 \
#AFL_POST_LIBRARY=1 \
#AFL_PYTHON_MODULE=1 \
#AFL_PYTHON_ONLY=1 \
#AFL_NO_UI=1
#AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 \
#AFL_BENCH_JUST_ONE=1 \
#AFL_BENCH_UNTIL_CRASH=1 \
#AFL_DEBUG_CHILD_OUTPUT=1 \
#AFL_QEMU_COMPCOV=1 \
#AFL_DEBUG=1 \
#AFL_ENTRYPOINT=1 \
#AFL_KEEP_TRACES=1 \

# AFL++
# Untested with https://github.com/google/AFL.git
# We do not install the following packages on purpose:
# automake qemu llvm-8-dev libiberty-dev libboost-all-dev libelf1 libelf-devlibdw-dev libboost-all-dev 
# A lot of them are dependencies of other packages which we don't need to install implicitly
# boost, dwarf and elf utilities will be downloaded and installed by dyninst itself, 
# which is probably the best way rather than rely on the OS provided ones
# General rule is: do an apt-get install in the same RUN as you need it. That allows to
# remove a tool more easily by uncommenting lines and then the image size is smaller
# use llvm-config-?.? for llvm 6.0 and earlier
# AFL++ commit "works for me" as in git reset --hard.
# Before the big code refactoring of AFL++: c124576a4dc00e31ad5cad118098f46eaa29cd17 -> python2.7-dev and python2.7 instead of python 3!
# Right after the big code refactoring of AFL++: a67d86c6e2ca58db81f2ddf6d0a4c837be88271d -> python2.7-dev and python2.7 instead of python 3!
# Just add this before make:
# && git reset --hard d8059cab6b09bf2e29e8b8db3d40567f193310d5 
RUN apt-get update && apt-get -y install build-essential gcc clang git python3.7-dev python3.7 vim flex lib32gcc-9-dev gcc-9-plugin-dev && \
	git clone https://github.com/vanhauser-thc/AFLplusplus.git /afl && cd /afl/ && \
	ln -s /usr/bin/llvm-config-? /usr/bin/llvm-config && \
	make source-only && make install

# TODO: Users can point .cur_input with AFL_TMPDIR to ramdisc: 
# https://docs.docker.com/storage/tmpfs/ so maybe rather:
# docker run -d --tmpfs /run:rw,noexec,nosuid,size=65536k
#RUN mkdir -p /ramdisc && mount -t tmpfs -o size=128M tmpfs /ramdisc

# recidivm
# This is a very small project and is helpful when you realize everything runs fine with huge memory values
# for "afl-fuzz -m", but you want to know it a little bit more exact
RUN mkdir /tools && git clone https://github.com/jwilk/recidivm.git /tools/recidivm && cd /tools/recidivm && \
	make

# preeny
# This is a very small project and is helpful for certain network binaries to make them do IO via stdin/stdout
RUN apt-get update && apt-get -y install libini-config-dev libseccomp-dev && \
	git clone https://github.com/zardus/preeny.git /tools/preeny && cd /tools/preeny/ && \
	make

# afl-kit
# This is a very small project and as you will always need to preselect a corpus to use, having an afl-cmin that
# runs faster can be really helpful
RUN git clone https://github.com/kcwu/afl-kit.git /tools/afl-kit


ENV AFL_CC=clang \
	AFL_CXX=clang++ \
	AFL_AS=as


#
# JQF section
#
# - This section is first, as compiling afl-binary-only takes time and disc space (which we can prevent if we build with docker build --target afl-jqf --tag=afl-jqf .)

FROM afl-base AS afl-jqf

ENV AFL_DIR=/afl/

# JQF
# If you get an error like
# [ERROR] Failed to execute goal on project jqf-examples: Could not resolve dependencies for project edu.berkeley.cs.jqf:jqf-examples:jar:1.2-SNAPSHOT: Failed to collect dependencies at org.apache.tika:tika-parsers:jar:1.18 -> org.apache.tika:tika-core:jar:1.18 -> org.apache.sis.core:sis-metadata:jar:0.8: Failed to read artifact descriptor for org.apache.sis.core:sis-metadata:jar:0.8: Could not transfer artifact org.apache.sis:parent:pom:0.8 from/to central (https://repo.maven.apache.org/maven2): /root/.m2/repository/org/apache/sis/parent/0.8/parent-0.8.pom.part (No such file or directory) -> [Help 1]
# just run the build process again. Such errors are rare but might occur. 
# JQF commit "works for me" as in git reset --hard. Add this at the end if you want a specific commit
# && git reset --hard 7d3270f8d69fff928591a874efcf8ee513205eb0
RUN apt-get update && apt-get -y install maven openjdk-11-jdk-headless && \
	git clone https://github.com/rohanpadhye/jqf.git /jqf && \
	cd /jqf && /jqf/setup.sh


# 
# Binary-only (QEMU, unicorn) section docker multi-stage build
# - If you are fuzzing something closed-source but you don't need dyninst-afl, you could use this. However, as a user I would prefer afl-blackbox. But afl-blackbox takes much longer to compile.
# 

FROM afl-base AS afl-binary-only

# binary-only, see AFL++ Makefile plus afl-dyninst
# 
RUN apt-get update && apt-get -y install libtool-bin wget bison libglib2.0-dev libpixman-1-dev python-setuptools && \
	cd /afl/ && make binary-only && make install


# 
# Blackbox (binary-only + Dyninst) section docker multi-stage build
# - If you are fuzzing something closed-source, you want this
# 

FROM afl-binary-only AS afl-blackbox

# dyninst (first dyninst itself, then afl-dyninst)
# To prevent an extra Docker layer that stores the /dyninst stuff, we need to do this in a single RUN command,
# which is a little ugly, so I put the echo commands there to show how I would separate into single RUN commands
# if it wouldn't be for the layers...
# For the first RUN command we can also install an older version of dyninst instead:
# RUN apt remove libdw-dev libdw1 libdwarf-dev libdwarf1 libelf1 libelf-dev && \
# 	  apt install flex libfl-dev libfl2 gawk && \
#	  git clone git://sourceware.org/git/elfutils.git /elfutils && cd /elfutils && \
#     autoreconf -i -f && \
#     ./configure --enable-maintainer-mode && \
#     make && make install && \
#	  git clone https://github.com/dyninst/dyninst.git /dyninst-git && \
# 	  cd /dyninst-git && git reset --hard 6a71517fb076390ef2c00b4df1dbc5b0607bb5fe && mkdir build && cd build && cmake .. && \
#     make -Wparentheses && make install
# afl-dyninst commit "works for me" as in git reset --hard. Add this line before make:
# git reset --hard c2f14ea01b9060d0b95719ff01d2ac6a2b38dcb3 && 
RUN apt-get update && apt-get -y install curl cmake && \
	curl -L https://github.com/dyninst/dyninst/archive/v10.1.0.tar.gz | tar zxf - && \
	cd dyninst-10.1.0 && mkdir build && cd build && cmake .. && \
    make && make install && \
	echo "Another RUN for afl-dyninst - do not use https://github.com/talos-vulndev/afl-dyninst.git" && \
	apt-get update && apt-get -y install libiberty-dev && \
	git clone https://github.com/vanhauser-thc/afl-dyninst.git /afl-dyninst && cd /afl-dyninst && \
	ln -s /afl afl && make && \
	cd /afl-dyninst && cp afl-dyninst /usr/local/bin && cp libAflDyninst.so /usr/local/lib && \
	echo "/usr/local/lib" > /etc/ld.so.conf.d/dyninst.conf && ldconfig && \
	rm -rf /dyninst-*

ENV DYNINSTAPI_RT_LIB /usr/local/lib/libdyninstAPI_RT.so

ENV AFL_CC=clang \
	AFL_CXX=clang++ \
	AFL_AS=as

#
# Demo section docker multi-stage build
# - Demonstrate how crashes can found with AFL on an old readelf of binutils 2.24
# 

FROM afl-blackbox AS afl-demo

# From now on compile by default with AFL...
ENV	CC=/afl/afl-clang-fast \
	CXX=/afl/afl-clang-fast++

# afl-clang build first
RUN mkdir /examples && \
	cd /examples && curl -L http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz | tar zxf - && cd binutils-2.24 && \
	mkdir -p build-afl/afl_in && cd build-afl && CC=afl-clang-fast CXX=afl-clang-fast++ CFLAGS="-Wno-error" ../configure && CFLAGS="-Wno-error" make && cd ..
	
# regular clang build
RUN cd /examples/binutils-2.24 && \
	mkdir -p build-clang/afl_in && cd build-clang && CC=clang CXX=clang++ CFLAGS="-Wno-error" ../configure && CFLAGS="-Wno-error" make && cd ..

# And also with afl-dyninst
# although that's not necessary (as we have the source code), we still demonstrate how it works
# DYNINSTAPI_RT_LIB should already be set from the docker container
# As we did not strip the binary, we do not need to specify the address of main with -e
RUN cd /examples/binutils-2.24/ && cp -r build-clang build-afl-dyninst && cd build-afl-dyninst && \
	/afl-dyninst/afl-dyninst -i ./binutils/readelf -o ./binutils/readelf_ins -s 100

# A clang ASAN and hardened build to look at crashes later
# Usually you would need to run docker with "--cap-add SYS_PTRACE" for ASAN to work
# However, that's not possible in "docker build", see https://github.com/moby/moby/issues/1916
# However, we are lucky, if we don't use LeakSanitizer (ASAN_OPTIONS="detect_leaks=0"),
# then we don't need SYS_PTRACE!

# If you want to know more about ASAN compile flags, what can be tricky, maybe read:
# https://www.mail-archive.com/ffmpeg-devel@ffmpeg.org/msg23631.html
# https://savannah.gnu.org/patch/?8775
# https://github.com/floyd-fuh/afl-crash-analyzer/blob/master/testcases/ffmpeg/install.sh#L44

# In any case, we can't use LeakSanitizer (detect_leaks=1), otherwise it would already fail during compilation time with:
# =================================================================
# ==43180==ERROR: LeakSanitizer: detected memory leaks
#
# Direct leak of 7123 byte(s) in 755 object(s) allocated from:
#     #0 0x4c6cf3 in malloc (/examples/binutils-2.24/build-clang-asan/binutils/sysinfo+0x4c6cf3)
#     #1 0x4fa313 in yylex /examples/binutils-2.24/build-clang-asan/binutils/syslex.l:55:13
#     #2 0x4f691d in yyparse /examples/binutils-2.24/build-clang-asan/binutils/sysinfo.c:1288:16
#     #3 0x4f9859 in main /examples/binutils-2.24/build-clang-asan/binutils/sysinfo.y:420:3
#     #4 0x7f4b16df8ea2 in __libc_start_main (/lib/x86_64-linux-gnu/libc.so.6+0x26ea2)
#
# SUMMARY: AddressSanitizer: 7123 byte(s) leaked in 755 allocation(s).
RUN cd /examples/binutils-2.24/ && mkdir build-clang-asan && cd build-clang-asan && mkdir afl_in && \
	CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS='-fsanitize=address' ../configure && \
	CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make

# Now also build AFL-ASAN
RUN cd /examples/binutils-2.24/ && mkdir build-afl-asan && cd build-afl-asan && mkdir afl_in && \
	AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS='-fsanitize=address' ../configure && \
	AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make

COPY examples/ /examples/

