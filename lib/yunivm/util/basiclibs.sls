(library (yunivm util basiclibs)
         (export
           basiclibs-zero-values
           basiclibs-proc-vector
           basiclibs-name-vector)
         (import (yuni scheme))
         
;;

(define basiclibs-zero-values
  '(;; FIXME: This list is incomplete. e.g. for-each etc
    write
    write-shared write-simple
    newline
    display
    write-char write-string write-u8 write-bytevector
    flush-output-port
    delete-file
    exit
    ;; stdlib
    vector-set!
    ))

(define basiclibs-proc-vector
  (vector
* + - / < <= = > >= abs append apply assoc assq assv
binary-port? boolean=? boolean? bytevector bytevector-append bytevector-copy
bytevector-copy! bytevector-length bytevector-u8-ref bytevector-u8-set!
bytevector? caar cadr call-with-current-continuation call-with-port
call-with-values call/cc car cdar cddr cdr ceiling char->integer

char<=?  char<? char=? char>=? char>? char? close-input-port
close-output-port close-port complex?

cons current-error-port
current-input-port current-output-port

dynamic-wind eof-object eof-object? eq?
equal? eqv?  error error-object-irritants error-object-message error-object?
even? exact exact-integer-sqrt exact-integer? exact? expt

file-error?
floor floor-quotient floor-remainder floor/ flush-output-port for-each gcd
get-output-bytevector get-output-string

inexact inexact? input-port-open? input-port? integer->char integer? lcm
length
list list->string list->vector list-copy list-ref list-set! list-tail list?
make-bytevector make-list make-parameter make-string make-vector map max member
memq memv min modulo negative? newline not null? number->string number?

odd? open-input-bytevector open-input-string open-output-bytevector
open-output-string output-port-open? output-port? pair?
peek-char peek-u8 port? positive?  procedure? quotient raise
raise-continuable

read-bytevector read-bytevector!
read-char read-error?  read-line read-string read-u8 real? remainder reverse
round set-car! set-cdr! square string string->list string->number
string->symbol string->utf8 string->vector string-append string-copy
string-copy! string-fill! string-for-each string-length string-map string-ref
string-set! string<=? string<? string=? string>=? string>? string? substring
symbol->string symbol=? symbol? textual-port? truncate
truncate-quotient truncate-remainder truncate/

utf8->string values vector vector->list vector->string
vector-append vector-copy vector-copy! vector-fill! vector-for-each
vector-length vector-map vector-ref vector-set!  vector?
with-exception-handler write-bytevector write-char write-string write-u8 zero?

caaaar caaadr caaar caadar caaddr caadr cadaar cadadr cadar caddar cadddr caddr
cdaaar cdaadr cdaar cdadar cdaddr cdadr cddaar cddadr cddar cdddar cddddr cdddr

call-with-input-file call-with-output-file delete-file file-exists?
open-binary-input-file open-binary-output-file open-input-file
open-output-file with-input-from-file with-output-to-file

acos asin atan cos exp finite? log nan? sin sqrt tan

command-line exit get-environment-variable

read
display write write-simple
    )
  )

(define basiclibs-name-vector
  '#(
* + - / < <= = > >= abs append apply assoc assq assv
binary-port? boolean=? boolean? bytevector bytevector-append bytevector-copy
bytevector-copy! bytevector-length bytevector-u8-ref bytevector-u8-set!
bytevector? caar cadr call-with-current-continuation call-with-port
call-with-values call/cc car cdar cddr cdr ceiling char->integer

char<=?  char<? char=? char>=? char>? char? close-input-port
close-output-port close-port complex?

cons current-error-port
current-input-port current-output-port

dynamic-wind eof-object eof-object? eq?
equal? eqv?  error error-object-irritants error-object-message error-object?
even? exact exact-integer-sqrt exact-integer? exact? expt

file-error?
floor floor-quotient floor-remainder floor/ flush-output-port for-each gcd
get-output-bytevector get-output-string

inexact inexact? input-port-open? input-port? integer->char integer? lcm
length
list list->string list->vector list-copy list-ref list-set! list-tail list?
make-bytevector make-list make-parameter make-string make-vector map max member
memq memv min modulo negative? newline not null? number->string number?

odd? open-input-bytevector open-input-string open-output-bytevector
open-output-string output-port-open? output-port? pair?
peek-char peek-u8 port? positive?  procedure? quotient raise
raise-continuable

read-bytevector read-bytevector!
read-char read-error?  read-line read-string read-u8 real? remainder reverse
round set-car! set-cdr! square string string->list string->number
string->symbol string->utf8 string->vector string-append string-copy
string-copy! string-fill! string-for-each string-length string-map string-ref
string-set! string<=? string<? string=? string>=? string>? string? substring
symbol->string symbol=? symbol? textual-port? truncate
truncate-quotient truncate-remainder truncate/

utf8->string values vector vector->list vector->string
vector-append vector-copy vector-copy! vector-fill! vector-for-each
vector-length vector-map vector-ref vector-set!  vector?
with-exception-handler write-bytevector write-char write-string write-u8 zero?

caaaar caaadr caaar caadar caaddr caadr cadaar cadadr cadar caddar cadddr caddr
cdaaar cdaadr cdaar cdadar cdaddr cdadr cddaar cddadr cddar cdddar cddddr cdddr

call-with-input-file call-with-output-file delete-file file-exists?
open-binary-input-file open-binary-output-file open-input-file
open-output-file with-input-from-file with-output-to-file

acos asin atan cos exp finite? log nan? sin sqrt tan

command-line exit get-environment-variable

read
display write write-simple
     )
  )
)
