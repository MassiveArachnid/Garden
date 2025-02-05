# Garden
This is a "genetic programming" experiment that tries to randomly generate working Lua code - kind of like the classic "infinite monkeys with typewriters" thought experiment, but with some smart constraints to make it more likely to produce valid programs.
Here's the key parts:

Code Generation System:


Instead of generating completely random text, it builds code using valid Lua building blocks
Uses a limited set of safe operations: basic math, comparisons, and string operations
Creates expressions like "x + 5" or "a == b" using random combinations
Builds statements like assignments ("local x = 42") and control flow ("if x > 0 then...")
Has depth limits to prevent generating overly complex code


Safety Features:


Runs generated code in a sandbox with limited access to Lua functions
Has timeout protection to catch infinite loops
Uses counters in generated while loops to prevent them running forever
Validates code structure before running it


Testing System:


Takes a list of "test cases" - each one specifies an expected output
Runs the generated program and checks if it produces the expected results
Can test for both numeric and string outputs
Catches and handles errors safely if the generated code crashes


Evolution Process:


Keeps generating and testing random programs
Reports progress every 100 generations
Stops when it finds a program that passes all test cases
Has a maximum generation limit to prevent running forever

For example, if you wanted to find a program that outputs 42, you might get something like:
luaCopylocal x = 84
if x > 50 then
    x = x / 2
end
return x
The interesting thing is that you never know exactly how the program will solve the problem - it might find a really creative or unexpected way to produce the right output.
Some cool aspects:

The generated code gets more complex as the depth increases
It balances between simple and complex solutions
You can watch it try different approaches over time
Sometimes finds surprisingly elegant solutions
Can potentially discover novel algorithms (though usually finds simple solutions)

The main limitation is that it's basically using random trial and error - it's not learning from previous attempts or building up complexity gradually like real genetic algorithms would. But it's a fascinating demonstration of how random processes can sometimes produce meaningful results when properly constrained.
