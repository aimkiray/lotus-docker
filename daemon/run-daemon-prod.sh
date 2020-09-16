#!/bin/bash

img_name=lotus-daemon
run_dir=/data2/lotus/$img_name

docker container rm $img_name -f

mkdir -p $run_dir
curl -sOL https://raw.githubusercontent.com/aimkiray/lotus-docker/master/$img_name/config.toml

host_ip=$(ip route get 255.255.255.255 | grep -Po '(?<=src )(\d{1,3}.){4}' | xargs)

sed -i "s/host_ip/$host_ip/g" config.toml

mv -f config.toml $run_dir/config.toml

docker run \
    --name $img_name \
    -p 2333:2333 \
    --ulimit nofile=1048576:1048576 \
    -v $run_dir:/lotus/$img_name \
    -v /data2/proofs/QmQG9NGWDUMb2WbAiGWkhT1WyZzSaYQQZBUgBxSbRXoqTt:/proofs \
    aimkiray/$img_name:latest