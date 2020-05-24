#!/bin/bash

test() {
    [[ "$1" == "$2" ]] || echo -e "Received: \n $1 \nExpected:\n $2"
}

./janetscript.janet generate examples/everything.janet > js-out/everything.js
everything=$(node ./js-out/everything.js)
everything_expected=$(cat <<EOF
[ 2, 3, 4 ]
[ ':a', ':b' ]
{ ':a': 1, ':b': 2 }
1
3
Hello
World
100
13
EOF
)

test "$everything" "$everything_expected"

./janetscript.janet generate examples/ex1.janet > js-out/ex1.js
ex1=$(node ./js-out/ex1.js)
ex1_ex=$(cat <<EOF
Greetings from janet
EOF
)
test "$ex1" "$ex1_ex"
