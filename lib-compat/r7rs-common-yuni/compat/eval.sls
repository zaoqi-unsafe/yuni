(library (r7rs-common-yuni compat eval)
         (export eval environment)
         (import 
           (scheme base) ;; FIXME: WAR for Chicken
           (scheme eval)))
