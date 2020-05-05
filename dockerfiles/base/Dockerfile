
# 
# AFL++ section docker multi-stage build
# - The base image you always need
# 

FROM ubuntu:20.04 AS afl-base
#means:
#apt-get install llvm-10-dev
#symlink to /usr/bin/llvm-config-?

MAINTAINER Tobias "floyd" Ospelt, Pentagrid AG "https://www.pentagrid.ch"
# Update first
# According to https://docs.docker.com/develop/develop-images/dockerfile_best-practices/ this is not best practice...
#RUN apt-get -y update && apt-get -y upgrade
# Moreover, we do not need to run "apt-get -y autoremove && rm -rf /var/lib/apt/lists/*" or such as the official Ubuntu/Debian images
# do that automatically:
# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
# https://github.com/moby/moby/blob/03e2923e42446dbb830c654d0eec323a0b4ef02a/contrib/mkimage/debootstrap#L82-L105

# See https://github.com/AFLplusplus/AFLplusplus/blob/master/docs/env_variables.txt
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
# automake qemu llvm-10-dev libiberty-dev libboost-all-dev libelf1 libelf-devlibdw-dev libboost-all-dev 
# A lot of them are dependencies of other packages which we don't need to install implicitly
# boost, dwarf and elf utilities will be downloaded and installed by dyninst itself, 
# which is probably the best way rather than rely on the OS provided ones
# General rule is: do an apt-get install in the same RUN as you need it. That allows to
# remove a tool more easily by uncommenting lines and then the image size is smaller
# use llvm-config-?.? for llvm 6.0 and earlier and llvm-config-? for 9.0 and earlier
# AFL++ commit "works for me" as in git reset --hard.
# Before the big code refactoring of AFL++: c124576a4dc00e31ad5cad118098f46eaa29cd17 -> python2.7-dev and python2.7 instead of python 3!
# Right after the big code refactoring of AFL++: a67d86c6e2ca58db81f2ddf6d0a4c837be88271d -> python2.7-dev and python2.7 instead of python 3!
# Just add this before make:
# && git reset --hard d8059cab6b09bf2e29e8b8db3d40567f193310d5 
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential gcc clang git python3.8-dev python3.8 python3-dev vim flex lib32gcc-10-dev gcc-10-plugin-dev gcc-multilib g++-multilib && \
	git clone https://github.com/AFLplusplus/AFLplusplus.git /afl && cd /afl/ && \
	ln -s /usr/bin/llvm-config-?? /usr/bin/llvm-config && \
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

# afl-kit
# This is a very small project and as you will always need to preselect a corpus to use, having an afl-cmin that
# runs faster can be really helpful
RUN git clone https://github.com/kcwu/afl-kit.git /tools/afl-kit


ENV AFL_CC=clang \
	AFL_CXX=clang++ \
	AFL_AS=as

