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
const get = (m, k) => m[k]
