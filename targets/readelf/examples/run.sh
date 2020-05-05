#!/bin/bash

#rm -rf /examples/binutils-2.34/build-*/afl_in/*
#rm -rf /examples/binutils-2.34/build-*/afl_out

echo "# /examples/binutils-2.34/build-clang/binutils/readelf -a /bin/ls | head"
/examples/binutils-2.34/build-clang/binutils/readelf -a /bin/ls | head

# With libdislocator
echo "# cd /examples/binutils-2.34/build-afl/"
cd /examples/binutils-2.34/build-afl/ 
echo "# cp /afl/testcases/others/elf/small_exec.elf afl_in/"
cp /afl/testcases/others/elf/small_exec.elf afl_in/
echo "# AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.34/build-afl/binutils/readelf -a @@"
AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.34/build-afl/binutils/readelf -a @@

#echo "# AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-showmap -o /dev/null /examples/binutils-2.34/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*"
#AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-showmap -o /dev/null /examples/binutils-2.34/build-afl/binutils/readelf -a afl_out/main/crashes/id\:000000*

#echo "# /examples/binutils-2.34/build-clang-asan/binutils/readelf -a /examples/binutils-2.34/build-afl/afl_out/main/crashes/id\:000000*"
#/examples/binutils-2.34/build-clang-asan/binutils/readelf -a /examples/binutils-2.34/build-afl/afl_out/main/crashes/id\:000000*


# echo "# cd /examples/binutils-2.34/build-afl-asan/"
# cd /examples/binutils-2.34/build-afl-asan/
# echo "# cp /afl/testcases/others/elf/small_exec.elf afl_in/"
# cp /afl/testcases/others/elf/small_exec.elf afl_in/
# echo "# afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.34/build-afl-asan/binutils/readelf -a @@"
# afl-fuzz -i afl_in -o afl_out -M main /examples/binutils-2.34/build-afl-asan/binutils/readelf -a @@
# read -n 1 -s -r -p $'\033[32mOh no, what was that?! Well, it\'s very well documented in that file AFL points us to... go read it on https://github.com/AFLplusplus/AFLplusplus/blob/master/docs/notes_for_asan.txt ! Always carefully read the output of AFL. It is saying that it crashed and there could be several reasons. The most obvious one is that AFL didn\'t give enough memory to readelf. But how much memory is necessary? We want to keep the value pretty low (close to what it really needs) for performance reasons. Let\'s use recidivm as described in that document. Luckily, recidivm comes preinstalled in the Docker.\n\033[0m';
# echo '# ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" /tools/recidivm/recidivm -u M /examples/binutils-2.34/build-afl-asan/binutils/readelf -a /afl/testcases/others/elf/small_exec.elf'
# ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" /tools/recidivm/recidivm -u M /examples/binutils-2.34/build-afl-asan/binutils/readelf -a /afl/testcases/others/elf/small_exec.elf
#
# ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" afl-fuzz -i afl_in -o afl_out -m 22000000 -M main /examples/binutils-2.34/build-afl-asan/binutils/readelf -a @@

