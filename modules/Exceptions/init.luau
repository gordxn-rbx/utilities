--[=[
@class Exceptions

An easy to use lightweight exceptions logging module.
]=]

--[=[
@within Exceptions
@interface Exception
@field message string
@fiedl formatted boolean
@field outputFn <T...>(T...) -> ()
]=]
export type Exception = {
    message: string,
    formatted: boolean,
    outputFn: <T...>(T...) -> ()
}

local UndefinedException: Exception = {
    message = "An undefined exception has occurred.",
    formatted = false,
    outputFn = warn
}


--[=[
@within Exceptions
@param e Exception
@param origin String -- Optional
@param ... any -- Optional arguments if an exception is formatted

Throws a given exception with an optional 'origin' parameter to help debug.

```lua
local e = require("@path/to/Exceptions")

type Exception = e.Exception

local sampleException: Exception = e.new("Sample exception has occurred.", warn)
local var: Number = 42
if (var ~= 50) then
    e.Throw(sampleException, "LOCATION")
    --Warns "[LOCATION]: Sample exception has occurred."
end
```
]=]
local Throw = function(e: Exception, origin: string?, ...: any?): ()
    local msg
    if (e == nil) or (typeof(e) ~= "table") then
        e = UndefinedException
    end

    if (origin == nil) or (typeof(origin) ~= "string") then
        origin = "Unknown"
    end

    if (e.formatted) then
        msg = e.message:format(tostring(...))
    else
        msg = e.message
    end
    
    pcall(function()
        e.outputFn(`[{origin}]: {msg}`)
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
type Exception = e.Exception

local sampleException: Exception = e.new("Sample exception has occurred.", warn)
```
]=]
local new = function(exceptionMsg: string, isFormatted: boolean, outputFn: <T...>(T...) -> ()): (Exception)
    exceptionMsg = exceptionMsg or ""
    isFormatted = isFormatted or false
    
    if (outputFn == nil) or (typeof(outputFn) ~= "function") then
        outputFn = warn
    end

    return {
        message = exceptionMsg,
        formatted = isFormatted,
        outputFn = outputFn
    }
end

return {
    Throw = Throw,
    new = new
} :: {
    Throw: (e: Exception, origin: string?, ...any?) -> (),
    new: (exceptionMsg: string, isFormatted: boolean, outputFn: <T...>(T...) -> ()) -> (Exception),
}