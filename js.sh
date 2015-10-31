#!/usr/bin/env bash

set -e

# [[ -f .jsshrc ]] && eval $(cat .jsshrc)

: ${NODE_DIST:=node-v5.0.0}
# : ${NODE_DIST:=node-v4.2.1}

: ${NODE_ENV:=development}

NODE_TYPE=${NODE_DIST%%-*}
NODE_VER=${NODE_DIST#*-}
NODE_OS=$(uname | tr A-Z a-z)
NODE_DIR="vendor/$NODE_TYPE-$NODE_VER-$NODE_OS-x64"

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
  NODE_URL="https://nodejs.org/dist/$NODE_VER/$NODE_TYPE-$NODE_VER-$NODE_OS-x64.tar.gz"
  echo "js.sh: Downloading $NODE_URL ..." 1>&2
  mkdir -p $NODE_DIR
  curl $NODE_URL | tar -xz -C $NODE_DIR --strip-components=1
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
