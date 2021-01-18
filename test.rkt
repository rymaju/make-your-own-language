#lang reader "reader.rkt"

def x;
x = 5;
def y = 6;
print(x, y);
def my-print (x) {
   print(x, 2);
}

my-print(42);

def identity (x) {
   return x;
}

def multiargs (x, y, z) {
   return x * -y / z;
}

print(identity(23));
print(x);
print(1 + 2 * 4);
print(multiargs(10, 2, 4));
print(7/4 * 2131);



def outputfunc() {
    def res(x) {
        return x;
    }
    return res;
}


print(outputfunc());

print(outputfunc()(2));

if(true){
    print("if");
} else if (true) {
    print("else if");               
} else {
    print("else");
}

if(false){
    print("if");
} else if (true) {
    print("else if");               
} else {
    print("else");
}

if(false){
    print("if");
} else if (false) {
    print("else if");               
} else {
    print("else");
}

if(false){
    print("wont print");
}

if(false){
    print("wont print");
} else if(true){
    print("else if (no ending else)");
}

cons(1, 2);
print(cdr(cons(1,2)));
identity(23);

