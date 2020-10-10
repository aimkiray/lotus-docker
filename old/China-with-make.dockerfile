FROM ubuntu:18.04
LABEL maintainer "aimkiray@gmail.com"

WORKDIR /

RUN sed -i 's/archive.ubuntu.com/mirrors.163.com/g' /etc/apt/sources.list \
    && apt-get -y update \
    && apt-get -y install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl \
    && apt-get -y upgrade

ENV GO_VERSION=1.15.2
ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

RUN curl -OL https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

RUN curl -sSf https://sh.rustup.rs | sh -s -- -y

ENV git_url=https://raw.excited.workers.dev/https://github.com
ENV raw_url=https://raw.excited.workers.dev/https://raw.githubusercontent.com
ENV lotus_rep=${git_url}/filecoin-project/lotus.git
ENV branch=master
ENV lotus_ver=v0.7.0
ENV GOPROXY=https://goproxy.cn,direct

ENV tini_url=${git_url}/krallin/tini/releases/download/v0.19.0/tini
ENV entrypoint_url=${raw_url}/aimkiray/lotus-docker/master/daemon-entrypoint.sh

RUN echo "[source.crates-io] \n\
replace-with = 'ustc' \n\n\
[source.ustc] \n\
registry = 'git://mirrors.ustc.edu.cn/crates.io-index'" >> $HOME/.cargo/config \
    && curl -sOL $tini_url \
    && chmod +x tini \
    && curl -sOL $entrypoint_url \
    && chmod +x daemon-entrypoint.sh

RUN export PATH=$PATH:/usr/local/go/bin:$HOME/.cargo/bin \
    && git clone --depth=1 -b $branch $lotus_rep lotus \
    && cd lotus \
    && git fetch --tags --prune \
    && git checkout tags/$lotus_ver \
    && sed -i "s#https://github.com#${git_url}#g" .gitmodules \
    && env RUSTFLAGS='-C target-cpu=native -g' FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 FIL_PROOFS_USE_GPU_TREE_BUILDER=1 FFI_BUILD_FROM_SOURCE=1 make clean && make all

FROM busybox:glibc
LABEL maintainer "aimkiray@gmail.com"

# Certs
COPY --from=0 /etc/ssl/certs /etc/ssl/certs

# Required libs
COPY --from=0 /usr/lib/libdl.so /lib/libdl.so.2
COPY --from=0 /usr/lib/libutil.so /lib/libutil.so.1 
COPY --from=0 /usr/lib/librt.so /lib/librt.so.1
COPY --from=0 /usr/lib/libgcc_s.so.1 /lib/libgcc_s.so.1
COPY --from=0 /usr/lib/libOpenCL.so.1 /lib/libOpenCL.so.1

# PID1 tini
COPY --from=0 /tini /usr/local/bin/tini

# Lotus bin && entrypoint script
COPY --from=0 /lotus/lotus /usr/local/bin/lotus
COPY --from=0 /daemon-entrypoint.sh /usr/local/bin/daemon-entrypoint.sh

# Lotus sync port
EXPOSE 2333

# Lotus home && proofs (optional)
# VOLUME /lotus
# VOLUME /proofs

ENTRYPOINT ["tini", "--", "daemon-entrypoint.sh"]

# Run lotus daemon
CMD ["lotus", "daemon"]