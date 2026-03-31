--[=[
@class Exceptions

An easy to use lightweight exceptions logging module.
]=]

--[=[
@within Exceptions
@interface Exception
@field message string
@field outputFn (string) -> ()
]=]
export type Exception = {
    message: string,
    outputFn: <T...>(T...) -> ()
}

local UndefinedException: Exception = {
    message = "An undefined exception has occurred.",
    outputFn = warn
}


--[=[
@within Exceptions
@param e Exception
@param origin String

Throws a given exception with an optional 'origin' parameter to help debug.

```lua
local e = require("@path/to/Exceptions")

local sampleException = e.new("Sample exception has occurred.", warn)
local var: Number = 42
if (var ~= 50) then
    e.Throw(sampleException, "LOCATION") --Warns "[LOCATION]: Sample exception has occurred."
end
```
]=]
local Throw = function(e: Exception, origin: string?): ()
    if (e == nil) or (typeof(e) ~= "table") then
        e = UndefinedException
    end

    if (origin == nil) or (typeof(origin) ~= "string") then
        origin = "Unknown"
    end
    
    pcall(function()
        e.outputFn(`[{origin}]: {e.message}`)
    end)
end

--[=[
@within Exceptions
@param exceptionMsg string
@param outputFn <T...>(T...) -> () -- The function to call when the exception is thrown.
@return Exception

Constructs and returns a new 'Exception' with the given parameters.
```lua
local e = require("@path/to/Exceptions")
local sampleException = e.new("Sample exception has occurred.", warn)
```
]=]
local new = function(exceptionMsg: string, outputFn: <T...>(T...) -> ()): (Exception)
    exceptionMsg = exceptionMsg or ""
    
    if (outputFn == nil) or (typeof(outputFn) ~= "function") then
        outputFn = warn
    end

    return {
        message = exceptionMsg,
        outputFn = outputFn
    }
end

return {
    Throw,
    new
} :: {
    Throw: (e: Exception, origin: string?) -> (),
    new: (exceptionMsg: string, outputFn: <T...>(T...) -> ()) -> (Exception),
}