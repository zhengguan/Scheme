#lang racket
(require C311/trace)
(require C311/pmatch)


(define value-of-scopes
 (lambda (exp env)
  (pmatch exp
   (`,n (guard (number? n)) n)
   (`,x (guard (symbol? x)) (apply-env env x))
   (`,b (guard (boolean? b)) b)
   (`(quote()) '())
   (`(null? ,ls) (null? (value-of-scopes ls env)))
   (`(cons ,a ,d) (cons (value-of-scopes a env) (value-of-scopes d env)))
   (`(car ,ls) (car (value-of-scopes ls env)))
   (`(cdr ,ls) (cdr (value-of-scopes ls env)))
   (`(zero? ,n-exp) (zero? (value-of-scopes n-exp env)))
   (`(* ,x ,y) (* (value-of-scopes x env) (value-of-scopes y env)))
   (`(let ([ ,x ,val ]) ,body) (value-of-scopes body (extend-env x (value-of-scopes val env) env)))
   (`(sub1 ,x) (sub1 (value-of-scopes x env)))
   (`(if ,test-exp ,then-exp ,else-exp) (if (value-of-scopes test-exp env) (value-of-scopes then-exp env) (value-of-scopes else-exp env)))
   (`(lambda (,x) ,body) (closure x body env))
   (`(d-lambda (,x) ,body) (closure-scopes x body env))
   (`(,rator ,rand) (apply-closure-scopes (value-of-scopes rator env) (value-of-scopes rand env) env)))))


(define empty-env
 (lambda ()
  (list 'empty-env)))

(define extend-env
 (lambda (x a env)
  (list 'extend-env x a env)))

(define apply-env
 (lambda (env y)
  (pmatch env
   (`(empty-env) (error 'error))
   (`(extend-env ,x ,a ,env) (if (eqv? y x) a (apply-env env y))))))

(define closure
 (lambda (x body env)
   (list 'closure x body env)))

;(define apply-closure
; (lambda (p a)
;  (pmatch p
;   (`(closure ,x ,body, env) (value-of-scopes body (extend-env x a env))))))

(define closure-scopes
 (lambda (x body env)
   (list 'closure-scopes x body env)))

(define apply-closure-scopes
 (lambda (p a env^)
  (pmatch p
   (`(closure ,x ,body, env) (value-of-scopes body (extend-env x a env)))
   (`(closure-scopes ,x ,body, env) (value-of-scopes body (extend-env x a env^))))))



;;-------------------------------------------------------------------------------------------------------------------
;Testcases

;(value-of-scopes '(let ([x 2])
;                    (let ([f (lambda (e) x)])
;                      (let ([x 5])
;                        (f 0))))
;                 (empty-env))
;2


;(value-of-scopes '(let ([x 2])
;                    (let ([f (d-lambda (e) x)])
;                      (let ([x 5])
;                        (f 0))))
;                 (empty-env))
;5



(value-of-scopes
    '(let
       ([l (cons 1 (cons 2 (cons 3 '())))])
         ((map (lambda (e) (cons e l))) l))
    (extend-env
      'map
      (value-of-scopes
        '(let ([map (lambda (map)
                    (lambda (f)
                      (lambda (l)
                        (if (null? l) '()
                            (cons (f (car l)) (((map map) f) (cdr l)))))))])
             (map map)) (empty-env))
      (empty-env)))
;'((1 1 2 3) (2 1 2 3) (3 1 2 3))


(value-of-scopes
    '(let
       ([l (cons 1 (cons 2 (cons 3 '())))])
         ((map (d-lambda (e) (cons e l))) l))
    (extend-env
      'map
      (value-of-scopes
        '(let ([map (lambda (map)
                    (lambda (f)
                      (lambda (l)
                        (if (null? l) '()
                            (cons (f (car l)) (((map map) f) (cdr l)))))))])
             (map map)) (empty-env))
      (empty-env)))
;'((1 1 2 3) (2 2 3) (3 3))


;; Notice the behavior of let in this next example.
;; we get letrec for free. (This is not a good thing.)
(value-of-scopes
    '(let
       ([map (d-lambda (f)
               (d-lambda (l)
                 (if (null? l) '()
                     (cons (f (car l)) ((map f) (cdr l))))))])
        (let ([f (d-lambda (e) (cons e l))])
          ((map f) (cons 1 (cons 2 (cons 3 '()))))))
    (empty-env))
;'((1 1 2 3) (2 2 3) (3 3))