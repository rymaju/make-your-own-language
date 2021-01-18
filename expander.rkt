#lang br/quicklang

; stack of return ccs
(define return-ccs empty)

(define-macro (imp-mb PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE
     (void)))

(provide (rename-out [imp-mb #%module-begin]))

(define-macro (program STATEMENT ...) #'(begin STATEMENT ... (void)))

(define-macro (statement CONTENTS) #'CONTENTS)
(define-macro (declare VAR) #'(define VAR (void)))
(define-macro (assign VAR VAL) #'(set! VAR VAL))
(define-macro (define-and-assign VAR VAL) #'(define VAR VAL))
(define print (lambda args (println (string-join (map (lambda (x) (format "~a" x)) args)))))


(define-macro-cases expression
  [(expression E) #'E]
  [(expression _ E _) #'E])


(define-macro (line-statement E) #'E)

(define-macro (literal E) #'E)
(define-macro (variable E) #'E)
(define-macro (number E) #'E)
(define-macro-cases call
  [(call FUNC) #'(FUNC)]
  [(call FUNC VAL ...) #'(FUNC VAL ...)])

(define-macro (define-function _ NAME _ PARAM ... _ BLOCK)
  #'(define (NAME PARAM ...)
      (let/ec block-return
        (push! block-return)
        BLOCK
        (pop!))))

(define-macro (block STATEMENT ...)
  #'(begin STATEMENT ... (void)))


(define (return VAL)
  (let ([a (car return-ccs)])
    (pop!)
    (a VAL)))

(define-macro-cases if-ladder
  [(if-ladder) #'(void)]
  [(if-ladder "if" CONDITION BLOCK REST ...) #'(if CONDITION
                                                   BLOCK
                                                   (if-ladder REST ...))]
  [(if-ladder "else" "if" CONDITION BLOCK REST ...) #'(if CONDITION
                                                          BLOCK
                                                          (if-ladder REST ...))]
  [(if-ladder "else" BLOCK) #'BLOCK])

(define (push! cc)
  (set! return-ccs (cons cc return-ccs)))
(define (pop!)
  (set! return-ccs (cdr return-ccs)))


(define-macro-cases sum
  [(_ VAL) #'VAL]
  [(_ LEFT "+" RIGHT) #'(+ LEFT RIGHT)]
  [(_ LEFT "-" RIGHT) #'(- LEFT RIGHT)])

(define-macro-cases product
  [(_ VAL) #'VAL]
  [(_ LEFT "*" RIGHT) #'(* LEFT RIGHT)]
  [(_ LEFT "/" RIGHT) #'(/ LEFT RIGHT)]
  [(_ LEFT "mod" RIGHT) #'(modulo LEFT RIGHT)])

(define-macro-cases neg
  [(_ VAL) #'VAL]
  [(_ "-" VAL) #'(- VAL)])

(define-macro-cases expt
  [(_ VAL) #'VAL]
  [(_ LEFT "^" RIGHT) #'(expt LEFT RIGHT)])

(define-macro-cases boolean-operators
  [(boolean-operators VAL1 "==" VAL2) #'(equal? VAL1 VAL2)]
  [(boolean-operators VAL1 ">" VAL2) #'(> VAL1 VAL2)]
  [(boolean-operators VAL1 "<" VAL2) #'(< VAL1 VAL2)]
  [(boolean-operators VAL1 ">=" VAL2) #'(>= VAL1 VAL2)]
  [(boolean-operators VAL1 "<=" VAL2) #'(<= VAL1 VAL2)]
  [(boolean-operators VAL1 "&&" VAL2) #'(and VAL1 VAL2)]
  [(boolean-operators VAL1 "||" VAL2) #'(or VAL1 VAL2)])

(define-macro (array VAL ...)
  #'(vector VAL ...))

(define-macro (declare-struct STRUCT-NAME FIELD ...)
  #'(struct STRUCT-NAME [FIELD ...]))


(define-macro (void-expression V) #'V)


(provide program statement declare assign define-and-assign expression
         literal variable call print define-function block return number
         sum product expt neg if-ladder void-expression  line-statement
         declare-struct boolean-operators array)

;; Racket functions
(provide cons empty car cdr procedure? )
