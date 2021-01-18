#lang br/quicklang
(require brag/support racket/contract)

(module+ test
  (require rackunit))

(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define-lex-abbrev varchars (:seq alphabetic (:* (:or alphabetic numeric (char-set "-_=?/!@#$%^&*+-<>~")))  ))
(define-lex-abbrev booleans (:or "true" "false"))
(define-lex-abbrev reserved-terms (:or "def" "{" "}" "," "(" ")" "=" "return" "=="
                                       "+" "*" "-" "/" "%" "if" "else" "lambda" "λ" "struct" ";" ":"
                                       "&&" "||" ">" "<" "<=" ">=" "[" "]"))


(define (make-tokenizer port)
  (define (next-token)
    (define basic-lexer
      (lexer-srcloc
       [whitespace (token lexeme #:skip? #t)]
       [(from/to "//" "\n") (next-token)]
       [(from/to "/*" "*/") (next-token)]
       [reserved-terms (token lexeme lexeme)]
       [booleans (token 'BOOLEAN (string=? "true" lexeme))]
       [digits (token 'INTEGER (string->number lexeme))]
       [(:or (:seq (:? digits) "." digits)
             (:seq digits "."))
        (token 'DECIMAL (string->number lexeme))]
       [(:or (from/to "\"" "\"") (from/to "'" "'"))
        (token 'STRING
               (substring lexeme
                          1 (sub1 (string-length lexeme))))]
       [varchars (token 'SYMBOL (string->symbol lexeme))]))
    (basic-lexer port))  
  next-token)

(provide make-tokenizer)