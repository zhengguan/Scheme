#lang racket
(require C311/pmatch) ;; <-- important
(require C311/trace)

(define value-of
 (lambda (exp env)
  (pmatch exp
   (`,n (guard (number? n)) n)
   (`,x (guard (symbol? x)) (unbox (env x)))
   (`,b (guard (boolean? b)) b)
   (`(zero? ,n-exp) (zero? (value-of n-exp env)))
   (`(* ,x ,y) (* (value-of x env) (value-of y env)))
   (`(sub1 ,x) (sub1 (value-of x env)))
   (`(let ([,x ,val]) ,body) (value-of body (lambda (y) (if (eqv? y x) (box (value-of val env)) (env y))))) 
   (`(if ,test-exp ,then-exp ,else-exp) (if (value-of test-exp env) (value-of then-exp env) (value-of else-exp env)))
   (`(lambda (,x) ,body) (lambda (a) (value-of body (lambda (y) (if (eqv? y x) a (env y)))))) 
   (`(lambda (,x ,y) ,body) (lambda (a b) (value-of body (lambda (q) (if (eqv? q x) a (if (eqv? q y) b (env y)))))))
   (`(,rator ,rand) ((value-of rator env) (box (value-of rand env))))
   (`(,rator ,rand1 ,rand2) ((value-of rator env) (box (value-of rand1 env)) (box (value-of rand2 env))))
   (`(begin2 ,arg1 ,arg2) (begin (value-of arg1 env) (value-of arg2 env)))
   (`(set! ,x ,valexp) (set-box! (env x) (value-of valexp env))))))


(value-of
'((lambda (x) (if (zero? x)
12
47))
0)
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;;12

(value-of
'((lambda (x) (if (zero? x)
(* 4 5)
47))
0)
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;;12


(value-of
'(((lambda (f) (lambda (n) (if (zero? n) 1 (* n ((f f) (sub1 n))))))
(lambda (f)
(lambda (n) (if (zero? n) 1 (* n ((f f) (sub1 n)))))))
5)
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;120
;;            

(value-of
'(let ([y (* 3 4)])
((lambda (x) (* x y)) (sub1 6)))
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;;60

(value-of
'(let ([x (* 2 3)])
(let ([y (sub1 x)])
(* x y)))
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;;30

(value-of
'(let ([x (* 2 3)])
(let ([x (sub1 x)])
(* x x)))
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;;25


(value-of
'(let ((! (lambda (x) (* x x))))
(let ((! (lambda (n)
(if (zero? n) 1 (* n (! (sub1 n)))))))
(! 5)))
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;;80