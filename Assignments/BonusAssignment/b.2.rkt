#lang racket
(require C311/pmatch)
(require C311/let-pair)
(provide (all-defined-out))
(require C311/trace)

(define filter*
  (lambda (f ls)
    (cond
      [(null? ls) '()]
      [(pair? (car ls))
       (cons (filter* f (car ls)) (filter* f (cdr ls)))]
      [(null? (car ls)) '()]
      [(f (car ls)) (cons (car ls) (filter* f (cdr ls)))]
      [else (filter* f (cdr ls))])))
 
(define filter*-sps
 (lambda (pred ls s)
  (cond
   [(null? ls) `(() . ,s)]
   [(pair? (car ls)) 
    (let-pair ([a . b] (filter*-sps pred (car ls) s))
     (let-pair ([c . d] (filter*-sps pred (cdr ls) s))
      `((,a . ,c) . (,b . ,d))))]
   [(let-pair ((e . s^)
     (filter*-sps pred (cdr ls) s))
     (cond 
      ((pred (car ls)) (cons (cons (car ls) e) s^))
      (else (cons e (cons (car ls) s^)))))])))


(filter* even? '(1 2 3 4 5 6))
;(2 4 6)
 
(filter* odd? '(1 (2 3 (4 5)) 6 7))
;(1 (3 (5)) 7)
 
(filter* (lambda (x) (or (even? x) (< 7 x))) '(1 (2 3 (4 5)) 6 7 ((8 9) 10)))
;((2 (4)) 6 ((8 9) 10))



;(filter*-sps even? '(1 2 3 4 5 6) '())

(filter*-sps odd? '(1 (2 3 (4 5)) 6 7) '())
;((1 (3 (5)) 7) . ((2 (4)) 6))

(filter*-sps even? '(1 2 3 4 5 6) '())
;(2 4 6)
 
(filter*-sps odd? '(1 (2 3 (4 5)) 6 7) '())
;(1 (3 (5)) 7)
 
(filter*-sps (lambda (x) (or (even? x) (< 7 x))) '(1 (2 3 (4 5)) 6 7 ((8 9) 10)) '())
;((2 (4)) 6 ((8 9) 10))