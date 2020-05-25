(def frozen {:a 1 :b 2})

# This will be an error since its immutable in janet - silently do nothing in js
(put frozen :c 3)
(pp frozen)

(def notfrozen @{:a 1 :b 2})

(put notfrozen :c 3)
(pp notfrozen)

(def frozelist [1 2])
(array/push frozelist 3)

(def notfrozelist @[1 2])
(array/push notfrozelist 3)
