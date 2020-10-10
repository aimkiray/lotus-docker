FROM busybox:glibc

RUN curl -sOL https://raw.githubusercontent.com/aimkiray/lotus-docker/master/daemon/config.toml

COPY config.toml /lotus/daemon