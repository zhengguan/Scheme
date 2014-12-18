#lang racket
(require C311/pmatch) ;; <-- important
(require C311/trace)

(trace-define value-of
              (lambda (exp env)
                (pmatch exp
                        (`,n (guard (number? n)) n)            
                        (`,x (guard (symbol? x)) (unbox (apply-env-ds env x)))
                        (`,b (guard (boolean? b)) b)
                        (`(zero? ,n-exp) (zero? (value-of n-exp env)))
                        (`(set! ,x ,valexp) (if (apply-env-ds env x) (set-box! (apply-env-ds env x) valexp) (extend-env-ds x valexp env) )) ;;(extend-env-ds x valexp env))   ;;(set! x valexp) )
                        (`(* ,x ,y) (* (value-of x env) (value-of y env) ))
                        (`(sub1 ,x) (sub1 (value-of x env)))
                        (`(let ([ ,x ,val ]) ,body) (value-of body (extend-env-ds x (value-of val env) env)) )
                        (`(if ,test-exp ,then-exp ,else-exp) (if (value-of test-exp env) (value-of then-exp env) (value-of else-exp env)))
                        (`(lambda (,x) ,body) (lambda (a) (value-of body (extend-env-ds x a env)))) 
                        (`(,rator ,rand) ((value-of rator env) (value-of rand env)))
                        (`(begin2 ,arg1 ,arg2) (begin (value-of arg1 env) (value-of arg2 env) ))
                        )))



(define empty-env-ds
  (lambda ()
    (lambda (y)
      (error 'value-of "unbound variable ~s" y)
      )))

(trace-define apply-env-ds
              (lambda (env y)
                (env y)
                ))

(trace-define extend-env-ds
              (lambda (x a env)
                (lambda (y)
                  (if (eqv? x y) (box a) (apply-env-ds env y)
                      ))))



;(test "set!-1"
(value-of
 '((lambda (a)
     ((lambda (p)
        (begin2
          (p a)
          a)) (lambda (x) (set! x 4)))) 3)
 (lambda (y) (error 'value-of "unbound variable ~s" y)))
;3)

;(test "set!-2"
(value-of
 '((lambda (f)
     ((lambda (g)
        ((lambda (z) (begin2
                       (g z)
                       z))
         55))
      (lambda (y) (f y)))) (lambda (x) (set! x 44)))
 (lambda (y) (error 'value-of "unbound variable ~s" y)))
;55)


;(test "set!-3"
(value-of
 '((lambda (x)
     (begin2 (set! x 5) x))
   6)
 (empty-env-ds))
;5)


;(test "set!-4"
(value-of
 '(let ((a 3))
    (begin2 (begin2 a (set! a 4)) a))
 (lambda (y) (error 'value-of "unbound variable ~s" y)))
;4)


;(test "set!-5"
(value-of
 '((lambda (x)
     (begin2
       ((lambda (y)
          (begin2
            (set! x 0)
            98))
        99)
       x))
   97)
 (empty-env-ds))
;0)


;(test "set!-6"
(value-of
 '((lambda (y)
     (let ((x (begin2
                (set! y 7)
                8)))
       (begin2
         (set! y 3)
         ((lambda (z) y)
          x))))
   4)
 (lambda (y) (error 'value-of "unbound variable ~s" y)))
;3)