(library (r7c-basic lib lists)
         (export
           list?
           list
           append
           reverse
           memq
           assq
           assv
           make-list
           length
           list-tail
           list-ref
           list-set!
           list-copy)
         (import (r7c-basic syntax define)
                 (r7c-system core)
                 (r7c core apply)
                 (r7c core error)
                 (r7c syntax if)
                 (r7c syntax or)
                 (r7c syntax and)
                 (r7c syntax let)
                 (r7c syntax cond)
                 (r7c heap core)
                 (r7c heap eqv)
                 (r7c heap fixnum)
                 (r7c heap pair))
         

(define (list? obj)
  (and (pair? obj)
       (let ((d (cdr obj)))
        (or (null? d)
            (list? d)))))

(define (list . x) x)

(define (append/itr! cur lis) ;; => cur
  (cond
    ((null? lis) cur)
    ((pair? lis)
     (let* ((a (car lis))
            (d (cdr lis))
            (p (cons a '())))
       (set-cdr! cur p)
       (append/itr! p d)))
    (else
      (error "List required" lis))))

(define (append/2 p s)
  (cond
    ((null? p)
     (unless (or (null? s) (list? s))
       (error "List required" s)) 
     s)
    ((pair? p)
     (let* ((a (car p))
            (d (cdr p))
            (x (cons a '())))
       (let ((y (append/itr! x d)))
        (append/itr! y s))
       x))
    (else
      (error "List required" p))))

(define (append/Nitr! cur lis queue)
  (let ((r (append/itr! cur lis)))
   (cond
     ((null? queue) r)
     (else
       (let ((a (car queue))
             (d (cdr queue)))
         (append/Nitr! r a d))))))

(define (append/N p s . rest)
  (cond
    ((null? p)
     (apply append s rest))
    ((pair? p)
     (let* ((a (car p))
            (d (cdr p))
            (x (cons a '())))
       (let ((y (append/itr! x d)))
        (append/Nitr! y s rest))
       x))
    (else
      (error "List required" p))))

(define (append a b . rest)
  (cond
    ((null? rest)
     (append/2 a b))
    (else
      (apply append/N a b rest)))) 

(define (reverse/itr cur lis)
  (cond
    ((pair? lis)
     (let ((a (car lis))
           (d (cdr lis)))
       (reverse/itr (cons a cur) d)))
    ((null? lis)
     cur)
    (else
      (error "List required" lis))))

(define (reverse x)
  (reverse/itr '() x))

(define (memq obj list)
  (cond
    ((pair? list)
     (if (eq? obj (car list))
       list
       (memq obj (cdr list))))
    ((null? list) #f)
    (else
      (error "List required" list))))

#|
(define (memv obj list)
  (cond
    ((pair? list)
     (if (eqv? obj (car list))
       list
       (memv obj (cdr list))))
    ((null? list) #f)
    (else
      (error "List required" list))))
|#

(define (assq obj alist)
  (cond
    ((pair? alist)
     (let ((a (car alist))
           (d (cdr alist)))
       (unless (pair? a)
         (error "Invalid alist entry" a))
       (if (eq? (car a) obj)
         a
         (assq obj d))))
    ((null? alist) #f)
    (else
      (error "alist required" alist)))) 

(define (assv obj alist)
  (cond
    ((pair? alist)
     (let ((a (car alist))
           (d (cdr alist)))
       (unless (pair? a)
         (error "Invalid alist entry" a))
       (if (eqv? (car a) obj)
         a
         (assv obj d))))
    ((null? alist) #f)
    (else
      (error "alist required" alist)))) 

(define (make-list/fill cur k fil)
  (if ($fx>= 0 k)
    cur
    (make-list/fill (cons fil cur) ($fx- k 1) fil)))

(define (make-list k . fill?)
  (if (null? fill?)
    (make-list/fill '() k #f)
    (make-list/fill '() k (car fill?))))

(define length $fx-length)

(define (list-tail lis k)
  (if ($fx>= 0 k)
    lis
    (list-tail (cdr lis) ($fx- k 1))))

(define (list-ref lis k)
  (car (list-tail lis k)))

(define (list-set! lis k v)
  (set-car! (list-tail lis k) v))

(define (list-copy obj)
  ;; FIXME: oh...
  (reverse (reverse obj)))

)