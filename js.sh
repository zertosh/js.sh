#!/usr/bin/env bash

set -e

NODE_DIST_DEFAULT=iojs
# NODE_DIST_DEFAULT=node

NODE_VER_IOJS_DEFAULT=v1.8.1
NODE_VER_NODE_DEFAULT=v0.10.38

: ${NODE_DIST:=$NODE_DIST_DEFAULT}

if [[ -z $NODE_VER ]] && [[ $NODE_DIST = iojs ]]; then
  NODE_VER=$NODE_VER_IOJS_DEFAULT
elif [[ -z $NODE_VER ]] && [[ $NODE_DIST = node ]]; then
  NODE_VER=$NODE_VER_NODE_DEFAULT
fi

if [[ $# == 0 ]]; then
  echo 'Usage: js.sh node [args]'
  echo '       js.sh npm [args]'
  echo '       js.sh MODULE_CLI [args]'
  exit 1
fi

BIN_DIR="$PWD/vendor"

NODE_OS=$(uname | tr A-Z a-z)
NODE_DIR="$BIN_DIR/$NODE_DIST-$NODE_VER-$NODE_OS-x64"

if [[ $NODE_VER == *"nightly"* ]]; then
  NODE_URL="https://iojs.org/download/nightly/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
elif [[ $NODE_DIST == iojs ]]; then
  NODE_URL="https://iojs.org/dist/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
elif [[ $NODE_DIST == node ]]; then
  NODE_URL="https://nodejs.org/dist/$NODE_VER/node-$NODE_VER-$NODE_OS-x64.tar.gz"
fi

if [[ ! -e $NODE_DIR/bin/node ]] || [[ ! -e $NODE_DIR/bin/npm ]]; then
  echo "Downloading $NODE_URL ..." 1>&2
  mkdir -p $NODE_DIR
  curl $NODE_URL | tar -xz -C $NODE_DIR --strip-components=1
fi

export PATH="$NODE_DIR/bin:$PATH"
export NODE_PATH="$NODE_DIR/lib/node_modules"

NODE_CMD_BIN="$NODE_DIR/bin/$1"
MODULE_CLI_BIN="$PWD/node_modules/.bin/$1"

if [[ -x "$MODULE_CLI_BIN" ]]; then
  shift
  echo "Using: ${NODE_DIR/#$HOME/\~} with ${MODULE_CLI_BIN/#$PWD/\.}" 1>&2;
  $MODULE_CLI_BIN $@
elif [[ -x "$NODE_CMD_BIN" ]]; then
  shift
  echo "Using: ${NODE_CMD_BIN/#$HOME/\~}" 1>&2;
  $NODE_CMD_BIN $@
else
  echo "Don't know $1 - what is it?" 1>&2;
  exit 1
fi
