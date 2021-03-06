#lang racket
(require C311/pmatch)

(define trampoline
 (lambda (th)
  (trampoline (th))))

(define empty-k-trp
 (lambda (jumpout^)
  (list 'empty-k-trp jumpout^)))

;--------------------------------------------------------------------
(define inner-k-ack
 (lambda (m k^)
  (list 'inner-k-ack m k^)))

(define apply-k-ack
 (lambda (k v)
  (pmatch k
   [`(empty-k-trp ,jumpout^) (jumpout^ v)]
   [`(inner-k-ack ,m^ ,k^) (lambda () (ack (sub1 m^) v k^))])))

(define ack
 (lambda (m n k)
  (lambda ()
   (cond
    [(zero? m) (apply-k-ack k (add1 n))]
    [(zero? n) (lambda () (ack (sub1 m) 1 k))]
    [else (lambda () (ack m (sub1 n) (inner-k-ack m k)))]))))

(define ack-tramp-driver 
 (lambda (n1 n2)
  (call/cc 
   (lambda (jumpout^) 
    (trampoline (ack n1 n2 (empty-k-trp jumpout^)))))))

;--------------------------------------------------------------------
(define inner-k-depth
 (lambda (l^ k^)
  (list 'inner-k-depth l^ k^)))

(define outer-k-depth
 (lambda (ls^ k^)
  (list 'outer-k-depth ls^ k^)))
  
(define apply-k-depth
 (lambda (k v)
  (pmatch k
   [`(empty-k-trp ,jumpout^) (jumpout^ v)]
   [`(inner-k-depth ,l^ ,k^) (let ((l^ (add1 l^))) (apply-k-depth k^ (if (< l^ v) v l^)))]
   [`(outer-k-depth ,ls^ ,k^) (lambda () (depth (cdr ls^) (inner-k-depth v k^)))])))

(define depth
 (lambda (ls k)
  (lambda ()
   (cond
    [(null? ls) (apply-k-depth k 1)]
    [(pair? (car ls))
     (lambda () (depth (car ls) (outer-k-depth ls k)))]
    [else (lambda () (depth (cdr ls) k))]))))


(define depth-tramp-driver
 (lambda (ls) 
  (call/cc (lambda (jumpout^)(trampoline (depth ls (empty-k-trp jumpout^)))))))

;--------------------------------------------------------------------
(define inner-k-fact
 (lambda (n^ k^)
  (list 'inner-k-fact n^ k^)))

(define apply-k-fact
 (lambda (k v)
  (pmatch k
   [`(empty-k-trp ,jumpout^) (jumpout^ v)]
   [`(inner-k-fact ,n^ ,k^) (apply-k-fact k^ (* n^ v))])))

(define fact
 (lambda (n k)
  (lambda ()
   ((lambda (fact k)
     (fact fact n k))
    (lambda (fact n k)
     (cond
      [(zero? n) (apply-k-fact k 1)]
      [else (lambda () (fact fact (sub1 n) (inner-k-fact n k)))]))
    k))))


(define fact-tramp-driver 
 (lambda (num) 
  (call/cc 
   (lambda (jumpout^) 
    (trampoline (fact num (empty-k-trp jumpout^)))))))


;--------------------------------------------------------------------
(define inner-k-pascal
 (lambda (a^ k^)
  (list 'inner-k-pascal a^ k^)))

(define outer-k-pascal
 (lambda (m^ a^ k^)
  (list 'outer-k-pascal m^ a^ k^)))

(define inner-k-single-pascal
 (lambda (k^)
  (list 'inner-k-single-pascal k^)))

(define apply-k-pascal
 (lambda (k v)
  (pmatch k
   [`(empty-k-trp ,jumpout^) (jumpout^ v)]
   [`(inner-k-pascal ,a^ ,k^) (apply-k-pascal k^ (cons a^ v))]
   [`(outer-k-pascal ,m^ ,a^ ,k^) (v (add1 m^) a^ (inner-k-pascal a^ k^))]
   [`(inner-k-single-pascal ,k^) (v 1 0 k^)])))

(define pascal
 (lambda (n k)
  (lambda ()
   (let ((pascal
          (lambda (pascal k)
           (apply-k-pascal k 
            (lambda (m a k)
             (cond
              [(> m n) (apply-k-pascal k '())]
              [else 
               (lambda () 
                (let ((a (+ a m)))
                 (lambda () (pascal pascal (outer-k-pascal m a k)))))]))))))
   (lambda () (pascal pascal (inner-k-single-pascal k)))))))

(define pascal-tramp-driver
 (lambda (ls)
  (call/cc
   (lambda (jumpout^)
    (trampoline
     (pascal 10 (empty-k-trp jumpout^)))))))
;-----------------------------------------------------------------------------------------------------------------------------
;;testcase to execute

(ack-tramp-driver 2 3)
;9
(depth-tramp-driver '((((a) b (c (d))) e)))
;5
(fact-tramp-driver 3)
;6
(pascal-tramp-driver 10)
;(1 3 6 10 15 21 28 36 45 55)



