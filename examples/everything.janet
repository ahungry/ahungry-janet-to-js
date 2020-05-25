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

# Sample JS interop
(pp (-> (:from Buffer "dog") :toString))

# Create a new struct object called Car with two methods, :say and :honk.
(def Car
  (struct :type "Car"
          :color "gray"
          :say (fn [msg] (print "Car says: " msg))
          :honk (fn [self] (print "beep beep! I am " (get self :color) "!"))))

(:honk Car Car) # prints "beep beep! I am gray!"

# Pass more arguments
(:say Car "hello!") # prints "Car says: hello!"

(pp @{:a 1 :b 2})
(pp {:x 1 :y 2})
(pp @[1 2 3])
(pp [4 5 6])
