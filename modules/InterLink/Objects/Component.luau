--// DEPENDENCIES
local Config = require("../Config")
local SignaLuau = require(script.Parent.Parent.Parent.SignaLuau)


--// TYPE IMPORTS
type Signal<T...> = SignaLuau.Signal<T...>
type SignalConnection = SignaLuau.SignalConnection


--[=[
@class Component

A 'Component' object allows for easy management of custom events and the component's 'Instance'.
]=]
local Component = {}
Component.__index = function(table: any, key: any): (unknown)
    -- Check if key is a method
    local method = rawget(Component, key)
    if (method ~= nil) then
        return method
    end

    -- Check if key is a property of the component
    local internal = rawget(table, "internal")
    local compVal = rawget(internal, key)
    if (compVal ~= nil) then
        return compVal
    end

    -- If an event with the name has already been registered we will pass it off
    -- This is to ensure new roblox updates do not overried pre-existing user-defined events
    local event = rawget(internal.Events, key)
    if (event ~= nil) then
        return event
    end

    -- Try and fetch the property from the instance
    local Instance = rawget(table["internal"], "Instance")
    local success, instanceVal = pcall(function()
        return Instance[key]
    end)
    if (success == true) then
        if (type(instanceVal) == "function") then
            return function(_, ...)
                return instanceVal(Instance, ...)
            end
        end

        return instanceVal
    end

    -- Finally create a new event and return it
    return table:_getEvent(key)
end

Component.__tostring = function(table: {}): (string)
    local Instance = rawget(table["internal"], "Instance")
    local success, returnVal = pcall(function()
        return Instance["Name"]
    end)

    return (success and returnVal) or "Undefined"
end

Component.__newindex = function(table: {}, key: any, value: any)
    local Instance = rawget(table["internal"], "Instance")
    
    local success = pcall(function()
        Instance[key] = value
    end)

    if (Config.Verbose == true) and (success == false) then
        warn(`[InterLink] Components are read-only, only valid properties of an instance are mutable. Silence warnings by setting 'Verbose' to 'false'.`)
    end
end


--[=[
@interface Component<T>
@field Id string
@field Instance T
@field Tags { string }
@field Attributes { [string]: any }
@field Events { [string]: { Signal<...any> } }
@field Destroy (self: Component<T>) -> ()
]=]
export type Component<T> = {
    Id: string,
    Instance: T,
    Tags: {
        string
    },
    Attributes: {
        [string]: any
    },
    Events: {
        [string]: {
            Signal<...any>
        }
    },

    Destroy: (self: Component<T>) -> ()
}


--[=[
@param Id string
@param Instance Instance
@return Component<T>

Returns a constructed 'Component' object with generic type <T>.
]=]
function Component.new<T>(_Id: string, _Instance: Instance): (Component<T>)
    local internal = {
        Id = _Id,
        Instance = _Instance,
        Tags = {},
        Attributes = {},
        Events = {}
    }

    local self = {
        internal = internal
    }

    local componentTags = _Instance:GetTags()
    local componentAttributes = _Instance:GetAttributes()

    for _: any, tag: string in pairs(componentTags) do
        table.insert(self.internal.Tags, tag)
    end

    for name: string, value: any in pairs(componentAttributes) do
        if (name == "id") then continue end
        self.internal.Attributes[name] = value
    end

    return setmetatable(self, Component)
end

function Component: _getEvent(eventName: string): (Signal<...any>)
    if (eventName == nil) or (typeof(eventName) ~= "string" ) then return end

    if (not self.internal.Events[eventName]) then
        if (Config.Verbose) then
            warn(`[InterLink] Creating event {eventName} for {tostring(self.internal.Id)}, silence warnings by setting 'Verbose' to 'false'.`)
        end
        self.internal.Events[eventName] = SignaLuau.new()
    end

    return self.internal.Events[eventName]
end

--[=[
Destroys the component, which includes destroying any related signals as well as the instance it wraps.
]=]
function Component:Destroy()
    for _, Event: Signal<any> in pairs(self.internal.Events) do
        Event:Destroy()
    end

    pcall(function()
        self.internal.Instance:Destroy()
    end)

    table.clear(self.internal)
    self.internal = nil
end


--// CLASS END
return Component