# Ahungry's Janet to JS Transpiler

A quick POC/effort on transpiling some Janet code to valid Javascript.

Find out more about Janet at https://janet-lang.org

*ALPHA QUALITY* (if that)

# Design Note

Consider this "not designed". I'll hack things on as I need them in
the way I see fit.  It won't be quite JS or quite Janet (more like a
subset of Janet with a sprinkling of JS).

For a more thought out project, perhaps check out:

https://github.com/staab/janet-js

# Notable TODO

- Flush out support for the Janet stdlib/BIF
- try/catch construct
- destructuring

# Caveats/Difference to standard Janet

- Janet OOP construct is slightly different (shorthand for invoking
  methods on a table/struct will *not* pass in the self/object)

# What works so far

```clojure
(do
  (def x 3)
  (def y 4)
  (defn sum []
    (def y 10)
    (+ x y))
  (pp (map (fn [n] (+ 1 n)) (tuple 1 2 3)))
  (pp (keys (struct :a 1
                    :b 2
                    )))
  (pp (struct :a 1 :b 2))
  (pp (-> (struct :x 1 :y 2) (get :x)))
  (defn recursive [n]
    (if (< n 3)
      (recursive (+ 1 n))
      n))
  (pp (recursive 0))
  (pp (if (= 1 1)
        (do (pp "Hello") (pp "World") (identity 100))
        (do (pp "Goodbye") (pp "World") (identity 200))))
  (pp (sum)))

# Sample JS interopt
(pp (-> (:from Buffer "dog") :toString))

# Create a new struct object called Car with two methods, :say and :honk.
(def Car
  (struct :type "Car"
          :color "gray"
          :say (fn [msg] (print "Car says: " msg))
          :honk (fn [] (print "beep beep! I am " (get Car :color) "!"))))

(:honk Car) # prints "beep beep! I am gray!"

# Pass more arguments
(:say Car "hello!") # prints "Car says: hello!"

(pp @{:a 1 :b 2})
(pp {:x 1 :y 2})
(pp @[1 2 3])
(pp [4 5 6])
```

Provides output as expected:

```sh
[ 2, 3, 4 ]
[ ':a', ':b' ]
{ ':a': 1, ':b': 2 }
1
3
Hello
World
100
13
dog
beep beep! I am gray!
Car says: hello!
{ a: 1, b: 2 }
{ x: 1, y: 2 }
[ 1, 2, 3 ]
[ 4, 5, 6 ]
```

# License

All linked/included works that are not my own are subject to their
original licenses (Janet itself is MIT).

All original works are Copyright 2020 Matthew Carter <m@ahungry.com> and
licensed under GPLv3.
