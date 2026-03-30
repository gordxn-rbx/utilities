--// CLASS DECLARATION
local SignalConnection = {}
SignalConnection.__index = SignalConnection


--// GENERAL VARIABLES


--// TYPE DECLARATIONS
type SignalConnectionInternal = {
    connected: boolean,
    disconnectFunction: () -> (),
}

export type SignalConnection = {
    Connected: boolean,
    Disconnect: (self: SignalConnection) -> ()
}


--// CLASS CONSTRUCTOR
function SignalConnection.new(_disconnectFunction: () -> ())
    local internal: SignalConnectionInternal = {
        connected = true,
        disconnectFunction = _disconnectFunction
    }

    local meta = {
        __index = function(table: {}, key: any)
            if (key == "Connected") then
                return table["internal"]["connected"]
            end

            return SignalConnection[key]
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
function SignalConnection:Disconnect(): ()
    if (not self.internal.connected) then return end

    self.internal.connected = false
    self.internal.disconnectFunction()
end


--// CLASS END
return SignalConnection