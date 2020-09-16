#!/bin/bash

img_name=lotus-miner
run_dir=/data2/lotus/$img_name

docker container rm $img_name -f

mkdir -p $run_dir
curl -sOL https://raw.githubusercontent.com/aimkiray/lotus-docker/master/$img_name/config.toml

host_ip=$(ip route get 255.255.255.255 | grep -Po '(?<=src )(\d{1,3}.){4}' | xargs)
public_ip=$(curl myip.ipip.net | awk '{print $2}' | awk -F： '{print $2}')

sed -i "s/host_ip/$host_ip/g" config.toml
sed -i "s/public_ip/$public_ip/g" config.toml

mv -f config.toml $run_dir/config.toml

# 注意，JWT_TOKEN 在 daemon 数据目录下的 token 文件
# DAEMON_IP 是 daemon 所在主机的内网 IP
# 使用前请务必替换
docker run -d \
    --name $img_name \
    -p 10086:10086 \
    -p 10010:10010 \
    --ulimit nofile=1048576:1048576 \
    -v $run_dir:/lotus/$img_name \
    -v /data2/proofs/QmQG9NGWDUMb2WbAiGWkhT1WyZzSaYQQZBUgBxSbRXoqTt:/proofs \
    -e FULLNODE_API_INFO="JWT_TOKEN:/ip4/DAEMON_IP/tcp/1234/http" \
    aimkiray/$img_name:latest