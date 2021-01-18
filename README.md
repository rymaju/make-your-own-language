# Make Your Own Language
### Creating a C style imperative language in Racket


The code in this repository is the most up to date version of my toy imperative language. The goal of this language is to demonstrate how to implement imperative language features using Racket to build our language.

For a full tutorial [click here]("tutorial.md")!


#### `Main.rkt`
The file that will be run by the package manager when `raco pkg install`ing this directory.

#### `reader.rkt`
The "controller" of our program. Reads in text, runs it through `tokenizer.rkt` and `parser.rkt`, then expands it using `expander.rkt`.

#### `tokenizer.rkt`
Parses the text as a raw string into useful tokens. Here we remove comments, mark words as reserved keywords, label words as symbols, numbers, booleans, etc.

#### `parser.rkt`
Describes valid syntax using the tokens we defined in `tokenizer.rkt`. Outputs an AST(Abstract Syntax Tree) with the label of the syntax called on its component parts.

#### `expander.rkt`
Defines macros and functions for the labels given by `parser.rkt`. Expands the AST into a full Racket program. Auxillary program state is also stored in this file.