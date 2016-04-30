#!/usr/bin/env bash

: ${node_version:=v6.0.0}
# : ${node_version:=v5.11.0}
# : ${node_version:=v4.4.3}
# : ${node_version:=v6.0.0-rc.4}
# : ${node_version:=v6.0.0-nightly201604227940ecfa00}

set -e

if [[ $# == 0 ]]; then
  echo 'usage: js.sh [--node-bin] [--npm-bin] [--clean] [--env]'
  echo '       js.sh [node|npm|MODULE_BIN] [args...]'
  exit 1
fi

node_os=$(uname | tr A-Z a-z)
node_dir="vendor/node-$node_version-$node_os-x64"

optnum=$#
while [ $# -gt 0 ]; do
  case "$1" in
    --node-bin)
      echo $node_dir/bin/node
      shift
      ;;
    --npm-bin)
      echo $node_dir/bin/npm
      shift
      ;;
    --env)
      echo "export PATH=\"$PWD/$node_dir/bin:\$PATH\""
      echo "export NODE_PATH=\"$PWD/$node_dir/lib/node_modules\""
      shift
      ;;
    --clean)
      if [[ -d 'vendor' ]]; then
        find 'vendor' -maxdepth 1 -type d -name 'node-v*' \
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

if [[ ! -e $node_dir/bin/node ]] || [[ ! -e $node_dir/bin/npm ]]; then
  case $node_version in
    *"-nightly"*) channel="nightly";;
    *"-rc"*)      channel="rc";;
    *)            channel="release";;
  esac
  node_url="https://nodejs.org/download/$channel/$node_version/node-$node_version-$node_os-x64.tar.xz"
  echo "js.sh: Downloading $node_url ..." 1>&2
  mkdir -p $node_dir
  curl $node_url | tar -x -C $node_dir --strip-components=1
fi

export PATH="$PWD/$node_dir/bin:$PATH"
export NODE_PATH="$PWD/$node_dir/lib/node_modules"

node_cmd_bin="$node_dir/bin/$1"
module_cli_bin="node_modules/.bin/$1"

if [[ -x "$module_cli_bin" ]]; then
  shift
  echo "js.sh: $node_dir on $module_cli_bin" 1>&2
  exec "$module_cli_bin" "$@"
elif [[ -x "$node_cmd_bin" ]]; then
  shift
  echo "js.sh: $node_cmd_bin" 1>&2
  exec "$node_cmd_bin" "$@"
else
  echo "js.sh: Don't know what \"$1\" is" 1>&2
  exit 1
fi
