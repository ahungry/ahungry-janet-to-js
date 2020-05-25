var identity = x => x
var pp = console.log
var print = (...args) => pp(args.join(''))
var nil = () => []
var plus = (...args) => args.reduce((a, b) => a + b, 0)
var minus = (...args) => args.reduce((a, b) => a - b, 0)
var star = (...args) => args.reduce((a, b) => a * b, 0)
var slash = (...args) => args.reduce((a, b) => a / b, 0)
var map = (f, xs) => xs.map(f)
var array = (...args) => args
var tuple = (...args) => Object.freeze(array.apply(null, args))
var equal = (a, b) => a === b
var lessthan = (a, b) => a < b
var lessthanequal = (a, b) => a <= b
var greaterthan = (a, b) => a > b
var greaterthanequal = (a, b) => a >= b
var keys = (m) => Object.keys(m)
var table = (...args) => {
  var m = {}
  for (let i = 0; i < args.length; i += 2) {
    var k = args[i]
    var v = args[i + 1]
    m[k] = v
  }
  return m
}
var struct = (...args) => {
  return Object.freeze(table.apply(null, args))
}
// Objects just fail silently when this is done, whereas push throws usually.
var array_push = (xs, x) => Object.isFrozen(x) ? x : xs.push(x)
var put = (m, k, v) => Object.isFrozen(m) ? m : m[k] = v
var get = (m, k) => m[k];
