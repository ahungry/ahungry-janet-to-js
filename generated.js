const pp = console.log
const nil = () => []
const plus = (...args) => args.reduce((a, b) => a + b, 0)
const minus = (...args) => args.reduce((a, b) => a - b, 0)
const star = (...args) => args.reduce((a, b) => a * b, 0)
const slash = (...args) => args.reduce((a, b) => a / b, 0)
const map = (f, xs) => xs.map(f)
const tuple = (...args) => args
const lessthan = (a, b) => a < b
const lessthanequal = (a, b) => a <= b
const greaterthan = (a, b) => a > b
const greaterthanequal = (a, b) => a >= b
do {
const x = 3;
const y = 4;
const sum = (nil,) => { const y = 10;; return plus(x,y) };
pp(map((n,) => { ; return plus(1,n) },tuple(1,2,3)))
const recursive = (n,) => { ; return (lessthan(n,3)) ? ( recursive(plus(1,n)) ) : ( n ) };
pp(recursive(0))
pp(sum())
} while (false)