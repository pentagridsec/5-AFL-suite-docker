#
# JQF section
#
# - As compiling afl-binary-only takes time and disc space (which we can prevent if we build with docker build --target afl-jqf --tag=afl-jqf .)

FROM afl-base AS afl-jqf

ENV AFL_DIR=/afl/

# JQF
# If you get an error like
# [ERROR] Failed to execute goal on project jqf-examples: Could not resolve dependencies for project edu.berkeley.cs.jqf:jqf-examples:jar:1.2-SNAPSHOT: Failed to collect dependencies at org.apache.tika:tika-parsers:jar:1.18 -> org.apache.tika:tika-core:jar:1.18 -> org.apache.sis.core:sis-metadata:jar:0.8: Failed to read artifact descriptor for org.apache.sis.core:sis-metadata:jar:0.8: Could not transfer artifact org.apache.sis:parent:pom:0.8 from/to central (https://repo.maven.apache.org/maven2): /root/.m2/repository/org/apache/sis/parent/0.8/parent-0.8.pom.part (No such file or directory) -> [Help 1]
# just run the build process again. Such errors are rare but might occur. 
# JQF commit "works for me" as in git reset --hard. Add this at the end if you want a specific commit
# && git reset --hard 7d3270f8d69fff928591a874efcf8ee513205eb0
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install maven openjdk-11-jdk-headless && \
	git clone https://github.com/rohanpadhye/jqf.git /jqf && \
	cd /jqf && /jqf/setup.sh
