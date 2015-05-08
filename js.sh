#!/usr/bin/env bash

set -e

# [[ -f .jsshrc ]] && eval $(cat .jsshrc)

: ${NODE_DIST:=iojs-v1.7.1}
# : ${NODE_DIST:=node-v0.10.38}
# : ${NODE_DIST:=node-v0.12.2}
# : ${NODE_DIST:=iojs-v2.0.2-nightly201505078bf878d6e5}

NODE_TYPE=${NODE_DIST%%-*}
NODE_VER=${NODE_DIST#*-}
NODE_OS=$(uname | tr A-Z a-z)
NODE_DIR="$PWD/vendor/$NODE_TYPE-$NODE_VER-$NODE_OS-x64"
NODE_MODULES_DIR="$PWD/node_modules"

if [[ $# == 0 ]]; then
  echo 'Usage: js.sh node [args]'
  echo '       js.sh npm [args]'
  echo '       js.sh MODULE_CLI [args]'
  echo '       js.sh --bins'
  exit 1
fi

if [[ $1 == '--bins' ]]; then
  echo $NODE_DIR/bin/node
  echo $NODE_DIR/bin/npm
  [[ $NODE_TYPE == iojs ]] && echo $NODE_DIR/bin/iojs
  exit 0
fi

if [[ $NODE_TYPE == iojs ]] && [[ $NODE_VER == *"nightly"* ]]; then
  NODE_URL="https://iojs.org/download/nightly/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
elif [[ $NODE_TYPE == iojs ]]; then
  NODE_URL="https://iojs.org/dist/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
elif [[ $NODE_TYPE == node ]]; then
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
MODULE_CLI_BIN="$NODE_MODULES_DIR/.bin/$1"

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
