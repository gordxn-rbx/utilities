local SignaLuau = require("@game/ReplicatedStorage/SignaLuau")

type SignalConnection = SignaLuau.SignalConnection
type Signal = SignaLuau.Signal

local Object = {}
Object.__index = Object

export type Object = {
    Name: string,
    Value: string,

    ValueUpdated: Signal,
    
    UpdateValue: (self: Object, newValue: string) -> ()
}

function Object.new(objectName: string, objectValue: string)
    local meta = {
        __index = function(table: any, key: unknown): (any)
            if (key == "Name") then
                return table["_name"]
            elseif (key == "Value") then
                return table["_value"]
            elseif (key == "ValueUpdated") then
                return table["_valueUpdated"]
            end

            return Object[key]
        end,

        __newindex = function(_: any, _: any, _: any): (any)
            return nil
        end
    }

    local self = {
        _name = objectName,
        _value = objectValue,

        _valueUpdated = SignaLuau.Signal.new()
    }

    return setmetatable(self, meta)
end

function Object:UpdateValue(newValue: string)
    self._value = newValue

    self._valueUpdated:Fire(newValue)
end

return Object