#!/usr/bin/env janet

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

(defn zipmap [ks vs]
  (if (or (= nil ks)
          (= nil vs))
    {}
    (do
      (def res @{})
      (map (fn [k v]
             (put res k v)) ks vs)
      res)))
(defn zipvec [ks vs]
  (if (or (= nil ks)
          (= nil vs))
    []
    (do
      (def res @[])
      (map (fn [k v]
             (array/push res k)
             (array/push res v)
             ) ks vs)
      res)))
(defn rest [xs] (if (= 0 (length xs)) [] (array/slice xs 1)))
(defn butfirst [xs] (array/slice xs 1))
(defn butlast [xs]
  (let [len (length xs)]
    (array/slice xs 0 (- len 1))))

(defn try-type [x]
  (try
    (type x)
    ([err] :function)))

(defn handle-fn [f args]
  {:call f :args args})

(defn handle-atom [x] x)

(defn walk-form [y]
  (def x (macex y))
  (cond (tuple? x)
        (let [[f] x]
          (if (= :parens (tuple/type x))
            (handle-fn f (map walk-form (rest x)))
            (handle-fn 'tuple (map walk-form x))))

        (array? x)
        (handle-fn 'array (map walk-form x))

        (struct? x)
        (handle-fn 'struct (map walk-form (zipvec (keys x) (values x))))

        (table? x)
        (handle-fn 'table (map walk-form (zipvec (keys x) (values x))))

        :else (handle-atom x)))

(def ast
  (walk-form '(defn foo [] (pp 5))))

(defn symbol-replacements [x]
  (->
   (cond (= '+ x) :plus
         (= '- x) :minus
         (= '/ x) :slash
         (= '* x) :start
         (= '= x) :equal
         (= '< x) :lessthan
         (= '<= x) :lessthanequal
         (= '> x) :greaterthan
         (= '>= x) :greaterthanequal
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
  (def params (if (string/find "tuple(" (get args 0))
                (get args 0)
                (get args 1)))
  #(def params (get args 0))
  (->> params
       (string/replace-all "tuple(" "")
       # FIXME: Incredibly hackish - related to [] -> (tuple)
       #(string/replace-all "tuple," "")
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

(defn do->js [f args]
  (string/format "(() => { %s; return %s})()"
                 (string/join (butlast args) "\n")
                 (string (last args))))

(defn make-if-predicate [args]
  (first args))

(defn make-if-true [args]
  (get args 1))

(defn make-if-false [args]
  (get args 2))

# Use an IIFE ternary to avoid early evaluation of either side
(defn if->js [f args]
  (string/format #"(%s) ? (() => { %s })() : (() => { %s })()"
   "(%s) ? %s : %s"
   (make-if-predicate args)
   (do->js :skip [(get args 1)])
   (do->js :skip [(get args 2)])))

(defn ret->js [f args]
  (string/format "return %s" (string/join args)))

(defn make-method [f args]
  (string/format "%s.%s(%s)"
                 (first args)
                 (symbol-replacements f)
                 (string/join (butfirst args) ",")))

(defn make-call [f args]
  (string/format "%s(%s)" (symbol-replacements f) (string/join args ",")))

(defn make-call-or-method [f args]
  (if (keyword? f)
    (make-method f args)
    (make-call f args)))

(defn make-js-expression [f args]
  (cond
    (= 'def f) (def->js f args)
    (= 'fn f) (fn->js f args)
    (= 'do f) (do->js f args)
    (= 'if f) (if->js f args)
    (= 'ret f) (ret->js f args)
    #:else (string/format "%s(%s)" (symbol-replacements f) (string/join args ","))
    :else (make-call-or-method f args)
    ))

(defn ast->js [ast]
  (cond
    (struct? ast)
    (let [expanded-args (map ast->js (get ast :args))]
      (make-js-expression (get ast :call) expanded-args))

    (string? ast) (string/format "'%s'" ast)

    (number? ast) (string ast)

    (keyword? ast) (string/format "'%s'" (string ast))

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
#(ast->js (walk-form '(do {:a 1 :b 2})))

(defn make-js-old []
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
                            (pp (sum)))))
      #(ast->js (walk-form '(do (def x 3) (pp (+ x 2)))))
      #(ast->js (walk-form '(do (defn three [] (+ 1 2)) (pp (three)))))
      )))
  (pp generated)
  (spit "generated.js" generated))

#(make-js-old)

(defn make-js [form]
  (def generated
    (string
     (->>
      (ast->js (walk-form form))
      )))
  (printf "%s" generated)
  #(spit "generated.js" generated)
  )

(defn get-file-content [s]
  (->> (slurp s)
       # Ensure shorthand for struct is good
       # TODO: We also will need similar for destruct I guess, if its
       # in a let binding (let will be done later, seems tricky)
       # (string/replace-all "@{" "(table ")
       # (string/replace-all "{" "(struct ")
       # (string/replace-all "}" ")")
       # # Ensure we do similar for shorthand
       # (string/replace-all "@[" "(array ")
       # (string/replace-all "[" "(tuple ")
       # (string/replace-all "]" ")")
       ))

(defn parse-file [s]
  (def parser (parser/new))
  # (->> (slurp s)
  #      (map (fn [byte] (parser/byte parser byte))))
  (parser/consume parser (get-file-content s))
  (while (parser/has-more parser)
    (make-js (parser/produce parser))))

#(parse-file "examples/syntaxstruct.janet")

(defn help [this]
  (printf
   ```
Run with:

  %s <cmd> <file1> <file2>...

Where <cmd> is one of:

  help                 - print this message
  generate             - generate Javascript from Janet source
  generate-no-prelude  - generate Javascrpit from Janet source (skip prelude)

and <file1> <file2> is a list of one or more files for transpilation.

The prelude is a set of functions - only use no-prelude if you are including it
via an external include of prelude.js.

Copyright 2020 Matthew Carter <m@ahungry.com>
   ``` this))

(defn gen [args ]
  (def out-buf (buffer/new 1))
  (with-dyns
    [:out out-buf]
    (print (slurp "prelude.js"))
    (map parse-file (butfirst args)))
  (print (string out-buf)))

(defn gen-no-prelude [args ]
  (def out-buf (buffer/new 1))
  (with-dyns
    [:out out-buf]
    (map parse-file (butfirst args)))
  (print (string out-buf)))

(defn main [& args]
  (if (= (length args) 1)
    (help (first args))
    (cond
      (= "generate" (get args 1)) (gen (butfirst args))
      (= "generate-no-prelude" (get args 1)) (gen-no-prelude (butfirst args))
      :else (help (first args)))))
