#lang racket
(require C311/pmatch) ;; <-- important
(require C311/trace)

(define fo-eulav
 (lambda (exp env)
  (pmatch exp
   (`,n (guard (number? n)) n)
   (`,x (guard (symbol? x)) (env x))
   (`,b (guard (boolean? b)) b)
   (`(,x ?orez) (zero? (fo-eulav x env)))
   (`(,x 1bus) (sub1 (fo-eulav x env)))
   (`(,y ,x *) (* (fo-eulav x env) (fo-eulav y env)))
   (`(,else-exp ,then-exp ,test-exp fi) (if (fo-eulav test-exp env) (fo-eulav then-exp env) (fo-eulav else-exp env)))
   (`(,rand ,rator) ((fo-eulav rator env) (fo-eulav rand env)))
   (`(,body (,x) adbmal) (lambda (a) (fo-eulav body (lambda (y) (if (eqv? y x) a (env y)))))))))


(define empty-env
  (lambda ()
    (lambda (y)
      (error 'value-of "unbound variable ~s" y))))

;; Ppa
(fo-eulav '(5 (x (x) adbmal)) (empty-env))
;;5

;; Stnemugra sa Snoitcnuf
(fo-eulav '(((x 1bus) (x) adbmal) ((5 f) (f) adbmal)) (empty-env))
;;4


;; Tcaf
(fo-eulav '(5
            (((((((n 1bus) (f f)) n *) 1 (n ?orez) fi)
               (n) adbmal)
              (f) adbmal)
             ((((((n 1bus) (f f)) n *) 1 (n ?orez) fi)
               (n) adbmal)
              (f) adbmal))) (lambda (y) (error 'value-of "unbound variable ~s" y)))
;;120
