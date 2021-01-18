#lang brag

program: statement*

statement: define-function | if-ladder | declare-struct | line-statement

line-statement: (declare | assign | define-and-assign | return | expression) /";"

declare-struct: /"def" /"struct" SYMBOL /"{" SYMBOL (/"," SYMBOL)* /"}" 

define-function: "def" SYMBOL "(" (SYMBOL (/"," SYMBOL)*)? ")" block 

block: /"{" statement* /"}"


if-ladder: "if" /"(" expression /")" block
           ("else" "if" /"(" expression /")" block)*
           ("else" block)?


return: /"return" expression

define-and-assign: /"def" SYMBOL /"=" expression 

declare: /"def" SYMBOL 
assign: SYMBOL /"=" expression

boolean-operators: expression "==" expression
                 | expression ">" expression
                 | expression "<" expression
                 | expression ">=" expression
                 | expression "<=" expression
                 | expression "&&" expression
                 | expression "||" expression

call: expression /"(" (expression (/"," expression)*)? /")"

void-expression: expression

expression: variable
          | call
          | literal
          | lambda
          | "(" expression ")"
          | array
          | sum
          | boolean-operators

array: /"["(expression (/"," expression)*)? /"]"

lambda: ("lambda"|"λ") (SYMBOL (/"," SYMBOL)*)? ":" expression

literal: INTEGER
       | DECIMAL
       | STRING
       | BOOLEAN

variable: SYMBOL
sum : [sum ("+"|"-")] product
product : [product ("*"|"/"|"mod")] neg
neg : ["-"] expt
expt : [expt "^"] expression

