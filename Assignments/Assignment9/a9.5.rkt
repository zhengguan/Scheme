#lang racket
(require "parse.rkt")
(require "parenthec.rkt")
(require C311/trace)

;(parse '((lambda (a b c) (* a c)) 5 6 7))

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
      [(const n) (apply-continuation k n)]
      [(var v) (apply-env env v k)]
      [(if test conseq alt)
       (let* ([expr test] [k (cont_inner_if conseq alt env k)])
       (value-of-cps expr env k))]                               
      [(mult rand1 rand2) 
       (let* ([expr rand1] [k (cont_outer_mult rand2 env k)]) (value-of-cps expr env k))]
      [(sub1 rand) 
       (let* ([expr rand] [k (cont_inner_sub1 k)]) (value-of-cps expr env k))]
      [(zero rand) 
       (let* ([expr rand] [k (cont_inner_zero k)]) (value-of-cps expr env k))]
      [(capture body)
       (let* ([expr body] [env (envr_extend k env)])
       (value-of-cps expr env k))]
      [(return vexp kexp)
       (let* ([expr kexp] [k (cont_inner_return vexp env)])
       (value-of-cps expr env k))]
      [(let vexp body)
       (let* ([expr vexp] [k (cont_inner_let body env k)])
       (value-of-cps expr env k))]
      [(lambda body) 
       (let* ([k^ k] [v (clos_closure body env)])
       (apply-continuation k^ v))]
      [(app rator rand)
       (let* ([expr rator] [k (cont_outer_rator_rand rand env k)]) 
       (value-of-cps expr env k))])))
 
(define-union envr
  (empty)
  (extend arg env))
 
(define apply-env
  (lambda (env num k)
    (union-case env envr
      [(empty) 
       (let* ([k^ k] [v (error 'env "unbound variable")])
           (apply-continuation k^ v))]
      [(extend arg env)
       (if (zero? num)
	   (let* ([k^ k] [v arg])
           (apply-continuation k^ v))
	   (let* ([num (sub1 num)])
           (apply-env env num k)))])))
 
(define-union clos
  (closure code env))
 
(define apply-closure
  (lambda (c a k)
    (union-case c clos
      [(closure code env)
       (let* ([expr code] [env (envr_extend a env)])
       (value-of-cps code env k))])))
 
(define-union cont
  (empty)
  (inner_if conseq alt env k)
  (inner_mult x k)
  (outer_mult rand2 env k)
  (inner_sub1 k)
  (inner_zero k)
  (inner_return vexp env)
  (inner_let body env k)
  (inner_rator_rand y k)
  (outer_rator_rand rand env k))

(define apply-continuation
  (lambda (k^ v)
    (union-case k^ cont
      [(empty) v]
      [(inner_if conseq alt env k)
        (if v 
	(let* ([expr conseq]) 
          (value-of-cps expr env k))
	 (let* ([expr alt])
           (value-of-cps expr env k)))]
      [(inner_mult x k) 
       (let* ([v (* x v)]) 
         (apply-continuation k v))]
      [(outer_mult rand2 env k) 
       (let* ([expr rand2] [k (cont_inner_mult v k)])
         (value-of-cps rand2 env k))]
      [(inner_sub1 k) 
       (let* ([v (- v 1)])
           (apply-continuation k v))]
      [(inner_zero k) 
       (let* ([v (zero? v)])
         (apply-continuation k v))]
      [(inner_return vexp env) 
       (let* ([expr vexp] [k v])
         (value-of-cps expr env k))]
      [(inner_let body env k) (let ((v^ v))
                                (let* ([expr body] [env (envr_extend v^ env)])
                                  (value-of-cps body env k)))]
      [(inner_rator_rand y k) 
       (let* ([c y] [a v])
         (apply-closure y v k))]
      [(outer_rator_rand rand env k) 
       (let* ([expr rand] [k (cont_inner_rator_rand v k)])
         (value-of-cps rand env k))])))
;;---------------------------------------------------------------------------------------------------------------------------------
;;Testcases
; Basic test...should be 5.
(pretty-print
 (value-of-cps (exp_app
            (exp_app
             (exp_lambda (exp_lambda (exp_var 1)))
             (exp_const 5))
            (exp_const 6))
           (envr_empty) (cont_empty)))
 

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
	   (envr_empty) (cont_empty)))
	   
 
					
; Test of capture and return...should evaluate to 24.
(pretty-print
 (value-of-cps
  (exp_mult (exp_const 2)
	    (exp_capture
	     (exp_mult (exp_const 5)
		       (exp_return (exp_mult (exp_const 2) (exp_const 6))
                                   (exp_var 0)))))
  (envr_empty) (cont_empty))) 
 
;; (let ([fact (lambda (f)                                                      
;;               (lambda (n)                                                    
;;                 (if (zero? n)                                                
;;                     1                                                        
;;                     (* n ((f f) (sub1 n))))))])                              
;;   ((fact fact) 5))                                                           
 
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
	   (envr_empty) (cont_empty)))
;120