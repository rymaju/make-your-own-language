#lang br
(require"parser.rkt"
        "tokenizer.rkt"
         brag/support
         rackunit)

(define test-program-1 #<<HERE
def x;
x = 5;
def y = 6;
print(1, 2, 3);
HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-1))

(define test-program-2 #<<HERE
def identity (x) {
   return x;
}
HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-2))

(define test-program-3 #<<HERE
def x = 1 + 2 * 4;
HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-3))


(define test-program-4 #<<HERE

if (true) {

}

if (true) {

} else if (true) {

} else if (true) {

} else {

}
HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-4))

(define test-program-5 #<<HERE

def struct position-2d { x, y }

def struct person {
   name,
   date-of-birth,
   country-of-origin,
   age,
   favorite-color
}

HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-5))

(define test-program-6 #<<HERE
def var=?(v1, v2) {
  
}
HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-6))

(define test-program-7 #<<HERE

1 == 2;

HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-7))