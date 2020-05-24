var identity = x => x
var pp = console.log
var nil = () => []
var plus = (...args) => args.reduce((a, b) => a + b, 0)
var minus = (...args) => args.reduce((a, b) => a - b, 0)
var star = (...args) => args.reduce((a, b) => a * b, 0)
var slash = (...args) => args.reduce((a, b) => a / b, 0)
var map = (f, xs) => xs.map(f)
var tuple = (...args) => args
var equal = (a, b) => a === b
var lessthan = (a, b) => a < b
var lessthanequal = (a, b) => a <= b
var greaterthan = (a, b) => a > b
var greaterthanequal = (a, b) => a >= b
var keys = (m) => Object.keys(m)
var struct = (...args) => {
  var m = {}
  for (let i = 0; i < args.length; i += 2) {
    var k = args[i]
    var v = args[i + 1]
    m[k] = v
  }
  return Object.freeze(m)
}
var get = (m, k) => m[k];
