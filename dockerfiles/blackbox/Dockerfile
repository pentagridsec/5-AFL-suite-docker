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
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install curl cmake && \
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

