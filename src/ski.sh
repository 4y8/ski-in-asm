#!/bin/sh -e

prog=".global _start
.lcomm nodelen, 8
.lcomm nodes,   10000
.lcomm adds,    100000
.lcomm nadds,   8
_start:"
IFS= read -r stack < "$1"
prog="$prog
push \$$(echo "$stack" | sed 's/ /\npush \$/g')"
nodelist=$(sed -n 2p "$1")
set -f
IFS=" "
set -- $nodelist
nodelist=$(printf '%s\n' "$@")
loop=0
for node in "$@"; do
    prog="$prog
movq \$$loop, %r8
movq \$$node, nodes(, %r8, 8)"
    loop=$((loop+1))
done
set +f
prog="$prog
movq \$0, nadds
movq \$$loop, nodelen
call run
mov  %rax, %rdi
mov  \$60, %rax
syscall"
echo "$prog" |
    cat - main.s |
    as - -o a.o
ld a.o
