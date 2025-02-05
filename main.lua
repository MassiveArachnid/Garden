local ffi = require("ffi")

-- Safe subset of Lua keywords and operators to generate code from
local keywords = {
    "local", "if", "then", "else", "end", "while", "do", "repeat", "until",
    "function", "return", "and", "or", "not"
}

local operators = {
    "+", "-", "*", "/", "%", "==", "~=", ">", "<", ">=", "<=", ".."
}

local valid_names = {
    "x", "y", "z", "a", "b", "c", "result", "temp", "val", "count"
}

-- Generates a random identifier
local function random_identifier()
    return valid_names[math.random(#valid_names)]
end

-- Generates a random number or string literal
local function random_literal()
    if math.random() > 0.5 then
        return tostring(math.random(-100, 100))
    else
        return string.format('"%s"', string.char(math.random(97, 122)))
    end
end

-- Generates a random expression
local function generate_expression(depth)
    depth = depth or 0
    if depth > 3 or math.random() < 0.3 then
        if math.random() > 0.5 then
            return random_identifier()
        else
            return random_literal()
        end
    end
    
    local expr1 = generate_expression(depth + 1)
    local expr2 = generate_expression(depth + 1)
    local op = operators[math.random(#operators)]
    
    return string.format("(%s %s %s)", expr1, op, expr2)
end

-- Generates a random statement
local function generate_statement(depth)
    depth = depth or 0
    if depth > 5 then
        return "return " .. generate_expression()
    end
    
    local r = math.random()
    if r < 0.3 then
        -- Assignment
        return string.format("local %s = %s",
            random_identifier(),
            generate_expression()
        )
    elseif r < 0.6 then
        -- If statement
        return string.format([[
if %s then
    %s
else
    %s
end]],
            generate_expression(),
            generate_statement(depth + 1),
            generate_statement(depth + 1)
        )
    else
        -- While loop with safety counter
        return string.format([[
local _counter = 0
while %s and _counter < 1000 do
    %s
    _counter = _counter + 1
end]],
            generate_expression(),
            generate_statement(depth + 1)
        )
    end
end

-- Generates a complete random program
local function generate_program()
    local statements = {}
    local num_statements = math.random(3, 10)
    
    for i = 1, num_statements do
        table.insert(statements, generate_statement())
    end
    table.insert(statements, "return " .. generate_expression())
    
    return table.concat(statements, "\n")
end

-- Tests if a program answers a given question correctly
local function test_program(program_code, test_cases)
    -- Create a safe environment for running the code
    local env = {
        math = math,
        string = string,
        tonumber = tonumber,
        tostring = tostring,
        print = print
    }
    
    -- Try to load and run the program
    local func, err = load(program_code, "generated", "t", env)
    if not func then
        return false, "Compilation error: " .. tostring(err)
    end
    
    -- Set a timeout using debug hooks
    local timeout = false
    debug.sethook(function()
        timeout = true
        error("Timeout")
    end, "", 10000)
    
    local success = true
    local results = {}
    
    for i, test in ipairs(test_cases) do
        local ok, result
        ok, result = pcall(function()
            return func()
        end)
        
        if not ok or timeout then
            success = false
            break
        end
        
        if tostring(result) ~= tostring(test.expected) then
            success = false
            break
        end
        
        results[i] = result
    end
    
    debug.sethook()  -- Clear the debug hook
    
    return success, results
end

-- Main evolution loop
local function evolve_program(test_cases, max_generations)
    local best_program = nil
    local generation = 1
    
    while generation <= max_generations do
        local program = generate_program()
        local success, results = test_program(program, test_cases)
        
        if success then
            best_program = program
            print(string.format("Found solution in generation %d!", generation))
            print("\nProgram:")
            print(program)
            print("\nResults:", table.concat(results, ", "))
            return best_program
        end
        
        if generation % 100 == 0 then
            print(string.format("Generation %d...", generation))
        end
        
        generation = generation + 1
    end
    
    return nil
end

-- Example usage
local test_cases = {
    {expected = 42},  -- Example: looking for a program that outputs 42
    {expected = "hello"}  -- Example: looking for a program that outputs "hello"
}

math.randomseed(os.time())  -- Initialize random seed
local solution = evolve_program(test_cases, 1000)

if not solution then
    print("No solution found within generation limit")
end
