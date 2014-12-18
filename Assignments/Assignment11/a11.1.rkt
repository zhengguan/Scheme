#lang racket
(require C311/mk)
(provide (all-defined-out))
;;(require "a11-student-tests.rkt")
;;(test-file #:file-name "a11.rkt")

(define apply-Go
  (lambda (G e t)
    (fresh (a G^)
      (== `(,a . ,G^) G)
      (fresh (aa da)
        (== `(,aa . ,da) a)
        (conde
          ((== aa e) (== da t))
          ((=/= aa e) (apply-Go G^ e t)))))))

(define !-
  (lambda (G e t)
    (conde
      ((numbero e) (== 'Nat t))
      ((== t 'Bool)
       (conde
         ((== #t e))
         ((== #f e))))
     ((fresh (e1)
             (== `(not ,e1) e)
             (== 'Bool t)
             (!- G e1 'Bool)
             ))
     ((fresh (e1)
             (== `(zero? ,e1) e)
             (== 'Bool t)
             (!- G e1 'Nat)))
     ((fresh (e1)
             (== `(sub1 ,e1) e)
             (== 'Nat t)
             (!- G e1 'Nat)))
      ((fresh (ne1 ne2)
         (== `(+ ,ne1 ,ne2) e)
             (== 'Nat t)
             (!- G ne1 'Nat)
             (!- G ne2 'Nat)))
     ((fresh (ne1 ne2)
             (== `(* ,ne1 ,ne2) e)
         (== 'Nat t)
         (!- G ne1 'Nat)
         (!- G ne2 'Nat)))
      ((fresh (teste anse elsee)
        (== `(if ,teste ,anse ,elsee) e)
        (!- G teste 'Bool)
        (!- G anse t)
        (!- G elsee t)))
      ((symbolo e) (apply-Go G e t))
      ((fresh (x b)
        (== `(lambda (,x) ,b) e)
        (symbolo x)
        (fresh (tx tb)          
          (== `(,tx -> ,tb) t)
          (!- `((,x . ,tx) . ,G) b tb))))
      ((fresh (e1 arg)
        (== `(,e1 ,arg) e)
        (fresh (targ)
          (!- G e1 `(,targ -> ,t))
                    (!- G arg targ))))
     ((fresh (x b)
             (== `(fix (lambda (,x) ,b)) e)
             (symbolo x)
             (!- `((,x . ,t) . ,G) b t))))))


(run* (q) (!- '() #t q))
;(Bool)
(run* (q) (!- '() 17 q))
;(Nat)
;(run* (q) (!- '() (+ 1 2) q))
;(Nat)
;(run* (q) (!- '() (* 1 2) q))
;(Nat)
;(run* (q) (!- '() (not (+ 1 2)) q))
;(Bool)
(run* (q) (!- '() '(zero? 24) q))
;(Bool)
(run* (q) (!- '() '(zero? (sub1 24)) q))
;(Bool)
(run* (q) (!- '() '(not (zero? (sub1 24))) q))
;(Bool)
(run* (q) (!- '() '(not (+ 1 2)) q))
;()
(run* (q) (!- '() '(not (not (+ 1 2))) q))
;()
;(run* (q) (!- '() '(sub1 1) q))
;(Nat)
;(run* (q) (!- '() '(sub1 (+ 1 2)) q))
;(Nat)
;(run* (q) (!- '() '(sub1 (zero? 0)) q))
;()
(run* (q)
      (!- '() '(zero? (sub1 (sub1 18))) q))
;(Bool)
(run* (q)
      (!- '() '(lambda (n) (if (zero? n) n n)) q))
;((Nat -> Nat))
(run* (q)
      (!- '() '((lambda (n) (zero? n)) 5) q))
;(Bool)
(run* (q)
      (!- '() '(if (zero? 24) 3 4) q))
;(Nat)
(run* (q)
      (!- '() '(if (zero? 24) (zero? 3) (zero? 4)) q))
;(Bool)
(run* (q)
      (!- '() '(lambda (x) (sub1 x)) q))
;((Nat -> Nat))
(run* (q)
      (!- '() '(lambda (a) (lambda (x) (+ a x))) q))
;((Nat -> (Nat -> Nat)))
(run* (q)
      (!- '() '(lambda (f)
                 (lambda (x)
                   ((f x) x)))
          q))
;(((_.0 -> (_.0 -> _.1)) -> (_.0 -> _.1)))
(run* (q)
      (!- '() '(sub1 (sub1 (sub1 6))) q))
;(Nat)
(run 1 (q)
     (fresh (t)
            (!- '() '(lambda (f) (f f)) t)))
;()
(length (run 20 (q)
             (fresh (lam a b)
                    (!- '() `((,lam (,a) ,b) 5) 'Nat)
                    (== `(,lam (,a) ,b) q))))
;20
(length (run 30 (q) (!- '() q 'Nat)))
;30
(length (run 30 (q) (!- '() q '(Nat -> Nat))))
;30
(length (run 500 (q) (!- '() q '(Nat -> Nat))))
;500
;; At this point, stop and take a look at maybe the 500th
;; program you generate
;; (last (run 500 (q) (!- '() q '(Nat -> Nat))))
;; You should be amazed at how quickly it's generating them.
;; If it isn't fast, consider reordering your clauses.
(length (run 30 (q) (!- '() q '(Bool -> Nat))))
;30
(length (run 30 (q) (!- '() q '(Nat -> (Nat -> Nat)))))
;30
(length (run 100 (q)
             (fresh (e t)
                    (!- '() e t)
                    (== `(,e ,t) q))))
;100
(length (run 100 (q)
             (fresh (g e t)
                    (!- g e t)
                    (== `(,g ,e ,t) q))))
;100
(length
 (run 100 (q)
      (fresh (g v)
             (!- g `(var ,v) 'Nat)
             (== `(,g ,v) q))))
;100
(run 1 (q)
     (fresh (g)
            (!- g
                '((fix (lambda (!)
                         (lambda (n)
                           (if (zero? n)
                               1
                               (* n (! (sub1 n)))))))
                  5)
                q)))
;(Nat)
(run 1 (q)
     (fresh (g)
            (!- g
                '((fix (lambda (!)
                         (lambda (n)
                           (* n (! (sub1 n))))))
                  5)
                q)))
;(Nat)
