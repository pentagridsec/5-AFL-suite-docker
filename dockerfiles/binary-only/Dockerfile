# 
# Binary-only (QEMU, unicorn) section docker multi-stage build
# - If you are fuzzing something closed-source but you don't need dyninst-afl, you could use this. However, as a user I would prefer afl-blackbox. But afl-blackbox takes much longer to compile.
# 

FROM afl-base AS afl-binary-only

# binary-only, see AFL++ Makefile plus afl-dyninst
# 
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install libtool-bin wget bison libglib2.0-dev libpixman-1-dev python python-setuptools && \
	cd /afl/ && make binary-only && make install

