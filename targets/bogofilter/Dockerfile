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
# --> afl-clang works
# /targets/bogofilter-1.2.5/build-afl-asan/src/bogofilter -e -u -p -d ./home_bogofilter/ < /targets/bogofilter-1.2.5/src/tests/inputs/dump.load.inp
# --> ASAN afl-clang works

# Does running with afl-showmap and libdislocator work?
# cd /targets && AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-showmap -m 1000 -o /dev/null -- /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/ < /targets/bogofilter-1.2.5/src/tests/inputs/dump.load.inp

# This is how messy run tactics might be...
# afl-fuzz -i /targets/bogofilter-1.2.5/src/tests/inputs/ -o ./afl_out -M main -- /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/
# AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -i ./afl_out/main/queue/ -o ./afl_out2 -S havoc -t 100+ -- /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/
# afl-fuzz -i ./afl_out2/havoc/queue/ -o ./afl_out3 -S havoc -t 100+ -m 21971582 -- /targets/bogofilter-1.2.5/build-afl-asan/src/bogofilter -e -u -p -d ./home_bogofilter/




# cd /targets && AFL_PRELOAD=/usr/local/lib/afl/libdislocator.so afl-fuzz -i /targets/bogofilter-1.2.5/src/tests/inputs -o ./afl_out -M main -- /targets/bogofilter-1.2.5/build-afl/src/bogofilter -e -u -p -d ./home_bogofilter/

FROM pentagrid/afl-base AS afl-bogofilter

# From now on compile by default with AFL...
ENV	CC=/afl/afl-clang \
	CXX=/afl/afl-clang++

# afl-clang build first
RUN mkdir /targets && \
	apt-get update && apt-get -y install wget libdb-dev && \
	cd /targets && wget "https://netcologne.dl.sourceforge.net/project/bogofilter/bogofilter-stable/bogofilter-1.2.5.tar.xz" -O bogofilter-1.2.5.tar.xz && tar xf bogofilter-1.2.5.tar.xz && rm bogofilter-1.2.5.tar.xz && cd bogofilter-1.2.5 && \
	echo "fix https://gitlab.com/bogofilter/bogofilter/issues/1 start" && \
	sed -i 's/*clang) gcc4/*clang*) gcc4/g' ./configure && \
	echo "fix end" && \
	mkdir -p build-afl/afl_in && cd build-afl && CC=afl-clang CXX=afl-clang++ CFLAGS="-Wno-error" ../configure && CFLAGS="-Wno-error" make && cd ..

# regular clang build
RUN cd /targets/bogofilter-1.2.5 && \
	mkdir -p build-clang/afl_in && cd build-clang && CC=clang CXX=clang++ CFLAGS="-Wno-error" ../configure && CFLAGS="-Wno-error" make && cd ..

# A clang ASAN and hardened build to look at crashes later
RUN cd /targets/bogofilter-1.2.5/ && mkdir build-clang-asan && cd build-clang-asan && mkdir afl_in && \
	CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS='-fsanitize=address' ../configure && \
	CC=clang CXX=clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make

# Now also build AFL-ASAN
RUN cd /targets/bogofilter-1.2.5/ && mkdir build-afl-asan && cd build-afl-asan && mkdir afl_in && \
	AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" LDFLAGS='-fsanitize=address' ../configure && \
	AFL_USE_ASAN=1 CC=afl-clang CXX=afl-clang++ ASAN_OPTIONS="abort_on_error=1:detect_leaks=0:symbolize=0:allocator_may_return_null=1" CFLAGS="-Wno-error -fsanitize=address" make

COPY corpus/ /targets/corpus

