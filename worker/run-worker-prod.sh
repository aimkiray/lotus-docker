#!/bin/bash

img_name=lotus-worker
run_dir=/data2/lotus/$img_name

docker container rm $img_name -f

host_ip=$(ip route get 255.255.255.255 | grep -Po '(?<=src )(\d{1,3}.){4}' | xargs)


mv -f config.toml $run_dir/config.toml

# 注意，JWT_TOKEN 在 miner 数据目录下的 token 文件
# MINER_IP 是 miner 所在主机的内网 IP
# 使用前请务必替换
docker run \
    --name $img_name \
    -p 6666:6666 \
    --ulimit nofile=1048576:1048576 \
    -v $run_dir:/lotus/$img_name \
    -v /data2/proofs/QmQG9NGWDUMb2WbAiGWkhT1WyZzSaYQQZBUgBxSbRXoqTt:/proofs \
    -e MINER_API_INFO="JWT_TOKEN:/ip4/MINER_IP/tcp/2345/http" \
    aimkiray/$img_name:latest