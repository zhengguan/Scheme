#lang racket
(require C311/let-pair)
(provide (all-defined-out))
(require C311/trace)

(define filter-sps
  (lambda (pred ls s)
    (cond
      [(null? ls) '(())]
      [(let-pair ((a . s^) (filter-sps pred (cdr ls) s))
                 (cond 
                   ((pred (car ls)) (cons (cons (car ls) a) s^))
                   (else (cons a (cons (car ls) s^)))))])))
                                    
                 ;`(,(cons (car ls) a) . ,(cons s^ a))) ])))

;(filter-sps even? '() '())

(filter-sps even? '(1 2 3 4) '())

(filter-sps even? '(1 2 3 4 5 6 7 8 9 10) '())
;((2 4 6 8 10) . (1 3 5 7 9))
 
(filter-sps odd? '(1 2 3 4 5 6 7) '())
;((1 3 5 7) . (2 4 6))

(filter-sps (lambda (x) (or (> x 6) (< x 2))) '(1 2 3 4 5 6 7) '())
;((1 7) . (2 3 4 5 6))