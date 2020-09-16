#!/bin/bash

set -eo pipefail

target=daemon
img_name=lotus-$target
lotus_version=v0.7.0

export proxy=http://127.0.0.1:8000

export http_proxy=$proxy
export https_proxy=$proxy

docker build \
    -t aimkiray/$img_name:$lotus_version \
    -t aimkiray/$img_name:latest \
    --network host \
    -f $target.dockerfile \
    .