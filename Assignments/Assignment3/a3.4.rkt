#lang racket
(require C311/pmatch) ;; <-- important
(require C311/trace)


(define value-of
 (lambda (exp env)
  (pmatch exp
   (`,n (guard (number? n)) n)
   (`,x (guard (symbol? x)) (env x))
   (`,b (guard (boolean? b)) b)
   (`(zero? ,n-exp) (zero? (value-of n-exp env)))
   (`(* ,x ,y) (* (value-of x env) (value-of y env)))
   (`(sub1 ,x) (sub1 (value-of x env)))
   (`(let ([ ,x ,val ]) ,body) `,(value-of body (lambda (y) (if (eqv? y x) (value-of val env) (env y)))))
   (`(if ,test-exp ,then-exp ,else-exp) (if (value-of test-exp env) (value-of then-exp env) (value-of else-exp env)))
   (`(lambda (,x) ,body) (lambda (a) (value-of body (lambda (y) (if (eqv? y x) a (env y))))))
   (`(lambda (,x ,y) ,body) (lambda (a b) (value-of body (lambda (q) (if (eqv? q x) a (if (eqv? q y) b (env y)))))))
   (`(,rator ,rand) ((value-of rator env) (value-of rand env)))
   (`(,rator ,rand1 ,rand2) ((value-of rator env) (value-of rand1 env) (value-of rand2 env))))))


(value-of
'((lambda (x y) (* x y)) (* 2 3) (* 4 1))
(lambda (y) (error 'value-of "unbound variable ~s" y)))
;;24