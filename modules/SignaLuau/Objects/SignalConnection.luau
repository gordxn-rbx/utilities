--[=[
@class SignalConnection

A `SignalConnection` object exposes methods for managing a specific connection.

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
local SignalConnection = {}
SignalConnection.__index = function(table: {}, key: any)
    if (key == "Connected") then
        return rawget(table, "internal")["connected"]
     end

    return rawget(SignalConnection, key)
end

SignalConnection.__newindex = function(table: {}, key: any, value: any)
    return nil
end


--// TYPE DECLARATIONS
type SignalConnectionInternal = {
    connected: boolean,
    disconnectFunction: () -> (),
}

--[=[
@within SignalConnection
@interface SignalConnection

.Connected boolean
.Disconnect (SignalConnection) -> ()
]=]
export type SignalConnection = {
    Connected: boolean,
    Disconnect: (self: SignalConnection) -> ()
}


--[=[
@param disconnectFunction Function
@return SignalConnection

Returns a constructed `Signal` object with the proper `disconnectFunction`.
]=]
function SignalConnection.new(disconnectFunction: () -> ()): ()
    local internal: SignalConnectionInternal = {
        connected = true,
        disconnectFunction = disconnectFunction
    }

    local self = {
        internal = internal
    }

    return setmetatable(self, SignalConnection)
end


--[=[
Disconnects a `SignalConnection` from the signal.
]=]
function SignalConnection:Disconnect(): ()
    if (not self.internal.connected) then return end

    self.internal.connected = false
    self.internal.disconnectFunction()
end


--// CLASS END
return SignalConnection