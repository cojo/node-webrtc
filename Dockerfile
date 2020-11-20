# Node WebRTC server Docker builder
#
# This Dockerfile creates a container which builds Node-WebRTC as found in the
# current folder, for the Ubuntu 18 OS (corresponding to Heroku's default Cedar-18 stack)
#
# Build using `docker build --ulimit nofile=122880:122880 --network=host -t node-webrtc/node-webrtc-build:latest .`
# Then see build-from-docker.sh (or run it from the root directory of the repo) for more on how to use this image.

FROM ubuntu:18.04

# Update apt cache
RUN apt-get update

# Install base dependencies
RUN apt-get install -y --no-install-recommends \
    vim \
    git \
    curl \
    wget \
    apt-utils \
    ca-certificates \
    python \
    lbzip2 \
    pkg-config \
    software-properties-common \
    gpg-agent \
    libxml2

# Get newer version of node
RUN curl --silent --location https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y \
    build-essential \
    nodejs

# Build CMake (need newer than apt-get)
RUN wget https://github.com/Kitware/CMake/releases/download/v3.19.0/cmake-3.19.0-Linux-x86_64.tar.gz
RUN tar -xzf cmake-3.19.0-Linux-x86_64.tar.gz -C /opt
ENV PATH /opt/cmake-3.19.0-Linux-x86_64/bin:$PATH

# Get Chromium depot tools
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /opt/depot_tools
ENV PATH /opt/depot_tools:$PATH

# Get folder ready with our local copy of the repo
COPY . /node-webrtc
WORKDIR /node-webrtc

# Run the npm install process (including the build)
RUN ls -al
RUN SKIP_DOWNLOAD=true npm install --unsafe-perm
RUN ls -al

# Make tarball for upload
WORKDIR /node-webrtc/build
RUN tar -zcvf linux-x64.tar.gz Release

WORKDIR /node-webrtc
ENTRYPOINT ./node_modules/.bin/ncmake build