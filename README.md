# js.sh

Use a specific version node or iojs in the current directory.

## install globally

```sh
npm install -g js.sh
```

## current defaults

```sh
NODE_DIST=iojs
```

```sh
# iojs
NODE_VER=v1.8.1
# node
NODE_VER=v0.10.38
```

## usage

`js.sh` will look in the current directory under `vendor` for node and npm. If the desired version isn't there, it'll download it and continue running your command.


```sh
# Jump into the REPL
js.sh node

# Run "npm install"
js.sh npm install

# Run "npm install" with a particular version of node
NODE_DIST=node NODE_VER=v0.12.2 js.sh npm install

# Run a local CLI package (node_modules/.bin)
js.sh browserify app/main.js > public/built.js

# Run a nightly iojs
NODE_VER=v2.0.0-nightly2015050366877216bd js.sh node

# Update npm and then use it
js.sh npm install npm
js.sh npm
```

## Notes

Thank you [@tomcz](https://github.com/tomcz)!
