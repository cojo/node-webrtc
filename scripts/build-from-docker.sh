#!/bin/bash
set -e
# Below will build the container, but once built you generally don't want to do so again if you're just changing src/...
#docker build --ulimit nofile=122880:122880 --network=host -t node-webrtc/node-webrtc-build:latest .
CONTAINER=$(docker create node-webrtc/node-webrtc-build:latest)

# Copy latest src in
docker cp src/. $CONTAINER:/node-webrtc/src/

# Build latest src
#docker exec -w /node-webrtc $CONTAINER ./node_modules/.bin/ncmake build
echo starting
docker start $CONTAINER
echo waiting
docker wait $CONTAINER
echo stopped

# Copy tarball out
mkdir -p out/
docker cp $CONTAINER:/node-webrtc/build/linux-x64.tar.gz out/

docker rm $CONTAINER
echo "Done. You can find the generated files in the out/ directory."