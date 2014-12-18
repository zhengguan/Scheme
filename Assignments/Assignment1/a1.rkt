#lang racket
;;(require "a1-student-tests.rkt")
;;(test-file #:file-name "a1.rkt")

;; 1. Define and test a procedure countdown that takes a natural number and returns a list of the natural numbers less than or equal to that number, in descending order.
;;
;;> (countdown 5)
;;(5 4 3 2 1 0)
;;
(define countdown
  (λ (x)
    (cond
      ((zero? (add1 x)) '())
      (else (cons x (countdown (sub1 x))))
      )))

;;MyOutput
;;> (countdown 4)
;;(4 3 2 1 0)
;;> (countdown 44)
;;(44 43 42 41 40 39 38 37 36 35 34 33 32 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0)
;;> (countdown 5)
;;(5 4 3 2 1 0)

;;2. Define and test a procedure insertR that takes two symbols and a list and returns a new list with the second symbol inserted after each occurrence of the first symbol.
;;
;;> (insertR 'x 'y '(x z z x y x))
;;(x y z z x y y x y)
;;
(define insertR
  (λ (s1 s2 ls)
    (cond
      ((null? ls) '())
      (else 
       (cond
         ((eq? (car ls) s1) (cons (car ls) (cons s2 (insertR s1 s2 (cdr ls)))))
         (else (cons (car ls) (insertR s1 s2 (cdr ls))))
         )))))

;;Myoutput
;;> (insertR 'a 'b '(a b h a y b a j a j))
;;(a b b h a b y b a b j a b j)
;;> (insertR 'x 'y '(x z z x y x))
;;(x y z z x y y x y)


;;3. Define and test a procedure remv-1st that takes a a symbol and a list and returns a new list with the first occurrence of the symbol removed.
;;
;;> (remv-1st 'x '(x y z x))
;;(y z x)
;;> (remv-1st 'y '(x y z y x))
;;(x z y x)
;;
(define remv-1st
  (λ (a ls)
    (cond
      ((null? ls) '())
      ((eq? (car ls) a) (cdr ls))
      (else (cons (car ls) (remv-1st a (cdr ls))))
      )))
;;MyOutput
;;> (remv-1st 'x '(x y z x))
;;(y z x)
;;> (remv-1st 'y '(x y z y x))
;;(x z y x)

;;4. Define and test a procedure occurs-?s that takes a list and returns the number of times the symbol ? occurs in the list.
;;
;;> (occurs-?s '(? y z ? ?))
;;3
;;
(define occurs-?s 
  (λ (ls)
    (cond
      ((null? ls) 0)
      ((eq? (car ls) '?) (add1 (occurs-?s (cdr ls))))
      (else (occurs-?s (cdr ls)))
      )))

;;Myoutput
;;> (occurs-?s '(? y z ? ? f s r t h g ? d e r ? ? f ? f))
;;7
;;> (occurs-?s '())
;;0
;;> (occurs-?s '(?))
;;1

;;5. Define and test a procedure filter that takes a predicate and a list and returns a new list containing the elements that satisfy the predicate. A predicate is a procedure that takes a single argument and returns either #t or #f. The number? predicate, for example, returns #t if its argument is a number and #f otherwise. The argument satisfies the predicate, then, if the predicate returns #t for that argument.
;;
;;> (filter even? '(1 2 3 4 5 6))
;;(2 4 6)
;;
(define filter
  (λ (pred? ls)
    (cond 
      ((null? ls) '())
      (else 
       (cond 
         ((pred? (car ls)) (cons (car ls) (filter pred? (cdr ls))))
         (else  (filter pred? (cdr ls))))
         ))))

;;MyOutput
;;> (filter even? '(1 2 3 4 5 6))
;;(2 4 6)
;;> (filter even? '(0 1 2 3 4 5 6 7 8 101))
;;(0 2 4 6 8)
;;> (filter odd? '(0 1 2 3 4 5 6 7 8 101))
;;(1 3 5 7 101)
;;> (filter null? '(0 1 2 3 4 5 6 7 8 101))
;;()
;;> (filter even? '(0 1 2 3 4 5 6 7 8 101))
;;(0 2 4 6 8)
;;> (filter zero? '())
;;()
;;> (filter zero? '(0 3))
;;(0)
;;> (filter zero? '(3))
;;()



;;6. Define and test a procedure zip that takes two lists of equal length and forms a new list, each element of which is a pair formed by combining the corresponding elements of the two input lists.
;;
;;> (zip '(1 2 3) '(a b c))
;;((1 . a) (2 . b) (3 . c))
;;
(define zip
  (λ (ls1 ls2)
    (cond
      ((or (null? ls1) (null? ls2)) '())
      (else (cons (cons (car ls1) (car ls2)) (zip (cdr ls1) (cdr ls2))))
            )))

;;MyOutput
;;> (zip '(1 2 3) '(a b c))
;;((1 . a) (2 . b) (3 . c))
;;> (zip '() '())
;;()
;;> (zip '() '(2 3 3))
;;()
;;> (zip '(1 2 3) '(2 3 3))
;;((1 . 2) (2 . 3) (3 . 3))
;;> (zip '(1 2 3) '(2 3 3 3))
;;((1 . 2) (2 . 3) (3 . 3))
;;> (zip '(1 2 3) '(2 3 3 4))
;;((1 . 2) (2 . 3) (3 . 3))
;;> (zip '(1 2 3) '(2 3 3 8))
;;((1 . 2) (2 . 3) (3 . 3))
;;> (zip '(1 2 3 8 9) '(2 3 3 8))
;;((1 . 2) (2 . 3) (3 . 3) (8 . 8))


;;7. Define and test a procedure map that takes a procedure p of one argument and a list ls and returns a new list containing the results of applying p to the elements of ls. Do not use Racket's built-in map in your definition.
;;
;;> (map add1 '(1 2 3 4))
;;(2 3 4 5)
;;
(define map
  (λ (proc ls)
    (cond
      ((null? ls) '())
      (else (cons (proc (car ls)) (map proc (cdr ls))))
      )))

;;Myoutput
;;> (map add1 '(1 2 3 4))
;;(2 3 4 5)
;;> (map sub1 '(1 2 3 4))
;;(0 1 2 3)
;;> (map sub1 '(1 2 3 42))
;;(0 1 2 41)
;;> (map sub1 '())
;;()


;;8. Define and test a procedure append that takes two lists, ls1 and ls2, and appends ls1 to ls2.
;;
;;> (append '(a b c) '(1 2 3))
;;(a b c 1 2 3)
;;
(define append
  (λ (ls1 ls2)
    (cond
      ((null? ls1) ls2)
      (else (cons (car ls1) (append (cdr ls1) ls2)))
      )))

;;myoutput
;;> (append '(a b c) '(1 2 3))
;;(a b c 1 2 3)
;;> (append '(a b c) '(1 2 ))
;;(a b c 1 2)
;;> (append '(a b c) '())
;;(a b c)
;;> (append '(a ) '(1))
;;(a 1)
;;> (append '() '(1))
;;(1)
;;> (append '() '())
;;()
;;> (append '(1) '(1313))
;;(1 1313)


;;9. Define and test a procedure reverse that takes a list and returns the reverse of that list.
;;
;;> (reverse '(a 3 x))
;;(x 3 a)
;;
(define reverse
  (λ (ls)
  (cond
    ((null? ls) '())
    (else (append (reverse (cdr ls)) (list (car ls))))
    )))

;;myoutput
;;> (reverse '())
;;()
;;> (reverse '(a 3 x))
;;(x 3 a)
;;> (reverse '(a 3 x (4)))
;;((4) x 3 a)


;;10. Define and test a procedure fact that takes a natural number and computes the factorial of that number. The factorial of a number is computed by multiplying it by every natural number less than it.
;;
;;> (fact 5)
;;120
;;
(define fact
  (λ (x)
    (cond
      ((zero? x) 1)
      (else (* x (fact (sub1 x))))
      )))

;;MyOutput
;;> (fact 1)
;;1
;;> (fact 0)
;;1
;;> (fact 2)
;;2
;;> (fact 3)
;;6
;;> (fact 4)
;;24
;;> (fact 5)
;;120
;;> (fact 8)
;;40320
;;> (fact 12)
;;479001600


;;11. Define and test a procedure member-?* that takes a (potentially deep) list and returns #t if the list contains the symbol ?, and #f otherwise.
;;
;;> (member-?* '(a b c))
;;#f
;;> (member-?* '(a ? c))
;;#t
;;> (member-?* '((a ((?)) ((c) b c))))
;;#t
;;
(define member-?*
  (λ (ls)
    (cond
      ((null? ls) #f)
      (else 
       (cond
         ((eq? (car ls) '?) #t)
         ((pair? (car ls)) (member-?* (car ls))) 
         (else (member-?* (cdr ls)))
         )))))


;;MyOutput
;;> (member-?* '(a b c))
;;#f
;;> (member-?* '(a ? c))
;;#t
;;> (member-?* '((a ((?)) ((c) b c))))
;;#t
;;> 



;;12. Define and test a procedure fib that takes a natural number n as input and computes the nth number, starting from zero, in the Fibonacci sequence (0, 1, 1, 2, 3, 5, 8, 13, 21, ...). Each number in the sequence is computed by adding the two previous numbers. (The “direct” solution to this problem is very inefficient; see the second brainteaser for a more efficient version.)
;;
;;> (fib 0)
;;0
;;> (fib 1)
;;1
;;> (fib 7)
;;13
;;
(define fib
  (λ (x)
    (cond
      ((zero? x) 0)
      ((zero? (sub1 x)) 1)
      (else (+ (fib (sub1 x)) (fib (sub1 (sub1 x)))))
      )))

;;MyOutput
;;> (fib 0)
;;0
;;> (fib 1)
;;1
;;> (fib 2)
;;1
;;> (fib 3)
;;2
;;> (fib 4)
;;3
;;> (fib 5)
;;5
;;> (fib 6)
;;8
;;> (fib 7)
;;13
;;> (fib 8)
;;21
;;> (fib 20)
;;6765
;;> (fib 12)
;;144



;;13. The expressions (a b) and (a . (b . ())) are equivalent. Using this knowledge, rewrite the expression ((w x) y (z)) using as many dots as possible. Be sure to test your solution using Racket's equal? predicate. (You do not have to define a rewrite procedure; just rewrite the given expression by hand and place it in a comment.)
;;
;;((w . (x . ())) . (y . ( ( z . ()) . () ))



;;14. Define and test a procedure binary->natural that takes a flat list of 0s and 1s representing an unsigned binary number in reverse bit order and returns that number. For example:
;;
;;> (binary->natural '())
;;0
;;> (binary->natural '(0 0 1))
;;4
;;> (binary->natural '(0 0 1 1))
;;12
;;> (binary->natural '(1 1 1 1))
;;15
;;> (binary->natural '(1 0 1 0 1))
;;21
;;> (binary->natural '(1 1 1 1 1 1 1 1 1 1 1 1 1))
;;8191
;;
(define binary->natural
  (λ (ls)
    (cond
      ((null? ls) 0)
      ((zero? (car ls)) ( * 2 (binary->natural (cdr ls))))
      (else (add1 (* 2 (binary->natural (cdr ls)))))
      )))

;;myoutputs
;;> (binary->natural '())
;;0
;;> (binary->natural '(0 0 1))
;;4
;;> (binary->natural '(0 0 1 1))
;;12
;;> (binary->natural '(1 1 1 1))
;;15
;;> (binary->natural '(1 0 1 0 1))
;;21
;;> (binary->natural '(1 1 1 1 1 1 1 1 1 1 1 1 1))
;;8191

;;15. Define subtraction using natural recursion. Your subtraction function, minus, need only take nonnegative inputs where the result will be nonnegative.
;;
;;> (minus 5 3)
;;2
;;> (minus 100 50)
;;50
;;
(define minus
  (λ (n1 n2)
    (cond
      ((zero? n2) n1)
      (else (sub1 (minus n1 (sub1 n2))))
      )))

;;myoutput
;;> (minus 5 2)
;;3
;;> (minus 5 3)
;;2
;;> (minus 5 0)
;;5
;;> (minus 100 50)
;;50

;;16. Define division using natural recursion. Your division function, div, need only work when the second number evenly divides the first. Division by zero is of course bad data.
;;
;;> (div 25 5)
;;5
;;> (div 36 6)
;;6
;;
(define div
  (λ (n1 n2)
    (cond
      ((< n1 n2) 0)
      (else (add1 (div (- n1 n2) n2))
      ))))

;;myoutput
;;> (div 4 5)
;;0
;;> (div 44 5)
;;8
;;> (div 44 15)
;;2
;;> (div 44 3)
;;14
;;> (div 25 5)
;;5
;;> (div 36 6)
;;6

            
;;Brainteasers
;;
;;17. Rewrite some of the natural-recursive programs from above instead using foldr. That is, the bodies of your definitions should not refer to themselves. The names should be the following:
;;
;;    insertR-fr
;;    occurs-?s-fr
;;    filter-fr
;;    zip-fr
;;    map-fr
;;    append-fr
;;    reverse-fr
;;    binary->natural-fr
;;

(define insertR-fr
  (λ (s1 s2 ls)
    (cond
      ((null? ls) '())
      (else (foldr (lambda (v l) 
                     (cond 
                       ((eq? v s1) (cons s1 (cons s2 l)))
                       (else (cons v l))
                             ))  '() ls)) 
      )))

;;myoutput
;;> (insertR-fr 'x 'v '(x x x y x s f f x))
;;(x v x v x v y x v s f f x v)


(define occurs-?s-fr 
  (λ (ls)
    (cond
      ((null? ls) 0)
      (else (foldr (lambda (a b) 
                     (cond
                       ((eq? '? a) (add1 b))
                       (else b)
                       )) 0 ls))
      )))

;;myoutput
;;> (occurs-?s-fr '(? ? c ? a ?))
;;4
;;> (occurs-?s-fr '(? ? c ? a ?))
;;4
;;> (occurs-?s-fr '(? ? c ? a))
;;3


(define filter-fr
  (λ (pred? ls)
    (cond 
      ((null? ls) '())
      (else (foldr (lambda (x y) 
                     (cond
                       ((pred? x) (cons x y))
                       (else y)
                       )) '() ls)) 
     )))


(define zip-fr 
  (λ (ls1 ls2)
    (cond 
      ((null? ls1) '())
      ((null? ls2) '())
      (else (foldr (lambda (x y res) (cons (cons x y) res)) '() ls1 ls2))
      )))

;;myoutput
;;> (zip-fr '(1 2 3) '(4 5 6))
;;((1 . 4) (2 . 5) (3 . 6))


(define map-fr
  (λ (pred ls)
    (cond
      ((null? ls) '())
      (else (foldr (lambda (v l) (cons (pred v) l)) '() ls))
      )))

;;myoutput
;;> (map-fr add1 '(1 2 3 4))
;;(2 3 4 5)
;;> (map-fr sub1 '(1 2 3 4))
;;(0 1 2 3)
;;> 

(define append-fr
  (λ (ls1 ls2)
    (cond
      ((null? ls2) ls1)
      ((null? ls1) ls2)
      (else (foldr cons ls2 ls1))
      )))

;;myoutput for append-fr
;;> (append '() '())
;;()
;;> (append-fr '() '())
;;()
;;> (append '(1 2 3) '(a b c))
;;(1 2 3 a b c)
;;> (append-fr '(1 2 3) '(a b c))
;;(1 2 3 a b c)
;;> (append '(1 2 3) '())
;;(1 2 3)
;;> (append-fr '(1 2 3) '())
;;(1 2 3)
;;> (append-fr '(1 2) '(a b c))
;;(1 2 a b c)
;;> (append-fr '() '(a b c))
;;(a b c)
;;> (append '() '(a b c))
;;(a b c)
;;> (append '(3 4 5 (4 5) (2)) '(a b c))
;;(3 4 5 (4 5) (2) a b c)
;;> (append-fr '(3 4 5 (4 5) (2)) '(a b c))
;;(3 4 5 (4 5) (2) a b c)

(define reverse-fr
  (λ (ls)
    (cond
      ((null? ls) '())
      (else (foldr (lambda (x y) (append y (list x)) ) '() ls  ))
      )))

;;myoutput
;;> (reverse-fr '(1 2 3 4))
;;'(4 3 2 1)


(define binary->natural-fr
  (λ (ls)
    (cond
      ((null? ls) 0)
      (else (foldr (lambda (a b)  (+ a (* 2 b))) 0 ls))
      )))

;;myoutput
;;> (binary->natural-fr '())
;;0
;;> (binary->natural-fr '(0 0 1))
;;4
;;> (binary->natural-fr '(0 0 1 1))
;;12
;;> (binary->natural-fr '(1 1 1 1))
;;15
;;> (binary->natural-fr '(1 0 1 0 1))
;;21
;;> (binary->natural-fr '(1 1 1 1 1 1 1 1 1 1 1 1 1))
;;8191


;;18. Write another variant of the fact procedure, fact-acc, that is properly tail-recursive. That is, any last operation performed by the function is a recursive call (the tail call), or returns a value without recursion. (Hint: fact-acc must take two arguments.)
;;

(define fact-acc
  (λ (x acc)
    (cond
      ((zero? x) acc)
      (else (fact-acc (sub1 x) (* x acc)))
      )))

;;myoutput
;;> (fact 10)
;;3628800
;;> (fact-acc 10 1)
;;3628800


;;19. The following recursive algorithm computes xn for a non-negative integer n:
;;
;;Write a Racket procedure power that uses this algorithm to raise a base x to a power n. For example:
;;
;;> (power 2 0)
;;1
;;> (power 2 2)
;;4
;;> (power 2 10)
;;1024
;;> (power 10 5)
;;100000
;;> (power 3 31)
;;617673396283947
;;> (power 3 32)
;;1853020188851841
;;

(define power
  (λ (b n)
    (cond
      ((zero? n) 1)
      ((odd? n) (* b (power b (sub1 n))))
      ((even? n) (* (power b (/ n 2)) (power b (/ n 2))))
      )))

;;myoutput
;;> (power 2 2)
;;4
;;> (power 1 3)
;;1
;;> (power 2 2)
;;4
;;> (power 2 3)
;;8
;;> (power 2 4)
;;16
;;> (power 2 5)
;;32
;;> (power 2 10)
;;1024
;;> (power 10 5)
;;100000
;;> (power 3 31)
;;617673396283947
;;> (power 3 32)
;;1853020188851841



;;20. Define and test a procedure natural->binary that takes a number and returns a flat list of 0s and 1s representing that unsigned binary number in reverse bit order. For example:
;;
;;> (natural->binary 0)
;;()
;;> (natural->binary 4)
;;(0 0 1)
;;> (natural->binary 12)
;;(0 0 1 1)
;;> (natural->binary 15)
;;(1 1 1 1)
;;> (natural->binary 21)
;;(1 0 1 0 1)
;;> (natural->binary 8191)
;;(1 1 1 1 1 1 1 1 1 1 1 1 1)
;;
;;You can solve this problem multiple ways, but you may want to look up quotient/remainder in the Racket documentation.
;;

(define natural->binary
  (λ (x)
    (cond
      ((zero? x) '())
      ((cons (remainder x 2) (natural->binary (quotient x 2))) )
      )))

;;myoutput
;;> (natural->binary 0)
;;()
;;> (natural->binary 4)
;;(0 0 1)
;;> (natural->binary 12)
;;(0 0 1 1)
;;> (natural->binary 15)
;;(1 1 1 1)
;;> (natural->binary 21)
;;(1 0 1 0 1)
;;> (natural->binary 8191)
;;(1 1 1 1 1 1 1 1 1 1 1 1 1)

;;21. Consider a function f defined as below
;;
;;It is an open question in mathematics, known as the Collatz Conjecture, as to whether, for every positive integer n, (f n) is 1.
;;
;;Your task is to, given the functions below, define collatz, a function which will, when given a positive integer as an input, operate in a manner similar to the mathematical description above.
;;
;;(define base
;;  (lambda (x)
;;    (error 'error "Invalid value ~s~n" x)))
;; 
;;(define odd-case
;;  (lambda (recur)
;;    (lambda (x)
;;      (cond 
;;        ((odd? x) (collatz (add1 (* x 3)))) 
;;        (else (recur x))))))
;; 
;;(define even-case
;;  (lambda (recur)
;;    (lambda (x)
;;      (cond 
;;        ((even? x) (collatz (/ x 2))) 
;;        (else (recur x))))))
;; 
;;(define one-case
;; (lambda (recur)
;;   (lambda (x)
;;     (cond
;;       ((zero? (sub1 x)) 1)
;;       (else (recur x))))))
;;
;;Your solution should use all of the provided functions, and should be no more than a single line long.
;;
;;> (collatz 12)
;;1
;;> (collatz 120)
;;1
;;> (collatz 9999)
;;1
;;

;;given definitions
(define base
  (lambda (x)
    (error 'error "Invalid value ~s~n" x)))
 
(define odd-case
  (lambda (recur)
    (lambda (x)
      (cond 
        ((odd? x) (collatz (add1 (* x 3)))) 
        (else (recur x))))))
 
(define even-case
  (lambda (recur)
    (lambda (x)
      (cond 
        ((even? x) (collatz (/ x 2))) 
        (else (recur x))))))
 
(define one-case
 (lambda (recur)
   (lambda (x)
     (cond
       ((zero? (sub1 x)) 1)
       (else (recur x))))))


(define collatz
  (λ (x)
    ((one-case (even-case (odd-case base))) x)
      ))
      


;;Just Dessert
;;
;;22. A quine is a program whose output is the listings (i.e. source code) of the original program. In Racket, 5 and #t are both quines.
;;
;;> 5
;;5
;;> #t
;;#t
;;
;;We will call a quine in Racket that is neither a number nor a boolean an interesting Racket quine. Below is an interesting Racket quine.
;;
;;> ((lambda (x) (list x (list 'quote x)))
;;  '(lambda (x) (list x (list 'quote x))))
;;((lambda (x) (list x (list 'quote x)))
;;  '(lambda (x) (list x (list 'quote x))))
;;
;;Write your own interesting Racket quine, and define it as quine.
;;