(library (r7b-impl write)
         (export display write write-shared write-simple)
         (import (rnrs))
(define write-shared write)
(define write-simple write)
)
