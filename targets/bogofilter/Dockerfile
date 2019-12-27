#
# Fuzzing bogofilter
#
# build with:
# docker build --target afl-bogofilter --tag=afl-bogofilter .
# run with:
# docker run -it --entrypoint=/bin/bash afl-bogofilter

# How much memory do we need?
# /tools/recidivm/recidivm -u M /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/
# --> 9

# And with ASAN?
# ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" /tools/recidivm/recidivm -u M /targets/bogofilter-1.2.5/build-afl-asan/src/bogofilter -e -u -p -d ./home_bogofilter/
# --> 20971582

# Do the binaries work?
# /targets/bogofilter-1.2.5/build-clang/src/bogofilter -e -u -p -d ./home_bogofilter/ < /targets/bogofilter-1.2.5/src/tests/inputs/dump.load.inp
# --> vanilla clang works
# /targets/bogofilter-1.2.5/build-clang-asan/src/bogofilter -e -u -p -d ./home_bogofilter/ < /targets/bogofilter-1.2.5/src/tests/inputs/dump.load.inp
# --> ASAN clang works
# /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/ < /targets/bogofilter-1.2.5/src/tests/inputs/dump.load.inp
# gsl: ../../src/../gsl/specfunc/gamma_inc.c:449: ERROR: domain error
# Default GSL error handler invoked.
# Aborted
# --> Oops, why is the AFL build broken? Same for AFL ASAN build. Same when run under afl-showmap.
# We find in gsl: ../../src/../gsl/specfunc/gamma_inc.c:449:
# int gsl_sf_gamma_inc_e(const double a, const double x, gsl_sf_result * result)
# {
#   if(x < 0.0) {
#     DOMAIN_ERROR(result);
#   }
# so what if we do "unset AFL_LLVM_LAF_SPLIT_COMPARES AFL_LLVM_LAF_SPLIT_FLOATS"? It works again. See bug report for AFL++ at https://github.com/vanhauser-thc/AFLplusplus/issues/155


# cd /targets && AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-showmap -m 1000 -o /dev/null -- /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/ < /targets/bogofilter-1.2.5/src/tests/inputs/dump.load.inp

# cd /targets && AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -i /targets/bogofilter-1.2.5/src/tests/inputs -o ./afl_out -M main -- /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/

FROM afl-base AS afl-bogofilter

# From now on compile by default with AFL...
ENV	CC=/afl/afl-clang-fast \
	CXX=/afl/afl-clang-fast++

# afl-clang build first
RUN mkdir /targets && \
	apt-get update && apt-get -y install wget libdb-dev && \
	cd /targets && wget "https://netcologne.dl.sourceforge.net/project/bogofilter/bogofilter-stable/bogofilter-1.2.5.tar.xz" -O bogofilter-1.2.5.tar.xz && tar xf bogofilter-1.2.5.tar.xz && rm bogofilter-1.2.5.tar.xz && cd bogofilter-1.2.5 && \
	echo "fix https://gitlab.com/bogofilter/bogofilter/issues/1 start" && \
	sed -i 's/*clang) gcc4/*clang*) gcc4/g' ./configure && \
	echo "fix end" && \
	echo "fix start" && \
	unset AFL_LLVM_LAF_SPLIT_COMPARES AFL_LLVM_LAF_SPLIT_FLOATS && \
	echo "fix end" && \
	mkdir -p build-afl/afl_in && cd build-afl && CC=afl-clang-fast CXX=afl-clang-fast++ CFLAGS="-Wno-error" ../configure && CFLAGS="-Wno-error" make && cd ..

# regular clang build
RUN cd /targets/bogofilter-1.2.5 && \
	mkdir -p build-clang/afl_in && cd build-clang && CC=clang CXX=clang++ CFLAGS="-Wno-error" ../configure && CFLAGS="-Wno-error" make && cd ..

# A clang ASAN and hardened build to look at crashes later
RUN cd /targets/bogofilter-1.2.5/ && mkdir build-clang-asan && cd build-clang-asan && mkdir afl_in && \
	CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS='-fsanitize=address' ../configure && \
	CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make

# Now also build AFL-ASAN
RUN cd /targets/bogofilter-1.2.5/ && mkdir build-afl-asan && cd build-afl-asan && mkdir afl_in && \
	echo "fix start" && \
	unset AFL_LLVM_LAF_SPLIT_COMPARES AFL_LLVM_LAF_SPLIT_FLOATS && \
	echo "fix end" && \
	AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS='-fsanitize=address' ../configure && \
	AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make



