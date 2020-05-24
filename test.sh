#!/bin/bash

echo Last tested against janet binary 1.9.1-48d31ad
echo

test() {
    echo "Ensuring: $3"
    [[ "$1" == "$2" ]] || echo -e "Received: \n$1 \nExpected:\n$2"
}

./janetscript.janet generate examples/everything.janet > js-out/everything.js
everything=$(node ./js-out/everything.js)
everything_expected=$(cat <<EOF
[ 2, 3, 4 ]
[ 'a', 'b' ]
{ a: 1, b: 2 }
1
3
Hello
World
100
13
dog
EOF
)

test "$everything" "$everything_expected" "golden master regression"

./janetscript.janet generate examples/ex1.janet > js-out/ex1.js
ex1=$(node ./js-out/ex1.js)
ex1_ex=$(cat <<EOF
Greetings from janet
EOF
)
test "$ex1" "$ex1_ex" "trivial test works"

./janetscript.janet generate examples/manyforms.janet > js-out/manyforms.js
ex1=$(node ./js-out/manyforms.js)
ex1_ex=$(cat <<EOF
Hello
Goodbye
EOF
)
test "$ex1" "$ex1_ex" "multiple forms can be parsed from one file"

./janetscript.janet generate examples/jsmethod.janet > js-out/jsmethod.js
ex1=$(node ./js-out/jsmethod.js)
ex1_ex=$(cat <<EOF
dog
EOF
)
test "$ex1" "$ex1_ex" "js-like interop on methods works"

./janetscript.janet generate examples/redcar.janet > js-out/redcar.js
ex1=$(node ./js-out/redcar.js)
ex1_ex=$(cat <<EOF
beep beep! I am gray!
Car says: hello!
EOF
)
test "$ex1" "$ex1_ex" "the janet redcar oop example works"
