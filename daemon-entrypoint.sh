#!/bin/bash
# $0 is a script name
# $1 is command
# $2, $3 etc are passed arguments
# $@ are all arguments

export FIL_PROOFS_PARAMETER_CACHE=/proofs
export LOTUS_PATH=/lotus/daemon
export RUST_LOG=Trace

ulimit -HSn 1048576

case "$1" in
"dev")
  exec lotus daemon
  ;;

"start")
  sed -i 's/\#  ListenAddress = "\/ip4\/127.0.0.1\/tcp\/1234\/http"/ListenAddress = "\/ip4\/0.0.0.0\/tcp\/1234\/http"/g' $LOTUS_PATH/config.toml
  export RUST_LOG=Info
  exec lotus daemon
  ;;

*)
  # Run custom command
  exec $@
  ;;
esac
