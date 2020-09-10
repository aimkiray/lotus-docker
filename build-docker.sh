#!/bin/bash

set -eo pipefail

curl -sOL https://github.com/krallin/tini/releases/download/v0.19.0/tini
chmod +x tini

mkdir -p lib

cp /usr/lib/x86_64-linux-gnu/libOpenCL.so.1 lib
cp /lib/x86_64-linux-gnu/libgcc_s.so.1 lib
cp /lib/x86_64-linux-gnu/libdl-2.27.so lib
cp /lib/x86_64-linux-gnu/libutil-2.27.so lib
cp /lib/x86_64-linux-gnu/librt-2.27.so lib

cp -r /etc/ssl/certs .

# Get lotus version
tag=$(./lotus --version | awk '{print $3}' | awk -F+ '{print $1}')

docker build -t aimkiray/lotus:$tag -t aimkiray/lotus:latest .