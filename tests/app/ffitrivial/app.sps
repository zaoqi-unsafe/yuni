(import (yuni scheme)
        (yuni ffi abi abiv0-runtime)
        (yuni compat ffi primitives)

        ;; Generated stubs
        (yunistub testing_trivial-constants))

(define test-counter 0)
(define success-counter 0)
(define failed-forms '())

(define (check-finish)
  (display "Test: ")
  (display success-counter)
  (display "/")
  (display test-counter)
  (display " passed.")(newline)
  (unless (null? failed-forms)
    (newline)
    (display "Failed: ")
    (newline)
    (for-each (lambda x
                (display "    ")
                (write x)
                (newline))
              (reverse failed-forms)))
  (flush-output-port (current-output-port))
  (exit (if (null? failed-forms) 0 1)))

(define-syntax check-equal
  (syntax-rules ()
    ((_ obj form)
     (begin
       (set! test-counter (+ 1 test-counter))
       (let ((e form))
       (cond ((equal? obj e)
              (set! success-counter (+ 1 success-counter)))
             (else
               (set! failed-forms (cons 'form failed-forms)))))))))


(define mod (yuniffi-module-load "yunistub_test_primitives"))
(define xmod (yuniffi-module-load "NEVERLAND"))
(define trivial (yuniffi-module-load "yunistub_testing_trivial"))

;; xmod should never be found
(check-equal #f xmod)

(when trivial
  (let* ((tbl (yuniffi-abiv0-lookup/constants trivial
                                              "testing_trivial"))
         (lis (yuniffi-abiv0-get-table tbl)))
    (check-equal #t (list? lis))
    (check-equal -1234 MINUS_CONST_1)
    ;(check-equal 0.5 REAL_1)
    ;(check-equal 0.5 REAL_2)
    (check-equal #f CONST_1)
    (check-equal 1234 CONST_2)
    (check-equal #f UNDEFINED)
    ;(for-each (lambda (e) (write e)(newline)) lis)
    ))

(check-finish)