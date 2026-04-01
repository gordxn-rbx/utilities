--// DEPENDENCIES
local SignalConnection = require("./SignalConnection")

--[=[
@class Signal

A `Signal` object allows events to be fired and observed.

Basic Implementation:
```lua
local Signal = require("@path/toSignaLuau")

type Signal<T...> = Signal.Signal<T...>
type SignalConnection = Signal.SignalConnection

local signal: Signal<string> = Signal.new()
local connection: SignalConnection = signal:Connect(function(msg: string): ()
    print(msg)
end)

signal:Fire("Hello, world!")
connection:Disconnect()
```
]=]
local Signal = {}
Signal.__index = function(table: {}, key: any)
    return Signal[key]
end

Signal.__newindex = function(table: {}, key: any, value: any)
    return nil
end


--// TYPE DECLARATIONS
export type SignalConnection = SignalConnection.SignalConnection

type SignalInternal = {
    callbacks: {
        (any) -> (any)
    }
}

--[=[
@within Signal
@interface Signal<T...>

.Connect (Signal<T...>, (...T) -> ()) -> (SignalConnection)
.Destroy (Signal<T...>) -> ()
.Fire (Signal<T...>, ...T) -> ()
.FireAsync (Signal<T...>, ...T) -> ()
.Once (Signal<T...>, (...T) -> ()) -> (SignalConnection)
.Wait (Signal<T...>) -> (...T)
]=]
export type Signal<T...> = {
    Connect: (self: Signal<T...>, callback: (T...) -> ()) -> (SignalConnection),
    Destroy: (self: Signal<T...>) -> (),
    Fire: (self: Signal<T...>, T...) -> (),
    FireAsync: (self: Signal<T...>, T...) -> (),
    Once: (self: Signal<T...>, callback: (T...) -> ()) -> (SignalConnection),
    Wait: (self: Signal<T...>) -> (T...)
}


--[=[
@return Signal<T...>

Returns a constructed `Signal` object

```lua
local Signal = require("@path/toSignaLuau")
type Signal<T...> = Signal.Signal<T...>

local signal: Signal<string> = Signal.new()
```
]=]
function Signal.new<T...>(): (Signal<T...>)
    local internal = {
        connections = {}
    }

    local self = setmetatable({
        internal = internal
    }, Signal)

    return self
end


--[=[
Cleans up `Signal` object by disconnecting all connections.

```lua
signal:Destroy()
```
]=]
function Signal:Destroy(): ()
    for connection: SignalConnection, _:any in pairs(table.clone(self.internal.connections)) do
        connection:Disconnect()
    end
end

--[=[
@param callback (...any) -> ()
@return SignalConnection?

Connects a given `function` to the `Signal` object.
Will run until `:Disconnect()` is called, or the connection's signal is destroyed.

```lua
signal:Connect(function(msg: string)
    print(msg)
end)

signal:Fire("Message 1")
```
]=]
function Signal:Connect(callback: (...any) -> ()): (SignalConnection?)
    if (callback == nil) or (typeof(callback) == "function") then
        return
    end

    local connection: SignalConnection
    connection = SignalConnection.new(function()
        self.internal.connections[connection] = nil
    end)

    self.internal.connections[connection] = callback

    return connection
end


--[=[
@param callback (...any) -> ()
@return SignalConnection?

Connects a given `function` to the `Signal` object.
Connection remains open until it is first fired, then cleans itself up.

```lua
signal:Once(function(msg: string)
    print(msg)
end)

signal:Fire("Message 1")
signal:Fire("Message 1") -- Will not print
```
]=]
function Signal:Once(callback: (any) -> ()): (SignalConnection?)
    if (callback == nil) or (typeof(callback) == "function") then
        return
    end

    local connection: SignalConnection
    connection = self:Connect(function(...: any)
        connection:Disconnect()
        pcall(callback, ...)
    end)

    return connection
end

--[=[
@yields
@return ... any

Yields the current thread until the event is fired, returning the results and resuming the thread.

```lua
task.spawn(function()
    local msg = signal:Wait()
    print(msg)
end)

task.wait(3)
signal:Fire("Hello, world!") -- Prints output 3 seconds after script is executed
```
]=]
function Signal:Wait(): (...any)
    local thread = coroutine.running()
    if not thread then
        error("Signal:Wait() must be called inside a coroutine")
    end

    local connection: SignalConnection
    connection = self:Connect(function(...: any)
        connection:Disconnect()
        coroutine.resume(thread, ...)
    end)

    if (not connection) then
        return
    end

    return coroutine.yield()
end

--[=[
@param ... any

Fires a signal, calling all connected functions associated with the Signal with the given arguments.

```lua
signal:Fire("Hello, world!", 100, false)
```
]=]
function Signal:Fire(...: any): ()
    for connection: SignalConnection, callback: (...any) -> (...any) in pairs(table.clone(self.internal.connections)) do
        pcall(callback, ...)
     end
end

--[=[
@param ... any

Fires a signal, calling all connected functions associated with the Signal with the given arguments in a new thread.

```lua
signal:FireAsync("Hello, world!", 100, false)
```
]=]
function Signal:FireAsync(...: any): ()
    for connection: SignalConnection, callback: (...any) -> (...any) in pairs(table.clone(self.internal.connections)) do
        task.spawn(pcall, callback, ...)
     end
end


--// CLASS END
return Signal