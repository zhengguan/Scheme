#lang racket
(require "parse.rkt")
(require "parenthec.rkt")
(require C311/trace)

(define-union exp
  (const n)
  (var v)
  (if test conseq alt)
  (mult rand1 rand2)
  (sub1 rand)
  (zero rand)
  (capture body)
  (return vexp kexp)
  (let vexp body)
  (lambda body)
  (app rator rand))

(define value-of-cps
  (lambda (expr env k)
    (union-case expr exp
                [(const n) (apply-k-fn k n)]
                [(var v) (apply-env env v k)]
                [(if test conseq alt)
                 (value-of-cps test env (inner-k-if-fn conseq alt env k))]                               
                [(mult rand1 rand2) (value-of-cps rand1 env (outer-k-mult-fn rand2 env k))]
                [(sub1 rand) (value-of-cps rand env (inner-k-sub1-fn k))]
                [(zero rand) (value-of-cps rand env (inner-k-zero-fn k))]
                [(capture body)
                 (value-of-cps body (envr_extend k env) k)]
                [(return vexp kexp)
                 (value-of-cps kexp env (inner-k-return-fn vexp env))]
                [(let vexp body)
                 (value-of-cps vexp env (inner-k-let body env k))]
                [(lambda body) (apply-k-fn k (clos_closure body env))]
                [(app rator rand)
                 (value-of-cps rator env (outer-k-rator-rand-fn rand env k))])))

(define-union envr
  (empty)
  (extend arg env))

(define apply-env
  (lambda (env num k)
    (union-case env envr
                [(empty) (error 'env "unbound variable")]
                [(extend arg env)
                 (if (zero? num)
                     (apply-k-fn k arg)
                     (apply-env env (sub1 num) k))])))

(define-union clos
  (closure code env))

(define apply-closure
  (lambda (c a k)
    (union-case c clos
                [(closure code env)
                 (value-of-cps code (envr_extend a env) k)])))

(define empty-k-fn
  (lambda ()
    (lambda (v)
      v)))

(define inner-k-if-fn
  (lambda (conseq alt env k)
    (lambda (t)
      (if t 
          (value-of-cps conseq env k)
          (value-of-cps alt env k)))))

(define inner-k-mult-fn
  (lambda (x k)
    (lambda (y) 
      (apply-k-fn k (* x y)))))

(define outer-k-mult-fn
  (lambda (rand2 env k)
    (lambda (x) 
      (value-of-cps rand2 env (inner-k-mult-fn x k)))))

(define inner-k-sub1-fn
  (lambda (k)
    (lambda (x) 
      (apply-k-fn k (- x 1)))))

(define inner-k-zero-fn
  (lambda (k)
    (lambda (x) 
      (apply-k-fn k (zero? x)))))

(define inner-k-return-fn
  (lambda (vexp env)
    (lambda (k) 
      (value-of-cps vexp env k))))

(define inner-k-let
  (lambda (body env k)
    (lambda (v1) 
      (let ((v v1))
        (value-of-cps body (envr_extend v env) k)))))

(define inner-k-rator-rand-fn
  (lambda (y k)
    (lambda (z) 
      (apply-closure y z k))))

(define outer-k-rator-rand-fn
  (lambda (rand env k)
    (lambda (y) 
      (value-of-cps rand env (inner-k-rator-rand-fn y k)))))

(define apply-k-fn
  (lambda (k^ v)
    (k^ v)))

;;---------------------------------------------------------------------------------------------------------------------------------
;;Testcases
; Basic test...should be 5.
(pretty-print
 (value-of-cps (exp_app
                (exp_app
                 (exp_lambda (exp_lambda (exp_var 1)))
                 (exp_const 5))
                (exp_const 6))
               (envr_empty) (empty-k-fn)))


; Factorial of 5...should be 120.
(pretty-print
 (value-of-cps (exp_app
                (exp_lambda
                 (exp_app
                  (exp_app (exp_var 0) (exp_var 0))
                  (exp_const 5)))
                (exp_lambda
                 (exp_lambda
                  (exp_if (exp_zero (exp_var 0))
                          (exp_const 1)
                          (exp_mult (exp_var 0)
                                    (exp_app
                                     (exp_app (exp_var 1) (exp_var 1))
                                     (exp_sub1 (exp_var 0))))))))
               (envr_empty) (empty-k-fn)))



; Test of capture and return...should evaluate to 24.
(pretty-print
 (value-of-cps
  (exp_mult (exp_const 2)
            (exp_capture
             (exp_mult (exp_const 5)
                       (exp_return (exp_mult (exp_const 2) (exp_const 6))
                                   (exp_var 0)))))
  (envr_empty) (empty-k-fn))) 

(pretty-print
 (value-of-cps (exp_let
                (exp_lambda
                 (exp_lambda
                  (exp_if
                   (exp_zero (exp_var 0))
                   (exp_const 1)
                   (exp_mult
                    (exp_var 0)
                    (exp_app
                     (exp_app (exp_var 1) (exp_var 1))
                     (exp_sub1 (exp_var 0)))))))
                (exp_app (exp_app (exp_var 0) (exp_var 0)) (exp_const 5)))
               (envr_empty) (empty-k-fn)))
;120