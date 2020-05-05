# 
# Demo section docker multi-stage build
# - Demonstrate how crashes can found with AFL on an old readelf of binutils 2.24
# 

FROM afl-blackbox AS afl-demo

# From now on compile by default with AFL...
ENV	CC=/afl/afl-clang \
	CXX=/afl/afl-clang++

# afl-clang build first
RUN mkdir /examples && \
	cd /examples && curl -L http://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz | tar zxf - && cd binutils-2.24 && \
	mkdir -p build-afl/afl_in && cd build-afl && CC=afl-clang CXX=afl-clang++ CFLAGS="-Wno-error" ../configure && CFLAGS="-Wno-error" make && cd ..
	
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

