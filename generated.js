const pp = console.log
const nil = () => []
const plus = (...args) => args.reduce((a, b) => a + b, 0)
const minus = (...args) => args.reduce((a, b) => a - b, 0)
const star = (...args) => args.reduce((a, b) => a * b, 0)
const slash = (...args) => args.reduce((a, b) => a / b, 0)
const map = (f, xs) => xs.map(f)
const tuple = (...args) => args
do {
const x = 3;
const y = 4;
const sum = (nil,) => { const y = 10;; return plus(x,y) };
pp(map((n,) => { ; return plus(1,n) },tuple(1,2,3)))
pp(sum())
} while (false)