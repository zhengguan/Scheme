#lang racket
(require C311/pmatch)
(require C311/trace)

(define k 'kahii)
(define v 'kahii)
(define n1 'kahii)
(define n2 'kahii)
(define pc 'kahii)


(trace-define trampoline-reg
 (lambda ()
   (begin
     (pc)
     (trampoline-reg))))

(define empty-k-reg
 (lambda (jumpout^)
  (list 'empty-k-reg jumpout^)))

(define apply-k-reg
 (lambda (k v)
  (pmatch k
   [`(empty-k-reg ,jumpout^) (jumpout^ v)]
   ;[`(inner-k-reg ,m^ ,k^) (lambda () (ack-reg (sub1 m^) v k^))]
   [`(inner-k-reg ,m^ ,k^) 
    (begin
      (set! k k^)
      (set! n1 (sub1 m^))
      (set! n2 v)
      (set! pc ack-reg))]
   [`(inner-k-reg-depth ,l^ ,k^) (let ((l^ (add1 l^))) (apply-k-reg k^ (if (< l^ v) v l^)))]
   [`(outer-k-reg-depth ,ls^ ,k^) (lambda () (depth-reg (cdr ls^) (inner-k-reg-depth v k^)))]
   [`(inner-k-reg-fact ,n^ ,k^) (apply-k-reg k^ (* n^ v))]
   [`(inner-k-reg-pascal ,a^ ,k^) (apply-k-reg k^ (cons a^ v))]
   [`(outer-k-reg-pascal ,m^ ,a^ ,k^) (v (add1 m^) a^ (inner-k-reg-pascal a^ k^))]
   [`(inner-k-reg-single-pascal ,k^) (v 1 0 k^)])))

(trace-define ack-reg
 ;(lambda (m n k)
  (lambda ()
   (cond
    ;[(zero? m) (apply-k-reg k (add1 n))]
    [(zero? n1)
     (begin
       (set! n1 (add1 n1))
       (set! pc apply-k-reg))]
    ;[(zero? n) (lambda () (ack-reg (sub1 m) 1 k))]
    [(zero? n2)
     (begin
       (set! n1 (sub1 n1))
       (set! n2 1)
       (set! pc ack-reg))]
    [else 
     ;(lambda () (ack-reg m (sub1 n) (inner-k-reg m k)))
     (begin 
       (set! k (inner-k-reg n1 k))
       ;(set! n1 n1)
       (set! n2 (sub1 n2))
       (set! pc ack-reg))])))

(define inner-k-reg
 (lambda (m k^)
  (list 'inner-k-reg m k^)))

(trace-define ack-reg-tramp-driver 
 (lambda (m n)
  (call/cc 
   (lambda (jumpout^) 
    ;(trampoline-reg (ack-reg n1 n2 (empty-k-reg jumpout^)))))))
     (begin 
       (set! k (empty-k-reg jumpout^))
       (set! n1 m)
       (set! n2 n)
       (set! pc ack-reg)
       (trampoline-reg))))))

;--------------------------------------------------------------------
(define depth-reg
 (lambda (ls k)
  (lambda ()
   (cond
    [(null? ls) (apply-k-reg k 1)]
    [(pair? (car ls))
     (lambda () (depth-reg (car ls) (outer-k-reg-depth ls k)))]
    [else (lambda () (depth-reg (cdr ls) k))]))))

(define inner-k-reg-depth
 (lambda (l^ k^)
  (list 'inner-k-reg-depth l^ k^)))

(define outer-k-reg-depth
 (lambda (ls^ k^)
  (list 'outer-k-reg-depth ls^ k^)))

(define depth-reg-tramp-driver
 (lambda (ls) 
  (call/cc (lambda (jumpout^)(trampoline-reg (depth-reg ls (empty-k-reg jumpout^)))))))

;--------------------------------------------------------------------
(define fact-reg
 (lambda (n k)
  (lambda ()
   ((lambda (fact-reg k)
     (fact-reg fact-reg n k))
    (lambda (fact-reg n k)
     (cond
      [(zero? n) (apply-k-reg k 1)]
      [else (lambda () (fact-reg fact-reg (sub1 n) (inner-k-reg-fact n k)))]))
    k))))

(define inner-k-reg-fact
 (lambda (n^ k^)
  (list 'inner-k-reg-fact n^ k^)))

(define fact-reg-tramp-driver 
 (lambda (num) 
  (call/cc 
   (lambda (jumpout^) 
    (trampoline-reg (fact-reg 5 (empty-k-reg jumpout^)))))))


;--------------------------------------------------------------------
(define pascal-reg
 (lambda (n k)
  (lambda ()
   (let ((pascal-reg
          (lambda (pascal-reg k)
           (apply-k-reg k 
            (lambda (m a k)
             (cond
              [(> m n) (apply-k-reg k '())]
              [else 
               (lambda () 
                (let ((a (+ a m)))
                 (lambda () (pascal-reg pascal-reg (outer-k-reg-pascal m a k)))))]))))))
   (lambda () (pascal-reg pascal-reg (inner-k-reg-single-pascal k)))))))

(define inner-k-reg-pascal
 (lambda (a^ k^)
  (list 'inner-k-reg-pascal a^ k^)))

(define outer-k-reg-pascal
 (lambda (m^ a^ k^)
  (list 'outer-k-reg-pascal m^ a^ k^)))

(define inner-k-reg-single-pascal
 (lambda (k^)
  (list 'inner-k-reg-single-pascal k^)))

(define pascal-reg-tramp-driver
 (lambda (ls)
  (call/cc
   (lambda (jumpout^)
    (trampoline-reg
     (pascal-reg 10 (empty-k-reg jumpout^)))))))

;-----------------------------------------------------------------------------------------------------------------------------
;;testcase to execute

(ack-reg-tramp-driver 2 3)
;9
;(depth-reg-tramp-driver '((((a) b (c (d))) e)))
;5
;(fact-reg-tramp-driver 3)
;6
;(pascal-reg-tramp-driver 10)
;(1 3 6 10 15 21 28 36 45 55)