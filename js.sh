#!/usr/bin/env bash

set -e

: ${NODE_VERSION:=v5.3.0}
# : ${NODE_VERSION:=v4.2.3}
# : ${NODE_VERSION:=v4.1.1}
# : ${NODE_VERSION:=v5.0.0-rc.2}
# : ${NODE_VERSION:=v5.0.1-nightly201510294e54dbec51}

: ${NODE_ENV:=development}

NODE_OS=$(uname | tr A-Z a-z)
NODE_DIR="vendor/node-$NODE_VERSION-$NODE_OS-x64"

if [[ $# == 0 ]]; then
  echo 'usage: js.sh [--node-bin] [--npm-bin] [--clean] [--env]'
  echo '       js.sh [--clean] [node|npm|MODULE_CLI] [args...]'
  exit 1
fi

while test $# -gt 0; do
  case "$1" in
    --node-bin) echo $NODE_DIR/bin/node; shift;;
    --npm-bin)  echo $NODE_DIR/bin/npm; shift;;
    --clean)
      if [[ -d 'vendor' ]]; then
        find 'vendor' -maxdepth 1 -type d -name 'node-v*' \
          -exec sh -c 'echo "js.sh: Removing {}" 1>&2; rm -rf "{}"' \;
      fi
      shift
      ;;
    --env)
      if [[ $PATH != $PWD/$NODE_DIR/bin:* ]]; then
        echo "export PATH=\"$PWD/$NODE_DIR/bin:\$PATH\""
        echo "export NODE_PATH=\"$PWD/$NODE_DIR/lib/node_modules\""
        echo "export NODE_ENV=$NODE_ENV"
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

[[ $# == 0 ]] && exit 0

if [[ ! -e $NODE_DIR/bin/node ]] || [[ ! -e $NODE_DIR/bin/npm ]]; then
  case $NODE_VERSION in
    *"-nightly"*) CHANNEL="nightly";;
    *"-rc"*)      CHANNEL="rc";;
    *)            CHANNEL="release";;
  esac
  NODE_URL="https://nodejs.org/download/$CHANNEL/$NODE_VERSION/node-$NODE_VERSION-$NODE_OS-x64.tar.xz"
  echo "js.sh: Downloading $NODE_URL ..." 1>&2
  mkdir -p $NODE_DIR
  curl $NODE_URL | tar -x -C $NODE_DIR --strip-components=1
fi

export PATH="$PWD/$NODE_DIR/bin:$PATH"
export NODE_PATH="$PWD/$NODE_DIR/lib/node_modules"
export NODE_ENV="$NODE_ENV"

NODE_CMD_BIN="$NODE_DIR/bin/$1"
MODULE_CLI_BIN="node_modules/.bin/$1"

if [[ -x "$MODULE_CLI_BIN" ]]; then
  shift
  echo "js.sh: NODE_ENV=\"$NODE_ENV\" $NODE_DIR on $MODULE_CLI_BIN" 1>&2
  $MODULE_CLI_BIN $@
elif [[ -x "$NODE_CMD_BIN" ]]; then
  shift
  echo "js.sh: NODE_ENV=\"$NODE_ENV\" $NODE_CMD_BIN" 1>&2
  $NODE_CMD_BIN $@
else
  echo "js.sh: Don't know what \"$1\" is" 1>&2
  exit 1
fi
