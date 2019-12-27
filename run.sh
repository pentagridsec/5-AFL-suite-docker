#!/bin/bash

echo "After running the demo container, please run /examples/demo.sh"
docker run -it --entrypoint=/bin/bash afl-demo
