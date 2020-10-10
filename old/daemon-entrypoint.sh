#!/bin/sh

export FIL_PROOFS_PARAMETER_CACHE=/proofs
export LOTUS_PATH=/lotus/daemon
export RUST_LOG=Trace

ulimit -HSn 1048576

case "$1" in
"dev")
  exec lotus daemon
  ;;

"start")
  # Customize lotus listen address and port
  sed -i 's/\#  ListenAddress = "\/ip4\/127.0.0.1\/tcp\/1234\/http"/ListenAddress = "\/ip4\/0.0.0.0\/tcp\/1234\/http"/g' $LOTUS_PATH/config.toml
  export RUST_LOG=Info
  exec lotus daemon
  ;;

*)
  exec $@
  ;;
esac
