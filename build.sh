#!/bin/bash
# WARNING: building this Dockerfile can take hours if you want to build all multi-stages, see README

# dangerous commands: only use if you really want to delete all your docker container and images:
# docker rm -f $(docker ps -a -q)
# docker rmi -f $(docker images -q)
# docker volume rm -f $(docker volume ls -qf dangling=true)

# Attention for macOS users: if you rebuild this too often with Docker for macOS, time machine might
# go bananas with its "local time machine backups" which can grow infinitely on disc... even
# when you exclude the docker directory. The following command will delete
# all local backups (you have to decide if you want that!):
# sudo tmutil deletelocalsnapshots $(tmutil listlocalsnapshots / |cut -d "." -f 4-)

# Note: "notes" and "warnings" during the compilation process are ugly but normal (especially dyninst)...

docker build --target afl-base --tag=afl-base . && \
docker build --target afl-jqf --tag=afl-jqf . && \
docker build --target afl-binary-only --tag=afl-binary-only . && \
docker build --target afl-blackbox --tag=afl-blackbox . && \
docker build --target afl-demo --tag=afl-demo . && \
echo "After build succeeds, please test afl-demo by running:" && \
echo "docker run -it --entrypoint=/bin/bash afl-demo" && \
echo "/examples/demo.sh"