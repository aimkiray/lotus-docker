FROM ubuntu:18.04 as builder
LABEL maintainer "aimkiray@gmail.com"

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

RUN mkdir -p /file && cd /file \
    && curl -sOL https://github.com/krallin/tini/releases/download/v0.19.0/tini \
    && chmod +x tini

RUN export PATH=$PATH:/usr/local/go/bin:$HOME/.cargo/bin \
    && git clone --depth=1 -b $branch $lotus_rep $rep_dir \
    && cd $rep_dir \
    && git fetch --tags --prune \
    && git checkout tags/$lotus_ver \
    && env RUSTFLAGS='-C target-cpu=native -g' FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1 FIL_PROOFS_USE_GPU_TREE_BUILDER=1 FFI_BUILD_FROM_SOURCE=1 make clean && make lotus-worker

FROM gcr.io/distroless/base-debian10
LABEL maintainer "aimkiray@gmail.com"

ENV FIL_PROOFS_PARAMETER_CACHE=/proofs
ENV WORKER_PATH=/lotus/lotus-worker
ENV FIL_PROOFS_MAXIMIZE_CACHING=1
ENV FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
ENV TRUST_PARAMS=1
ENV RUST_LOG=Info

# Required libs
COPY --from=builder /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/libgcc_s.so.1
COPY --from=builder /lib/x86_64-linux-gnu/libdl-2.27.so /lib/libdl.so.2
COPY --from=builder /lib/x86_64-linux-gnu/libutil-2.27.so /lib/libutil.so.1
COPY --from=builder /lib/x86_64-linux-gnu/librt-2.27.so /lib/librt.so.1 
COPY --from=builder /usr/lib/x86_64-linux-gnu/libOpenCL.so.1 /lib/libOpenCL.so.1

# PID1 tini
COPY --from=builder /file/tini /usr/local/bin/tini

# Lotus bin & config
COPY --from=builder /lotus/lotus-worker /usr/local/bin/lotus-worker

# Lotus home && proofs (optional)
# VOLUME /lotus
# VOLUME /proofs

# Lotus sync port
EXPOSE 6666

ENTRYPOINT ["tini", "--"]

# Run lotus daemon
CMD ["lotus-worker", "run", "--address", "0.0.0.0:6666"]