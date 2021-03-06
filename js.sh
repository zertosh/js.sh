#!/usr/bin/env bash

: ${NODE_VERSION:=v10.8.0}

set -e

if [[ $# == 0 ]]; then
  echo 'usage: js.sh [--node-bin] [--npm-bin] [--clean] [--env]'
  echo '       js.sh [node|npm|MODULE_BIN] [args...]'
  exit 1
fi

node_os=$(uname | tr A-Z a-z)
node_name="node-$NODE_VERSION-$node_os-x64"
node_dir="vendor/$node_name"

optnum=$#
while [ $# -gt 0 ]; do
  case "$1" in
    --node-bin)
      echo "$node_dir/bin/node"
      shift
      ;;
    --npm-bin)
      echo "$node_dir/bin/npm"
      shift
      ;;
    --env)
      echo "export PATH=\"$PWD/$node_dir/bin:\$PATH\""
      echo "export NODE_PATH=\"$PWD/$node_dir/lib/node_modules\""
      shift
      ;;
    --clean)
      if [[ -d "vendor" ]]; then
        find "vendor" \
          -maxdepth 1 \
          -type d \
          -name 'node-v*' \
          -exec sh -c 'echo "js.sh: Removing {}" 1>&2; rm -rf "{}"' \;
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

[[ $# == 0 ]] && exit 0
[[ $# != $optnum ]] && exit 0

if [[ ! -e "$node_dir/bin/node" ]] || [[ ! -e "$node_dir/bin/npm" ]]; then
  case $NODE_VERSION in
    *"-nightly"*) channel="nightly";;
    *"-rc"*)      channel="rc";;
    *)            channel="release";;
  esac
  node_url="https://nodejs.org/download/$channel/$NODE_VERSION/$node_name.tar.xz"
  echo "js.sh: Downloading $node_url ..." 1>&2
  mkdir -p vendor
  curl $node_url | tar -x -C vendor
fi

export PATH="$PWD/$node_dir/bin:$PATH"
export NODE_PATH="$PWD/$node_dir/lib/node_modules"

node_cmd_bin="$node_dir/bin/$1"
module_bin_bin="node_modules/.bin/$1"

if [[ -x "$module_bin_bin" ]]; then
  shift
  echo "js.sh: $node_dir on $module_bin_bin" 1>&2
  exec "$module_bin_bin" "$@"
elif [[ -x "$node_cmd_bin" ]]; then
  shift
  echo "js.sh: $node_cmd_bin" 1>&2
  exec "$node_cmd_bin" "$@"
else
  echo "js.sh: Don't know what \"$1\" is" 1>&2
  exit 1
fi
