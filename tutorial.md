# 🚨 WARNING 🚨
This is a work in progress.

# Table of Contents

- [Setup](#setup)
- [Comments & Basic Expressions](#comments-&-basic-expressions)
- [Variables & Assignment](#assignment-&-variables)
- Functions & Scope
- If Statements
- Boolean Operators
- :fire: Infix notation :fire:

Coming soon:

- Loops
- Lambdas
- REPL
- Defining New Syntax
- Types


## Intro

Making a language with Racket is a fun expriment for those of us who are curious about programming language design. While resources exist online for using Racket to define languages, I couldn't find one that explained how to write an imperative language in the style of C, Python, or Java.

Frankly, most people are not Rackeeters. When they think "Creating Your Own Programming Language" they want to frankenstein together their favorite lanugages, which is most likely an imperative C flavored language.

Racket is *amazing* for this. But there just isn't a clean introduction to the language that builds a language similar to C. This aims to be that guide.

This isn't really a very good introduction to creating languages in Racket in general though.

If you want better deep dive, [Beautiful Racket](https://beautifulracket.com/) is a far better introduction to creating languages in Racket. In fact this guide is best if you have already finished the `jsonic` or `basic` lang tutorials.




## Setup

To follow along you need Racket, and some knowledge of functional programming. Install Racket and the IDE DrRacket [here](https://download.racket-lang.org/).

We're going to use the `br` package which provides features to make our code slightly more concise and readable.

In the command line write: `raco pkg install br`

### File setup

Our language really consists of 4 main files:

#### `reader.rkt`
The "controller" of our program. Reads in text, runs it through `tokenizer.rkt` and `parser.rkt`, then expands it using `expander.rkt`.

#### `tokenizer.rkt`
Parses the text as a raw string into useful tokens. Here we remove comments, mark words as reserved keywords, label words as symbols, numbers, booleans, etc.

#### `parser.rkt`
Describes valid syntax using the tokens we defined in `tokenizer.rkt`. Outputs an AST(Abstract Syntax Tree) with the label of the syntax called on its component parts.

#### `expander.rkt`
Defines macros and functions for the labels given by `parser.rkt`. Expands the AST into a full Racket program. Auxillary program state is also stored in this file.


We will also be including a test file for our parser and expander, and another test file for the language itself.


Lets fill in these files with some skeleton code:

`reader.rkt`
```rkt
#lang br/quicklang
(require "parser.rkt" "tokenizer.rkt")

(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port)))
  
  (define module-datum (strip-bindings
   #`(module imp "expander.rkt"
       #,parse-tree)))

  (datum->syntax #f module-datum))

(provide read-syntax)
```

`tokenizer.rkt`
```rkt
#lang br/quicklang
(require brag/support)

(define (make-tokenizer port)
  (define (next-token)
    (define my-lexer
      (lexer-srcloc
       ...
       [any-char (token lexeme lexeme)]))
    (my-lexer port))  
  next-token)

(provide make-tokenizer)
```

`parser.rkt`
```rkt
#lang brag

program: statement*

statement: ...

```

`expander.rkt`
```rkt
#lang br/quicklang

(define-macro (imp-mb PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE))

(provide (rename-out [imp-mb #%module-begin]))

(define-macro (program STATEMENT ...) #'(begin STATEMENT ... (void)))

(define-macro (statement CONTENTS) #'CONTENTS)

(provide program statement)

```

`parser-test.rkt`
```rkt
#lang br
(require "parser.rkt"
         "tokenizer.rkt"
          brag/support)

(define test-program-1 #<<HERE

HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-1))
```

`test.rkt`
```rkt
#lang reader "reader.rkt"

```

DrRacket is not always the most convenient IDE. I recommend opening each of these files as a seperate tab.


## Comments & Basic Expressions


Our goal for this section is to create a language that looks like:

```c
/*
This is a multi line comment!
*/

123.456; // an expression for the decimal 123.456
"this is a string"; // an expression for the string "this is a string"
true; // the boolean true
```

---


We left our lexer incomplete. Lets add the ability to write a literal expression like a number.

`tokenizer.rkt`
```rkt
#lang br/quicklang
(require brag/support)

; define digits to be 1 or more of the set of characters 0123...
(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define (make-tokenizer port)
  (define (next-token)
    (define my-lexer
      (lexer-srcloc
       [digits (token 'INTEGER (string->number lexeme))]
       [(:or (:seq (:? digits) "." digits)
             (:seq digits "."))
        (token 'DECIMAL (string->number lexeme))]))
    (my-lexer port))  
  next-token)

(provide make-tokenizer)
```

Now if we see anything numeric, we can identify it as a `digits`. Integers are just `digits`, but we can idenity decimals too. A number with a dot in it should be classified as a decimal/float rather than an integer.

Lets take the time to break down some of this code. We need to provide a function that takes in the port (the stream of text to be parsed) and return a function that returns the next token.

To do this, we create a lexer. To aid in debugging we use `lexer-srcloc` which auto-magically inserts the position data into each token. Later on this will make identifying the token that causes an error much easier.


The lexer functions a lot like `cond` or `match`. We have a matching pattern on the left that loosely resembles a regex expression. On the right we need to output a token.

For our use case, a token is a `(token TYPE DATA)`. `TYPE` is the name of the token, which we will use in `parser.rkt`.

`lexeme` is a fancy way of saying "what we just parsed".

So for example we might find a match of `"123"`, which will output a token `(token 'INTEGER (string->number "123"))` or `(token 'INTEGER 123)`.

Lets do the same for strings and booleans:

`tokenizer.rkt`
```rkt
#lang br/quicklang
(require brag/support)


(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define-lex-abbrev booleans (:or "true" "false"))

(define (make-tokenizer port)
  (define (next-token)
    (define my-lexer
      (lexer-srcloc
        [(from/to "\"" "\"")
            (token 'STRING
                (substring lexeme
                            1 (sub1 (string-length lexeme))))]
       [booleans (token 'BOOLEAN (string=? "true" lexeme))]
       [digits (token 'INTEGER (string->number lexeme))]
       [(:or (:seq (:? digits) "." digits)
             (:seq digits "."))
        (token 'DECIMAL (string->number lexeme))]))
    (my-lexer port))  
  next-token)

(provide make-tokenizer)
```

`from/to` matches input that starts with some string and ends with some string. In our case, anything that starts and ends with a `"` is a string. We then take the substring to trim off those double quotes from the string.

`"\"This is a string\"" -> (token 'STRING "This is a string")`

Booleans are implemented just like numbers, except that there are only two cases: `"true"` or `"false"`.


---

With that, we have the ability to make tokens out of values. But we're missing a few critical features. Recall that our language uses semiclons `;` to seperate statements. That means we dont really need to care about whitespace. (Although, if we were making a language more like Python, we *would* need to care about whitespace).

We should also add support for comments. Its easier to just strip out all comments in the code in the tokenization phase rather than handle it later.

`tokenizer.rkt`
```rkt
#lang br/quicklang
(require brag/support)


(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define-lex-abbrev booleans (:or "true" "false"))

(define (make-tokenizer port)
  (define (next-token)
    (define my-lexer
      (lexer-srcloc
        [whitespace (token lexeme #:skip? #t)] ;
        [(from/to "//" "\n") (next-token)] ; single line comments
        [(from/to "/*" "*/") (next-token)] ; multi line comments

        [(from/to "\"" "\"")
            (token 'STRING
                (substring lexeme
                            1 (sub1 (string-length lexeme))))]
       [booleans (token 'BOOLEAN (string=? "true" lexeme))]
       [digits (token 'INTEGER (string->number lexeme))]
       [(:or (:seq (:? digits) "." digits)
             (:seq digits "."))
        (token 'DECIMAL (string->number lexeme))]))
    (my-lexer port))  
  next-token)

(provide make-tokenizer)
```

Now lets move on to the parser.

Remember that our program was essentially a list of expressions seperated with semicolons. We removed comments and whitespace in the tokenization phase so all thats left is our literal expressions and semicolons.

`parser.rkt`
```rkt
#lang brag

program: statement*

statement: expression /";"

expression: INTEGER
          | DECIMAL
          | BOOLEAN
          | STRING

```



And its really as simple as that. This will produce an AST consistent with the grammar we described above.

Note that we preceded the semicolon with a `/`, this marks it to be ignored when converted into the AST.

Lets check to make sure our tokenizer and parser are correct.


`parser-test.rkt`
```rkt
#lang br
(require "parser.rkt"
         "tokenizer.rkt"
          brag/support)

(define test-program-1 #<<HERE
/*
This is a multi line comment!
*/

123.456; // an expression for the decimal 123.456
"this is a string"; // an expression for the string "this is a string"
true; // the boolean true
HERE
)
  
(parse-to-datum
  (apply-tokenizer-maker make-tokenizer test-program-1))
```

Should output an AST in the interactions window:


```
'(program
    (statement (expression 123.456))
    (statement (expression "this is a string"))
    (statement (expression #t))
)
```

Again, note that the semicolons are absent from the AST. This is because we preprended them with a `/` in our parser. This will make our macros much easier to write.


Next we need to expand this AST into a real Racket program. We take in the above AST as `PARSE-TREE` in the `imp-mb` macro below. 

`'#` begins a template literal, which allows us to rewrite our macros into this template at compile time.

`expander.rkt`
```rkt
#lang br/quicklang

(define-macro (imp-mb PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE))

(provide (rename-out [imp-mb #%module-begin]))

(define-macro (program STATEMENT ...) #'(begin STATEMENT ... (void)))

(define-macro (statement CONTENTS) #'CONTENTS)

(define-macro (expression VAL) #'VAL)

(provide program statement expression)
```

In our case, the only macro that does anything is the `program` macro, which starts a `(begin STATEMENT ... (void))`.

We end with `(void)` so that our begin evaluates to `(void)`.

The other macros `statement` and `expression` simply evaluate to their single argument. In other words they disappear.

Our macro expansion should look something like:

```
(program
    (statement (expression 123.456))
    (statement (expression "this is a string"))
    (statement (expression #t))
)
=>
(begin
    (statement (expression 123.456))
    (statement (expression "this is a string"))
    (statement (expression #t))
    (void)
)
=>
(begin
    (expression 123.456)
    (expression "this is a string")
    (expression #t)
    (void)
)
=>
(begin
    123.456
    this is a string"
    expression #t
    (void)
)
```

Finally we can run our program...

`test.rkt`
```c
#lang reader "reader.rkt"
/*
This is a multi line comment!
*/

123.456; // an expression for the decimal 123.456
"this is a string"; // an expression for the string "this is a string"
true; // the boolean true
```

...and nothing should happen.

We arent displaying any of the values (we ended our `begin` with `void` remember?) and we arent printing anything either.

But notice that if you forget a semicolon or write gibberish and run the code, it should panic and yell at you.


## Assignment & Variables

Our goal for this section is to create a language that looks like:

```c
def x = 5; // initalization
x = 42 // mutation
```

This is actually pretty easy to add into our existing language.

In general when adding features we start at our tokenizer, move up to the parser, test to make sure our AST makes sense, then write the macros to expand our AST, and then test the final results in `test.rkt`.

---

`tokenizer.rkt`
```rkt
#lang br/quicklang
(require brag/support)


(define-lex-abbrev digits (:+ (char-set "0123456789")))
(define-lex-abbrev booleans (:or "true" "false"))
(define-lex-abbrev reserved-keywords (:or "def" "="))
(define-lex-abbrev id-chars (:seq alphabetic (:* (:or alphabetic numeric (char-set "-_=?/!@#$%^&*+-<>~")))))

(define (make-tokenizer port)
  (define (next-token)
    (define my-lexer
      (lexer-srcloc
        [whitespace (token lexeme #:skip? #t)]
        [(from/to "//" "\n") (next-token)]
        [(from/to "/*" "*/") (next-token)]
        [reserved-keywords (token lexeme lexeme)]
        [id-chars (token 'SYMBOL (string->symbol lexeme))]
        [(from/to "\"" "\"")
            (token 'STRING
                (substring lexeme
                            1 (sub1 (string-length lexeme))))]
       [booleans (token 'BOOLEAN (string=? "true" lexeme))]
       [digits (token 'INTEGER (string->number lexeme))]
       [(:or (:seq (:? digits) "." digits)
             (:seq digits "."))
        (token 'DECIMAL (string->number lexeme))]))
    (my-lexer port))  
  next-token)

(provide make-tokenizer)
```

Adding a set of reserved keywords rather than dealing with them as individual cases will scale better. Once we have dozens of keywords in the language we will be glad we dont handle each one as its own branch of the lexer. Note that we set the type of the `reserved-keyword` token to `lexeme`. This means we can refer to the token as its string representation in our parser.

We also add the ability to parse any symbols that arent keywords. Valid identifiers (symbols, variables, etc.) start with an alphabetic character, then can be almost any printable character. We deliberately exclude symbols like `.`, `,`, `;`, `{`, `(`, etc.

Ideally we would like any valid identifier in Racket to also be valid in our language.

`parser.rkt`
```rkt
#lang brag

program: statement*

statement: expression /";"

define-and-assign: /"def" SYMBOL /"=" expression

assign: SYMBOL /"=" expression

expression: SYMBOL
          | INTEGER
          | DECIMAL
          | BOOLEAN
          | STRING

```

Now that we have identifiers in our language we can insert them into our template literals. Since our identifiers are valid Racket identifiers, they should function as identifiers when we add them to our Racket program.

You can go ahead and test this in `parser-test.rkt` if you want to see what the AST looks like.

`expander.rkt`
```rkt
#lang br/quicklang

(define-macro (imp-mb PARSE-TREE)
  #'(#%module-begin
     PARSE-TREE))

(provide (rename-out [imp-mb #%module-begin]))

(define-macro (program STATEMENT ...) #'(begin STATEMENT ... (void)))

(define-macro (statement CONTENTS) #'CONTENTS)

(define-macro (expression VAL) #'VAL)

(define-macro (define-and-assign ID EXPR) #'(define ID EXPR))

(define-macro (assign ID EXPR) #'(set! ID EXPR))

(provide program statement expression define-and-assign assign)
```

Lets go back to `test.rkt` and see if everything works.


`test.rkt`
```c
#lang reader "reader.rkt"
/*
This is a multi line comment!
*/

123.456; // an expression for the decimal 123.456
"this is a string"; // an expression for the string "this is a string"
true; // the boolean true

def x = 5;
def y = 42;
y = "Mutatis mutandis";
```

Now if we go down to the interactions window and ask for the value of `x` and `y`:

```rkt
> x
5
> y
"Mutatis mutandis"
```

It works! :tada:

---

#### Aside: On Walruses


>  I don’t care how much you know about continuations and closures and exception handling: if you can’t explain why `while (*s++ = *t++);` copies a string, or if that isn’t the most natural thing in the world to you, well, you’re programming based on superstition, as far as I’m concerned: a medical doctor who doesn’t know basic anatomy, passing out prescriptions based on what the pharma sales babe said would work.<br/><br/> &mdash; Joel Spolsky "Advice for Computer Science College Students"

As you might have already noticed, our `x = 5` does not behave the way it might in C. Since we used `set!`, our assignment doesnt evaluate to `5`, as we might expect.

Maybe this is a good thing! But perhaps we do want to include that functionality as another operator?

Introducing the walrus: `x := 5`, which both mutates and evaluates to the value being assigned.

Lets give this a shot. We would start by introducing `":="` as a keyword...

`tokenizer.rkt`
```rkt
...
(define-lex-abbrev reserved-keywords (:or "def" "=" ":="))
...
```

Then we would add it to our parser, perhaps like so...

`parser.rkt`
```rkt
...
walrus-assign: SYMBOL /"=" expression

expression: SYMBOL
          | INTEGER
          | DECIMAL
          | BOOLEAN
          | STRING
          | walrus-assign
...
```

And expand it. We can use `let` to rewrite into a series of instructions...

`expander.rkt`
```rkt
...
(define-macro (walrus-assign ID VAL)
    #'(let () (set! ID VAL) VAL))
...
(provide ... walrus-assign)
```

`test.rkt`
```c
def x = 5; def y = 6;
x = y := 42
```
```rkt
> x
42
> y
42
```

You can probably imagine how we might support `def x := 5`.

###