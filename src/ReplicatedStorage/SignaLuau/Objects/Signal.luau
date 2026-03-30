--// DEPENDENCIES
local SignalConnection = require("./SignalConnection")


--// CLASS DECLARATION
local Signal = {}
Signal.__index = Signal


--// GENERAL VARIABLES



--// TYPE DECLARATIONS
export type SignalConnection = SignalConnection.SignalConnection

type SignalInternal = {
    callbacks: {
        (any) -> (any)
    }
}

export type Signal = {
    Connect: (self: Signal, callback: (...any) -> (...any)) -> (SignalConnection),
    Destroy: (self: Signal) -> (),
    Fire: (self: Signal, any) -> (),
    FireAsync: (self: Signal, any) -> (),
    Once: (self: Signal, callback: (...any) -> (...any)) -> (SignalConnection),
    Wait: (self: Signal) -> ()
}


--// CLASS CONSTRUCTOR
function Signal.new(): ()
    local internal = {
        connections = {}
    }

    local meta = {
        __index = function(table: {}, key: any)
            return Signal[key]
        end,

        __newindex = function(table: {}, key: any, value: any)
            return nil
        end
    }

    local self = {
        internal = internal
    }

    return setmetatable(self, meta)
end


--// CLASS METHODS
function Signal:Destroy(): ()
    for connection: SignalConnection, _:any in pairs(table.clone(self.internal.connections)) do
        connection:Disconnect()
    end
end

function Signal:Connect(callback: () -> ()): (SignalConnection)
    local connection: SignalConnection
    connection = SignalConnection.new(function()
        self.internal.connections[connection] = nil
    end)

    self.internal.connections[connection] = callback

    return connection
end

function Signal:Once(callback: () -> ()): (SignalConnection)
    local connection: SignalConnection
    connection = self:Connect(function(...: any)
        connection:Disconnect()
        pcall(callback, ...)
    end)

    return connection
end

--[=[
	
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

    return coroutine.yield()
end

function Signal:Fire(...: any): ()
    for connection: SignalConnection, callback: (...any) -> (...any) in pairs(table.clone(self.internal.connections)) do
        pcall(callback, ...)
     end
end

function Signal:FireAsync(...: any): ()
    for connection: SignalConnection, callback: (...any) -> (...any) in pairs(table.clone(self.internal.connections)) do
        task.spawn(pcall, callback, ...)
     end
end


--// CLASS END
return Signal