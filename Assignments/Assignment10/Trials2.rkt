#lang racket
(require C311/mk)
(require C311/numbers)
(provide (all-defined-out) (all-from-out C311/mk) (all-from-out C311/numbers))
(require C311/let-pair)
(require C311/trace)

(run* (q)
  (== 5 q)
  (conde
    [(conde [(== 5 q)
	     (== 6 q)])
     (== 5 q)]
    [(== q 5)]
    ))

(run 2 (q) 
  (fresh (a b) 
    (== `(,a ,b) q)
    (absento 'tag q)
    (symbolo a)
    ))


(run* (q)
     (fresh (x y z)
            (== `,x `(,y . ,z))
            (== `(,y . ,z) '(cat dog))))

;(((_.0 _.1) (=/= ((_.0 tag))) (sym _.0) (absento (tag _.1))))


(run* (q)
      (fresh (x y)
             (not-pairo x)))

(run* (q)
      (== 'cat '5))

(run* (q)
      (absento 'cat q))

(run* (q)
      (numbero q)
      ;(symbolo 'cat)
      (=/= 5 q)
      ;(absento 'cat q))
)


(run* (q)
      ;(symbolo q)
      (absento 'cat q))

;(run* (q)
;      (listo (a b c q)))

;(run* (q)
;      (symbolo q)
;      (listo `(,a ,b ,c . ,q)))

(run* (q)
      (=/= q 6))


(run* (q)
      (not-pairo q))


(run* (q)
      (numbero q)
      (symbolo q)
      ;(listo q)
      ;(=/= 5 q)
      ;(absento 'cat q))
)