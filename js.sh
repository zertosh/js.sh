#!/usr/bin/env bash

set -e

# [[ -f .jsshrc ]] && eval $(cat .jsshrc)

: ${NODE_ENV:=development}

: ${NODE_DIST:=iojs-v2.2.1}
# : ${NODE_DIST:=node-v0.10.38}
# : ${NODE_DIST:=node-v0.12.4}
# : ${NODE_DIST:=iojs-v2.2.2-nightly201506116e4d30286d}

NODE_TYPE=${NODE_DIST%%-*}
NODE_VER=${NODE_DIST#*-}
NODE_OS=$(uname | tr A-Z a-z)
NODE_DIR="vendor/$NODE_TYPE-$NODE_VER-$NODE_OS-x64"

if [[ $# == 0 ]]; then
  echo 'Usage: js.sh node [args]'
  echo '       js.sh npm [args]'
  echo '       js.sh MODULE_CLI [args]'
  echo '       js.sh --bins'
  exit 1
fi

case "$1" in
  --node-bin)
    echo $NODE_DIR/bin/node; exit 0;;
  --iojs-bin)
    echo $NODE_DIR/bin/iojs; exit 0;;
  --npm-bin)
    echo $NODE_DIR/bin/npm; exit 0;;
  --bins)
    echo $NODE_DIR/bin/node
    [[ $NODE_TYPE == iojs ]] && echo $NODE_DIR/bin/iojs
    echo $NODE_DIR/bin/npm
    exit 0
    ;;
esac

if [[ ! -e $NODE_DIR/bin/node ]] || [[ ! -e $NODE_DIR/bin/npm ]]; then
  if [[ $NODE_TYPE == iojs ]] && [[ $NODE_VER == *"nightly"* ]]; then
    NODE_URL="https://iojs.org/download/nightly/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
  elif [[ $NODE_TYPE == iojs ]]; then
    NODE_URL="https://iojs.org/dist/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
  elif [[ $NODE_TYPE == node ]]; then
    NODE_URL="https://nodejs.org/dist/$NODE_VER/node-$NODE_VER-$NODE_OS-x64.tar.gz"
  fi
  echo "Downloading $NODE_URL ..." 1>&2
  mkdir -p $NODE_DIR
  curl $NODE_URL | tar -xz -C $NODE_DIR --strip-components=1
fi

export PATH="$PWD/$NODE_DIR/bin:$PATH"
export NODE_PATH="$PWD/$NODE_DIR/lib/node_modules"
export NODE_ENV=$NODE_ENV

NODE_CMD_BIN="$NODE_DIR/bin/$1"
MODULE_CLI_BIN="node_modules/.bin/$1"

if [[ -x "$MODULE_CLI_BIN" ]]; then
  shift
  echo "Using: $NODE_DIR with $MODULE_CLI_BIN" 1>&2;
  $MODULE_CLI_BIN $@
elif [[ -x "$NODE_CMD_BIN" ]]; then
  shift
  echo "Using: $NODE_CMD_BIN" 1>&2;
  $NODE_CMD_BIN $@
else
  echo "Don't know $1 - what is it?" 1>&2;
  exit 1
fi
