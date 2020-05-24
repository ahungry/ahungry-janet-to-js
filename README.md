# Janetscript

A quick POC/effort on transpiling some Janet code to valid Javascript.

Find out more about Janet at https://janet-lang.org

*ALPHA QUALITY* (if that)

# Notable TODO

- Support shorthand for struct/table/tuple/array syntax
- Flush out support for the Janet stdlib/BIF

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
```

# License

All linked/included works that are not my own are subject to their
original licenses (Janet itself is MIT).

All original works are Copyright 2020 Matthew Carter <m@ahungry.com> and
licensed under GPLv3.
