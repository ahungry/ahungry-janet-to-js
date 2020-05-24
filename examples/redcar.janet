# Create a new struct object called Car with two methods, :say and :honk.
(def Car
  (struct :type "Car"
          :color "gray"
          :say (fn [msg] (print "Car says: " msg))
          :honk (fn [] (print "beep beep! I am " (get Car :color) "!"))))

(:honk Car) # prints "beep beep! I am gray!"

# Pass more arguments
(:say Car "hello!") # prints "Car says: hello!"
