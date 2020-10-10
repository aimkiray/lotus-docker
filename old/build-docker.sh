#!/bin/bash

set -eo pipefail

# Lotus version
lotus_version=v0.7.0

export proxy=http://127.0.0.1:8000

export http_proxy=$proxy
export https_proxy=$proxy

git config --global http.proxy $proxy
git config --global https.proxy $proxy
# export GOPROXY=https://goproxy.cn,direct

docker build \
    -t aimkiray/lotus:$lotus_version \
    -t aimkiray/lotus:latest \
    --network host \
    .