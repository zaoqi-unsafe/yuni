(library (r7b-util time)
         (export current-jiffy current-second jiffies-per-second)
         (import (rnrs)
                 (r7b-compat i19))

(define scale 1000000000.0)

(define (jiffies-per-second) (exact scale))
(define (current-jiffy) (exact (return-sec time-monotonic)))
(define (current-second) (return-sec time-tai))

(define (return-sec sym)
  (let ((t (current-time sym)))
    (+ (* scale (time-second t))
       (time-nanosecond t))))

)
