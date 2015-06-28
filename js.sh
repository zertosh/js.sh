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
  echo 'usage: js.sh [--node-bin] [--iojs-bin] [--npm-bin] [--clean]'
  echo '       js.sh [--clean] [node|npm|MODULE_CLI] [args...]'
  exit 1
fi

while test $# -gt 0; do
  case "$1" in
    --node-bin) echo $NODE_DIR/bin/node; shift;;
    --iojs-bin) echo $NODE_DIR/bin/iojs; shift;;
    --npm-bin)  echo $NODE_DIR/bin/npm; shift;;
    --clean)
      find vendor -maxdepth 1 \( -name "iojs-v*" -o -name "node-v*" \) \
        -exec sh -c 'echo "js.sh: Removing {}" 1>&2; rm -rf "{}"' \;
      shift
      ;;
    *)
      break
      ;;
  esac
done

[[ $# == 0 ]] && exit 0

if [[ ! -e $NODE_DIR/bin/node ]] || [[ ! -e $NODE_DIR/bin/npm ]]; then
  if [[ $NODE_TYPE == iojs ]] && [[ $NODE_VER == *"nightly"* ]]; then
    NODE_URL="https://iojs.org/download/nightly/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
  elif [[ $NODE_TYPE == iojs ]]; then
    NODE_URL="https://iojs.org/dist/$NODE_VER/iojs-$NODE_VER-$NODE_OS-x64.tar.gz"
  elif [[ $NODE_TYPE == node ]]; then
    NODE_URL="https://nodejs.org/dist/$NODE_VER/node-$NODE_VER-$NODE_OS-x64.tar.gz"
  fi
  echo "js.sh: Downloading $NODE_URL ..." 1>&2
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
