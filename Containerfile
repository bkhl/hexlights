FROM docker.io/library/alpine:latest as builder

RUN <<HERE
set -xeuo pipefail

apk --no-cache add luajit-dev git make

git clone https://git.sr.ht/~xerool/fennel-ls /fennel-ls
make -C /fennel-ls LUA=luajit

git clone https://git.sr.ht/~technomancy/fnlfmt /fnlfmt
LUA=lua5.3 make -C /fnlfmt LUA=luajit FENNEL="luajit ./fennel"
HERE

FROM docker.io/library/alpine:latest

ENV XDG_DATA_HOME=/usr/local/share

RUN <<HERE
set -xeuo pipefail

apk --no-cache add luajit-dev

mkdir -p "${XDG_DATA_HOME}/fennel-ls/docsets/"
wget "https://p.hagelb.org/docsets/love2d.lua" -O "${XDG_DATA_HOME}/fennel-ls/docsets/love2d.lua"
HERE

COPY --from=builder --chmod=0755 /fennel-ls/fennel-ls /fnlfmt/fnlfmt /usr/local/bin/
