(defmacro my-pp [& xs]
  ~(do
     (pp "in my special macro")
     (pp ;xs)))

(defn expand-str [s]
  (def form (parse s))
  (pp form)
  (string (macex form)))

# (expand-str "(my-pp 3)")

(def peg-form
  '{:id (some (+ (range "09") (range "az") (range "AZ") "-" "_"))
    :arg (* (any :s) :id (any :s))
    #:form (* "(" :id (any (+ :arg :form)) ")")
    :form (capture (* "(" :id (any (+ :s :form :arg)) ")"))
    :main (* (some :form))
    })

#(peg/match peg-form "(outer (middle (inner 1 2 3) (inner-2 4 5 6)))")

(defn parse-file [s]
  (def parser (parser/new))
  # (->> (slurp s)
  #      (map (fn [byte] (parser/byte parser byte))))
  (parser/consume parser (slurp s))
  (pp (parser/produce parser))
  )

#(parse-file "js.janet")

(defn rest [xs] (if (= 0 (length xs)) [] (array/slice xs 1)))

(defn try-type [x]
  (try
    (type x)
    ([err] :function)))

(defn handle-fn [f args]
  {:call f :args args})

(defn handle-atom [x] x)

(defn walk-form [y]
  (def x (macex y))
  (cond (tuple? x) (let [[f] x]
                     (handle-fn f (map walk-form (rest x))))
        :else (handle-atom x)))

(def ast
  (walk-form '(defn foo [] (pp 5))))

(defn symbol-replacements [x]
  (->
   (cond (= '+ x) :plus
         (= '- x) :minus
         (= '/ x) :slash
         (= '* x) :start
         :else x)
   string))

(defn call-replacements [x]
  (cond (number? x) (string x)
        :else (string/format "'%s'" (string (symbol-replacements x)))))

(defn arg-replacements [f args]
  (cond
    # Functions should delay evaluation of args
    (= 'fn f)
    (string/format "() => janet.wrap(%s)" args)

    :else args))

(defn invoke-replacements [f args]
  (cond
    (= 'def f) "const %s = %s"
    :else "janet.call(%s, %s)"))

(defn make-fn-params [args]
  # At this point they are already 'callable' similar to a(b,c)
  # We want to make them a,b,c
  (def params (if (string/find "(" (get args 0))
                (get args 0)
                (get args 1)))
  (->> params
       (string/replace-all "(" ",")
       (string/replace-all ")" "")))

(defn make-fn-body [inargs]
  (def args (if (string/find "(" (get inargs 0))
              inargs
              (array/slice inargs 1)))
  (def len (length args))
  (def last (array/slice args (- len 1) len))
  (string/format "%s; return %s"
                 (string/join (array/slice args 1 (- len 1)) ";")
                 (string/join last)))

(defn def->js [f args]
  (if (= 2 (length args))
    (string/format "const %s = %s;" (get args 0) (get args 1))
    (do
      (string/format "const %s = %s;" (get args 0) (last args)))))

(defn fn->js [f args] (string/format "(%s) => { %s }"
                                     (make-fn-params args)
                                     (make-fn-body args)))

(defn do->js [f args] (string/format "do {\n%s\n} while (false)"
                                     (string/join args "\n")))

(defn make-js-expression [f args]
  (cond
    (= 'def f) (def->js f args)
    (= 'fn f) (fn->js f args)
    (= 'do f) (do->js f args)
    :else (string/format "%s(%s)" (symbol-replacements f) (string/join args ","))))

(defn ast->js [ast]
  (cond
    (struct? ast)
    (let [expanded-args (map ast->js (get ast :args))]
      (make-js-expression (get ast :call) expanded-args))

    (string? ast) (string/format "'%s'" ast)

    (number? ast) (string ast)

    :else (string/format "%s" (string ast))))

#(ast->js (walk-form '(fn [a b c] "Hello")))
#(ast->js (walk-form '(fn haha [a b c] "Hello")))
#(ast->js (walk-form '(defn hooray [a b c] "Hello")))
#(ast->js (walk-form '(pp "Hello")))
#(ast->js (walk-form '(def x "Hello")))
#(ast->js (walk-form '(def fx (fn [] (pp "Hi") (pp "Hello") "Hello"))))
#(ast->js (walk-form '(defn hello [] (pp "Hello") (pp "World"))))
#(ast->js (walk-form '(defn ping [] (pp "pong"))))

#(ast->js (walk-form '(do (def x 3) (def y 4) (defn sum [] (+ x y)) (pp 5 (sum)))))

(defn make-js []
  (def prelude (slurp "prelude.js"))
  (def generated
    (string
     prelude
     (->>
      #(ast->js (walk-form '(defn ping [] (pp "pong"))))
      (ast->js (walk-form '(do
                            (def x 3)
                            (def y 4)
                            (defn sum []
                              (def y 10)
                              (+ x y))
                            (pp (map (fn [n] (+ 1 n)) (tuple 1 2 3)))
                            (pp (sum)))))
      #(ast->js (walk-form '(do (def x 3) (pp (+ x 2)))))
      #(ast->js (walk-form '(do (defn three [] (+ 1 2)) (pp (three)))))
      )))
  (pp generated)
  (spit "generated.js" generated))

(make-js)
