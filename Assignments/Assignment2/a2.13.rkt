#lang racket
(require C311/pmatch) ;; <-- important
(require C311/trace)


(define walk-symbol
  (λ (a origls)
    (define helper 
      (λ (a ls)
        (cond
          ((null? ls) a)          
          ((eqv? (car (car ls)) a)  (cond ((number? (cdr (car ls))) (cdr (car ls)))  (else(walk-symbol (cdr (car ls)) origls)) ))         
          (else (helper a (cdr ls)))
          )
        ))
    (helper a origls)))

(define walk*
  (lambda (v s)
    (let ((v (cond ((symbol? v) (walk-symbol v s))
                   (else v))))
      (cond ((pair? v)
             (cons (walk* (car v) s)
                   (walk* (cdr v) s)))
            (else v)))))

(define unify
  (lambda (u v ls)   
    (cond
      ((not (and (pair? u) (pair? v))) (cond ((eqv? u v) ls) (else #f)))
      ((and (eqv? (walk* (car (car u)) ls) (walk* (car (car v)) ls)) (eqv? (walk* (cdr (car u)) ls) (walk* (cdr (car v)) ls))) ls )
      (else #f)
      )))

(unify 'x 'x '())
(unify 5 5 '())
(unify '((x . 5) (y . z)) '((y . 5) (x . 5)) '((z . 5) (x . y)))
;;(unify '(z 5) '(5 x) '((z . 3) (x . z)))
;;(unify '(5 6) '(x y) '())
;;(unify '(x) '(y) '())


;;      ( ((x . 5) (y . z)) (y . 5) (x . 5)  )
;;      ( ( ,x            )  ,y              )


(walk* 'c '((a . 5) (b . 6) (c . a)))

;;(unify '((x . 5) (y . z)) '((y . 5) (x . 5)) '((z . 5) (x . y)))


;;(walk* 'x '((z . 5) (x . y)))
;;(walk* '((y . 5) (x . 5)) '((z . 5) (x . y)))


;;(unify '(z 5) '(5 x) '((z . 3) (x . z)))
;;(walk* '(z 5) '((z . 3) (x . z)))
;;(walk* '(5 x) '((z . 3) (x . z)))




;Some help on the final condition matching ofr equivalence of walk* u and walk* v.
;Below will be the pmatch line that we might have in the else part fo the main unify code.
;[(else try-extend u v)}
;
;
;inside the helper function try-extend
;we can have as below
;
;(define try-extend
;	(lambda (u v s)
;	(cond
;	[(symbol? (walk* u s)) (cons `(,(walk* v s) (walk* v s)))]
;	[(and (pair? (walk* u s)) (pair? (walk* v s)))]
;	
;