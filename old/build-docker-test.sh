#!/bin/bash

set -eo pipefail

# Lotus version
lotus_version=v0.7.0

docker build \
    -t aimkiray/lotus:$lotus_version \
    -t aimkiray/lotus:latest \
    --build-arg http_proxy=http://127.0.0.1:8000 \
    --build-arg https_proxy=http://127.0.0.1:8000 \
    .

docker build \
    -t aimkiray/lotus:$lotus_version \
    -t aimkiray/lotus:latest \
    --build-arg http_proxy=socks5://192.168.0.9:23333 \
    --build-arg https_proxy=socks5://192.168.0.9:23333 \
    .

[Service]
Environment="HTTP_PROXY=http://192.168.0.8:8000"
Environment="HTTPS_PROXY=http://192.168.0.8:8000"

[Service]
Environment="HTTP_PROXY=http://127.0.0.1:8000"
Environment="HTTPS_PROXY=http://127.0.0.1:8000"

[Service]
Environment="HTTP_PROXY=socks5://192.168.0.9:23333"
Environment="HTTPS_PROXY=socks5://192.168.0.9:23333"

systemctl daemon-reload
systemctl restart docker