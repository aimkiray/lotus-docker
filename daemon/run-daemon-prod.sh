#!/bin/bash

img_name=lotus
lotus_home=/data2/lotus/daemon

docker container rm $img_name -f

mkdir -p $lotus_home
curl -sOL https://raw.githubusercontent.com/aimkiray/lotus-docker/master/daemon/config.toml
cp -f config.toml $lotus_home/config.toml

docker run \
    --name $img_name \
    -p 2333:2333 \
    --ulimit nofile=1048576:1048576 \
    -v $lotus_home:/lotus/daemon \
    -v /data2/proofs/QmQG9NGWDUMb2WbAiGWkhT1WyZzSaYQQZBUgBxSbRXoqTt:/proofs \
    aimkiray/lotus:latest