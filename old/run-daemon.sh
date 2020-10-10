#!/bin/bash

container_name=lotus

docker container rm $container_name -f

docker run -d \
    --name $container_name \
    -p 2333:2333 \
    -v /data2/lotus:/lotus \
    -v /data2/proofs/QmQG9NGWDUMb2WbAiGWkhT1WyZzSaYQQZBUgBxSbRXoqTt:/proofs \
    aimkiray/lotus:latest start