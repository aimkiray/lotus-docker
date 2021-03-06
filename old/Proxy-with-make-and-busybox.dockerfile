FROM ubuntu:18.04
LABEL maintainer "aimkiray@gmail.com"

WORKDIR /

RUN apt-get -y update \
    && apt-get -y install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl \
    && apt-get -y upgrade

ENV GO_VERSION=1.15.2

RUN curl -OL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz

RUN curl -sSf https://sh.rustup.rs | sh -s -- -y

ENV lotus_rep=https://github.com/filecoin-project/lotus.git
ENV branch=master
ENV lotus_ver=v0.7.0
ENV rep_dir=lotus

RUN curl -sOL https://github.com/krallin/tini/releases/download/v0.19.0/tini \
    && chmod +x tini \
    && curl -sOL https://raw.githubusercontent.com/aimkiray/lotus-docker/master/daemon-entrypoint.sh \
    && chmod +x daemon-entrypoint.sh

RUN export PATH=$PATH:/usr/local/go/bin:$HOME/.cargo/bin \
    && git clone --depth=1 -b $branch $lotus_rep $rep_dir \
    && cd $rep_dir \
    && git fetch --tags --prune \
    && git checkout tags/$lotus_ver \
    && env RUSTFLAGS='-C target-cpu=native -g' FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 FIL_PROOFS_USE_GPU_TREE_BUILDER=1 FFI_BUILD_FROM_SOURCE=1 make clean && make all

FROM busybox:glibc
LABEL maintainer "aimkiray@gmail.com"

# Required libs
COPY --from=0 /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/libgcc_s.so.1
COPY --from=0 /lib/x86_64-linux-gnu/libdl-2.27.so /lib/libdl.so.2
COPY --from=0 /lib/x86_64-linux-gnu/libutil-2.27.so /lib/libutil.so.1
COPY --from=0 /lib/x86_64-linux-gnu/librt-2.27.so /lib/librt.so.1 
COPY --from=0 /usr/lib/x86_64-linux-gnu/libOpenCL.so.1 /lib/libOpenCL.so.1

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