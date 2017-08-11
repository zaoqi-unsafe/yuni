(library (yunivm heap fixnum coreops)
         (export make-coreops-fixnum)
         (import (yuni scheme)
                 (yunivm heap fixnum objtags)
                 (yunivm heap fixnum objpool)
                 (yunivm heap fixnum allocator))

;;

(define (make-sympool)
  (define count 0)
  (define syms '())
  (define (getsymstr num)
    (unless (<= num count)
      (error "Invalid symbol number" num count))
    (let loop ((ctr (- count num))
               (cur syms))
      ;; FIXME: Use list-ref
      (cond
        ((= ctr 0)
         (car cur))
        (else
          (loop (- ctr 1) (cdr cur))))))
  (define (intern str)
    (let loop ((idx 0) (cur syms))
     (cond
       ((null? cur)
        (set! count idx)
        (set! syms (cons str syms))
        idx)
       ((string=? (car cur) str)
        (- count idx))
       (else
         (loop (+ idx 1) (cdr cur))))))

  (define (query sym)
    (case sym
      ((INTERN) intern)
      ((GETSYMSTR) getsymstr)
      (else (error "Unknown symbol"))))
  query)

(define (make-fixnumpool size)
  (define vec (make-vector size 0))
  (define (iref idx) (vector-ref vec idx))
  (define (iset idx n) (vector-set! vec idx n))
  (define (isize) size)
  (define (query sym)
    (case sym
      ((REF) iref)
      ((SET!) iset)
      ((SIZE) isize)
      (else (error "Unknown symbol"))))
  query)

(define (fixnum-eq? a b) (= a b))

(define (predicate1 proc)
  (lambda (obj)
    (if (proc obj)
      (fixnum-true)
      (fixnum-false))))

(define (predicate2 proc)
  (lambda (a b)
    (if (proc a b)
      (fixnum-true)
      (fixnum-false))))

;; For every predicate procedures, we have 2 variants
;;  1. returns host boolean
;;  2. returns target boolean
(define Pfixnum-eq?               (predicate2 fixnum-eq?))
(define Pfixnum-null?             (predicate1 fixnum-null?))
(define Pfixnum-eof-object?       (predicate1 fixnum-eof-object?))
(define Pfixnum-boolean?          (predicate1 fixnum-boolean?))
(define Pfixnum-boolean=?         (predicate2 fixnum-boolean=?))
(define Pfixnum-true?             (predicate1 fixnum-true?))
(define Pfixnum-false?            (predicate1 fixnum-false?))
(define Pfixnum-char?             (predicate1 fixnum-char?))
(define Pfixnum-char=?            (predicate2 fixnum-char=?))
(define Pfixnum-string?           (predicate1 fixnum-string?))
(define Pfixnum-bytevector?       (predicate1 fixnum-bytevector?))
(define Pfixnum-symbol?           (predicate1 fixnum-symbol?))
(define Pfixnum-symbol=?          (predicate2 fixnum-symbol=?))
(define Pfixnum-pair?             (predicate1 fixnum-pair?))
(define Pfixnum-vector?           (predicate1 fixnum-vector?))
(define Pfixnum-simple-struct?    (predicate1 fixnum-simple-struct?))
(define Pfixnum-flonum?           (predicate1 fixnum-flonum?))
(define Pfixnum-fixnum?           (predicate1 fixnum-fixnum?))
(define Pfixnum-primitive?        (predicate1 fixnum-primitive?))
(define Pfixnum-vmclosure?        (predicate1 fixnum-vmclosure?))

(define (make-coreops-fixnum)
  (define HEAPSIZE (* 2 1024 1024))
  (define theheapbase (make-fixnumpool HEAPSIZE))

  (let ((string-pool (make-objpool (* 16 1024)))
        (flonum-pool (make-objpool (* 16 1024)))
        (bytevector-pool (make-objpool (* 16 1024)))
        (sym-pool (make-sympool))
        (theheap (fixnum-allocator theheapbase)))

    (let ((string-register (string-pool 'REGISTER))
          (string-fetch (string-pool 'FETCH))
          (string-clear-mark (string-pool 'CLEAR-MARK))
          (string-mark (string-pool 'MARK))
          (string-sweep (string-pool 'SWEEP))
          (flonum-register (flonum-pool 'REGISTER))
          (flonum-fetch (flonum-pool 'FETCH))
          (flonum-clear-mark (flonum-pool 'CLEAR-MARK))
          (flonum-mark (flonum-pool 'MARK))
          (flonum-sweep (flonum-pool 'SWEEP))
          (bytevector-register (bytevector-pool 'REGISTER))
          (bytevector-fetch (bytevector-pool 'FETCH))
          (bytevector-clear-mark (bytevector-pool 'CLEAR-MARK))
          (bytevector-mark (bytevector-pool 'MARK))
          (bytevector-sweep (bytevector-pool 'SWEEP))
          (sym-intern (sym-pool 'INTERN))
          (sym-getsymstr (sym-pool 'GETSYMSTR))
          (heap-init (theheap 'INIT))
          (alloc0 (theheap 'ALLOC))
          (free (theheap 'FREE))
          (heapref (theheapbase 'REF))
          (heapset! (theheapbase 'SET!)))


      (define (alloc size . objs)
        (let ((siz (* 8 (quotient (+ size 7) 8))))
         (alloc0 siz)))

      ;; Dummy fixnum converter
      (define (%fixnum x) 
        (unless (fixnum-fixnum? x)
          (error "Overflow" x)) 
        x)

      (define (fixnum-eqv? a b) 
        (or (= a b)
            ;; Numbers
            (and (fixnum-flonum? a)
                 (fixnum-flonum? b)
                 (let ((aa (fixnum-unwrap-flonum a))
                       (bb (fixnum-unwrap-flonum b)))
                   (= aa bb)))))

      (define Pfixnum-eqv? (predicate2 fixnum-eqv?))

      ;; string
      (define (%fixnum-string obj)
        (string-fetch (fixnum-string->idx obj)))
      (define (fixnum-string-length obj)
        (string-length (%fixnum-string obj)))
      (define (fixnum-string-ref obj idx)
        (fixnum-integer->char
          (char->integer (string-ref (%fixnum-string obj) (%fixnum idx)))))
      (define (fixnum-string-set! obj idx c)
        (string-set! (%fixnum-string obj) (%fixnum idx) 
                     (integer->char (fixnum-char->integer c))))
      (define (fixnum-make-string0 count)
        (fixnum-idx->string (string-register (make-string (%fixnum count)) #f)))

      ;; bytevector
      (define (%fixnum-bytevector obj)
        (bytevector-fetch (fixnum-bytevector->idx obj)))
      (define (fixnum-bytevector-length obj)
        (bytevector-length (%fixnum-bytevector obj)))
      (define (fixnum-bytevector-u8-ref obj idx)
        (bytevector-u8-ref (%fixnum-bytevector obj) (%fixnum idx)))
      (define (fixnum-bytevector-u8-set! obj idx n)
        (bytevector-u8-set! (%fixnum-bytevector obj) 
                            (%fixnum idx) (%fixnum n)))
      (define (fixnum-make-bytevector0 count)
        (fixnum-idx->bytevector (bytevector-register 
                                  (make-bytevector (%fixnum count)) #f)))

      ;; symbol
      (define (fixnum-string->symbol obj)
        (fixnum-idx->symbol (sym-intern (%fixnum-string obj))))
      (define (fixnum-symbol->string obj)
        (fixnum-idx->string
          (string-register (sym-getsymstr (fixnum-symbol->idx obj)) #f)))

      ;; pair (tentative)
      (define (fixnum-cons a b)
        (let ((offs (alloc 4 a b)))
         (heapset! (+ offs 2) a)
         (heapset! (+ offs 3) b)
         (fixnum-idx->pair offs)))
      (define (fixnum-car obj)
        (let ((offs (fixnum-pair->idx obj)))
         (heapref (+ offs 2))))
      (define (fixnum-cdr obj)
        (let ((offs (fixnum-pair->idx obj)))
         (heapref (+ offs 3))))
      (define (fixnum-set-car! obj x)
        (heapset! (+ 2 (fixnum-pair->idx obj)) x))
      (define (fixnum-set-cdr! obj x)
        (heapset! (+ 3 (fixnum-pair->idx obj)) x))

      ;; vector
      (define (fixnum-vector-length obj)
        (heapref (+ (fixnum-vector->idx obj) 2)))
      (define (fixnum-vector-ref obj idx)
        (let* ((offs (fixnum-vector->idx obj))
               (len (heapref (+ offs 2))))
          (unless (<= 0 idx (- len 1))
            (error "Out of index" offs len idx))
          (heapref (+ offs idx 3))))
      (define (fixnum-vector-set! obj idx x)
        (let* ((offs (fixnum-vector->idx obj))
               (len (heapref (+ offs 2))))
          (unless (<= 0 idx (- len 1))
            (error "Out of index" offs len idx))
          (heapset! (+ offs idx 3) x)))
      (define (fixnum-make-vector0 count)
        (let ((offs (alloc (+ count 3))))
         (heapset! (+ offs 2) count)
         (fixnum-idx->vector offs)))

      ;; flonum
      (define (fixnum-wrap-flonum obj)
        (fixnum-idx->flonum (flonum-register obj #f)))
      (define (fixnum-unwrap-flonum fl)
        (flonum-fetch (fixnum-flonum->idx fl)))

      ;; simple-struct
      (define (fixnum-make-simple-struct0 name count)
        (let ((offs (alloc (+ count 4) name)))
         (heapset! (+ offs 2) count)
         (heapset! (+ offs 3) name)
         (fixnum-idx->simple-struct offs)))
      (define (fixnum-simple-struct-ref obj idx)
        (let* ((offs (fixnum-simple-struct->idx obj))
               (len (heapref (+ offs 2))))
          (unless (<= 0 idx (- len 1))
            (error "Out of index" offs len idx))
          (heapref (+ offs idx 4))))
      (define (fixnum-simple-struct-set! obj idx x)
        (let* ((offs (fixnum-simple-struct->idx obj))
               (len (heapref (+ offs 2))))
          (unless (<= 0 idx (- len 1))
            (error "Out of index" offs len idx))
          (heapset! (+ offs idx 4) x)))
      (define (fixnum-simple-struct-name obj)
        (heapref (+ 3 (fixnum-simple-struct->idx obj))))

      ;; vmclosure (tentative)
      (define (fixnum-vmclosure-env obj)
        (heapref (+ 3 (fixnum-vmclosure->idx obj))))
      (define (fixnum-vmclosure-label obj)
        (heapref (+ 2 (fixnum-vmclosure->idx obj))))
      (define (fixnum-make-vmclosure label env)
        (let ((idx (alloc 4 label env)))
         (heapset! (+ idx 3) env)
         (heapset! (+ idx 2) label)
         (fixnum-idx->vmclosure idx)))

      (define (query sym)
        (case sym
          ((eq?)                 Pfixnum-eq?)
          ((Peq?)                fixnum-eq?)
          ((eqv?)                Pfixnum-eqv?)
          ((Peqv?)               fixnum-eqv?)
          ((null)                fixnum-null)
          ((null?)               Pfixnum-null?)
          ((Pnull?)              fixnum-null?)

          ((eof-object)          fixnum-eof-object)
          ((eof-object?)         Pfixnum-eof-object?)
          ((Peof-object?)        fixnum-eof-object?)

          ((true)                fixnum-true)
          ((false)               fixnum-false)
          ((boolean?)            Pfixnum-boolean?)
          ((Pboolean?)           fixnum-boolean?)
          (($boolean=?)          Pfixnum-boolean=?)
          ((P$boolean=?)         fixnum-boolean=?)
          ((true?)               Pfixnum-true?)
          ((false?)              Pfixnum-false?)
          ((Ptrue?)              fixnum-true?)
          ((Pfalse?)             fixnum-false?)

          ((char?)               Pfixnum-char?)
          ((Pchar?)              fixnum-char?)
          (($char=?)             Pfixnum-char=?)
          ((P$char=?)            fixnum-char=?)
          ((integer->char)       fixnum-integer->char)
          ((char->integer)       fixnum-char->integer)
          ((string?)             Pfixnum-string?)
          ((Pstring?)            fixnum-string?)
          ((string-length)       fixnum-string-length)
          ((string-ref)          fixnum-string-ref)
          ((string-set!)         fixnum-string-set!)
          (($make-string)        fixnum-make-string0)

          ((bytevector?)         Pfixnum-bytevector?)
          ((Pbytevector?)        fixnum-bytevector?)
          ((bytevector-length)   fixnum-bytevector-length)
          ((bytevector-u8-ref)   fixnum-bytevector-u8-ref)
          ((bytevector-u8-set!)  fixnum-bytevector-u8-set!)
          (($make-bytevector)    fixnum-make-bytevector0)

          ((symbol?)             Pfixnum-symbol?)
          (($symbol=?)           Pfixnum-symbol=?)
          ((Psymbol?)            fixnum-symbol?)
          ((P$symbol=?)          fixnum-symbol=?)
          ((string->symbol)      fixnum-string->symbol)
          ((symbol->string)      fixnum-symbol->string)

          ((pair?)               Pfixnum-pair?)
          ((Ppair?)              fixnum-pair?)
          ((cons)                fixnum-cons)
          ((car)                 fixnum-car)
          ((cdr)                 fixnum-cdr)
          ((set-car!)            fixnum-set-car!)
          ((set-cdr!)            fixnum-set-cdr!)

          ((vector?)             Pfixnum-vector?)
          ((Pvector?)            fixnum-vector?)
          ((vector-length)       fixnum-vector-length)
          ((vector-ref)          fixnum-vector-ref)
          ((vector-set!)         fixnum-vector-set!)
          (($make-vector)        fixnum-make-vector0)

          ((Pfixnum?)            fixnum-fixnum?)
          ((fixnum?)             Pfixnum-fixnum?)
          ((Pflonum?)            fixnum-flonum?)
          ((flonum?)             Pfixnum-flonum?)
          ((wrap-flonum)         fixnum-wrap-flonum)
          ((unwrap-flonum)       fixnum-unwrap-flonum)

          ((undefined)           fixnum-undefined)
          ((unspecified)         fixnum-unspecified)

          ((simple-struct?)      Pfixnum-simple-struct?)
          ((Psimple-struct?)     fixnum-simple-struct?)
          (($make-simple-struct) fixnum-make-simple-struct0)
          ((simple-struct-ref)   fixnum-simple-struct-ref)
          ((simple-struct-set!)  fixnum-simple-struct-set!)
          ((simple-struct-name)  fixnum-simple-struct-name)

          ((primitive?)          Pfixnum-primitive?)
          ((Pprimitive?)         fixnum-primitive?)
          ((make-primitive)      fixnum-make-primitive)
          ((primitive-id)        fixnum-primitive-id)

          ((vmclosure?)          Pfixnum-vmclosure?)
          ((Pvmclosure?)         fixnum-vmclosure?)
          ((make-vmclosure)      fixnum-make-vmclosure)
          ((vmclosure-env)       fixnum-vmclosure-env)
          ((vmclosure-label)     fixnum-vmclosure-label)

          (else (error "Unknown symbol" sym))))

      ;; Init heap
      (heap-init)

      query)))
         
)
