#!/bin/bash

set -eo pipefail

# Lotus version
lotus_version=v0.7.0

docker build \
    -t aimkiray/lotus:$lotus_version \
    -t aimkiray/lotus:latest \
    --build-arg http_proxy=http://0.0.0.0:8000 \
    --build-arg https_proxy=http://0.0.0.0:8000 \
    .