FROM busybox:1-glibc
LABEL maintainer "aimkiray@gmail.com"

WORKDIR /

# Certs
COPY certs /etc/ssl/certs

# Required libs
COPY lib/libgcc_s.so.1 /lib/libgcc_s.so.1
COPY lib/libdl-2.27.so /lib/libdl.so.2
COPY lib/libutil-2.27.so /lib/libutil.so.1
COPY lib/librt-2.27.so /lib/librt.so.1
COPY lib/libOpenCL.so.1 /lib/libOpenCL.so.1

# PID1 tini
COPY tini /usr/local/bin/tini

# Lotus bin && entrypoint script
COPY lotus /usr/local/bin/lotus
COPY daemon-entrypoint.sh /usr/local/bin/daemon-entrypoint.sh

# Lotus sync port
EXPOSE 2333

# Lotus home && proofs (optional)
# VOLUME /lotus
# VOLUME /proofs

ENTRYPOINT ["tini", "--", "daemon-entrypoint.sh"]

# Run lotus daemon
CMD ["lotus", "daemon"]