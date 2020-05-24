const identity = x => x
const pp = console.log
const nil = () => []
const plus = (...args) => args.reduce((a, b) => a + b, 0)
const minus = (...args) => args.reduce((a, b) => a - b, 0)
const star = (...args) => args.reduce((a, b) => a * b, 0)
const slash = (...args) => args.reduce((a, b) => a / b, 0)
const map = (f, xs) => xs.map(f)
const tuple = (...args) => args
const equal = (a, b) => a === b
const lessthan = (a, b) => a < b
const lessthanequal = (a, b) => a <= b
const greaterthan = (a, b) => a > b
const greaterthanequal = (a, b) => a >= b
const keys = (m) => Object.keys(m)
const struct = (...args) => {
  const m = {}
  for (let i = 0; i < args.length; i += 2) {
    const k = args[i]
    const v = args[i + 1]
    m[k] = v
  }
  return Object.freeze(m)
}
const get = (m, k) => m[k];
(() => { const x = 3;
const y = 4;
const sum = (nil,) => { const y = 10;; return plus(x,y) };
pp(map((n,) => { ; return plus(1,n) },tuple(1,2,3)))
pp(keys(struct(':a',1,':b',2)))
pp(struct(':a',1,':b',2))
pp(get(struct(':x',1,':y',2),':x'))
const recursive = (n,) => { ; return (lessthan(n,3)) ? (() => { ; return recursive(plus(1,n))})() : (() => { ; return n})() };
pp(recursive(0))
pp((equal(1,1)) ? (() => { ; return (() => { pp('Hello')
pp('World'); return identity(100)})()})() : (() => { ; return (() => { pp('Goodbye')
pp('World'); return identity(200)})()})()); return pp(sum())})()