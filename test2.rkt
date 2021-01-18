#lang reader "reader.rkt"
print(cdr(cons(1,2)));
print(1, cdr(cons(1,2)));

def factorial(x) {
    if(x == 0) {
        return 1;
    }
    return x * (factorial(x - 1));
}

print(factorial(10));
