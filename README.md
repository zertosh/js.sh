# js.sh

Use a specific version node in the current directory.

## install

```sh
# install globally
npm install -g js.sh
```

```sh
# local download
curl -LO "https://github.com/zertosh/js.sh/raw/master/js.sh" && chmod +x js.sh
```

## defaults

```sh
$NODE_VERSION=v6.0.0
```

## usage

`js.sh` will look in `$PWD/vendor` for a node installation that matches `NODE_VERSION`. If it isn't there, it'll download it and continue running your command. The command will run with a `PATH` and `NODE_PATH` set to the local node.

```sh
# jump into the REPL
js.sh node

# run "npm install"
js.sh npm install

# run "npm install" with a particular version of node
NODE_VERSION=v5.11.0 js.sh npm install

# run a local CLI package (node_modules/.bin)
js.sh browserify app/main.js > public/built.js

# run a nightly node
NODE_VERSION=v6.0.0-nightly201604227940ecfa00 js.sh node

# update npm and then use it
js.sh npm install npm
js.sh npm
```

## credit

Thank you [@tomcz](https://github.com/tomcz)!
