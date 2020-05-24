# Janetscript

A quick POC/effort on transpiling some Janet code to valid Javascript.

*ALPHA QUALITY* (if that)

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
  (pp (sum)))
```

Provides output as expected:

```sh
[ 2, 3, 4 ]
[ ':a', ':b' ]
{ ':a': 1, ':b': 2 }
1
3
13
```

# License

All linked/included works that are not my own are subject to their
original licenses (Janet itself is MIT).

All original works are Copyright 2020 Matthew Carter <m@ahungry.com> and
licensed under GPLv3.
