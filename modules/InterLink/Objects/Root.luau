--// DEPENDENCIES
local Config = require("../Config")
local Exceptions = require("../Shared/Exceptions")
local e = require("../../Exceptions")

local Component = require("./Component") 


--[=[
@within InterLink
@class Root

A 'Root' object is the wrapper for all 'Component' objects within it's physical instance.
It will not search and wrap objects outside of its own descendants.
]=]
local Root = {}
Root.__index = function(table: {}, key: any): (unknown)
    local internal = rawget(table, "internal")
    if (internal ~= nil) and (internal[key] ~= nil) then
		return internal[key]
	end

	return rawget(Root, key)
end

Root.__newindex = function()
    if (Config.Verbose == true) then
        warn(`[InterLink] Roots are read-only, only valid properties of an instance are mutable. Silence warnings by setting 'Verbose' to 'false'.`)
    end
end



type Exception = e.Exception
export type Component<T> = Component.Component<T>

--[=[
@within Root
@interface Root<T>
@field Instance T
@field Components { [string]: Component<any> }
@field Tags { [string]: { [string]: boolean } }
@field Attributes { [string]: { [string]: { [string]: boolean } } }
@field GetById <U>(self: Root<T>, queryId: string) -> (Component<U>?),
@field GetByTag (self: Root<T>, queryTag: string) -> ({ Component<any> }),
@field GetByAttribute (self: Root<T>, queryAttribute: string, value: any) -> ({ Component<any> }),
@field Destroy (self: Root<T>) -> ()
]=]
export type Root<T> = {
    Instance: T,
    Components: {
        [string]: Component<any>
    },
    Tags: {
        [string]: {
            [string]: boolean
        }
    },
    Attributes: {
        [string]: {
            [string]: {
                [string]: boolean
            }
        }
    },

    GetById: <U>(self: Root<T>, queryId: string) -> (Component<U>?),
    GetByTag: (self: Root<T>, queryTag: string) -> ({ Component<any> }),
    GetByAttribute: (self: Root<T>, queryAttribute: string, value: any) -> ({ Component<any> }),
    Destroy: (self: Root<T>) -> ()
}

local function UnregisterComponent(self: Root<any>, component: Instance)
    local componentId: string = component:GetAttribute("id") :: string
    
    if (componentId == nil) then
        return 
    end

    if (componentId == "") or (type(componentId) ~= "string") then
        return
    end

    if (not self.internal.Components[componentId]) then
        return
    end
    
    local componentElement = self.internal.Components[componentId]

    for _: any, tag: any in pairs(componentElement.Tags) do
        if (self.internal.Tags[tag] == nil) then
            continue
        end

        self.internal.Tags[tag][componentElement.Id] = nil

        if (next(self.internal.Tags[tag]) == nil) then
            self.internal.Tags[tag] = nil
        end
    end

    for name: string, value: any in pairs(componentElement.Attributes) do
        if (self.internal.Attributes[name] == nil) then
            continue
        end

        if (self.internal.Attributes[name][value] == nil) then
            continue
        end

        self.internal.Attributes[name][value][componentElement.Id] = nil

        if (next(self.internal.Attributes[name][value]) == nil) then
            self.internal.Attributes[name][value] = nil
        end
    end

    self.internal.Components[componentId] = nil
    componentElement:Destroy()
end

local function RegisterComponent(self: Root<any>, component: Instance)
    local componentId: string = component:GetAttribute("id") :: string
    
    if (componentId == nil) then
        return 
    end

    if (componentId == "") or (type(componentId) ~= "string") then
        e.Throw(Exceptions.InvalidComponentId, "RegisterComponent()", componentId)
        return
    end 

    if (self.internal.Components[componentId]) then
        e.Throw(Exceptions.ComponentAlreadyExists, "RegisterComponents()", componentId)
        return
    end
    
    local componentElement = Component.new(componentId, component)

    for _: any, tag: any in pairs(componentElement.Tags) do
        if (self.internal.Tags[tag] == nil) then
            self.internal.Tags[tag] = {}
        elseif (self.internal.Tags[tag][componentElement.Id]) then
            continue
        end

        self.internal.Tags[tag][componentElement.Id] = true
    end

    for name: string, value: any in pairs(componentElement.Attributes) do
        if (self.internal.Attributes[name] == nil) then
            self.internal.Attributes[name] = {}
        end

        if (self.internal.Attributes[name][value] == nil) then
            self.internal.Attributes[name][value] = {}
        elseif (self.internal.Attributes[name][value][componentElement.Id]) then
            continue
        end

        self.internal.Attributes[name][value][componentElement.Id] = true
    end

    self.internal.Components[componentId] = componentElement
end

local function RegisterComponents(self: Root<any>)
    for _, component: Instance in pairs(self.internal.Instance:QueryDescendants("[$id]")) do
		RegisterComponent(self, component)
    end
end

--[=[
@param root Instance
@return Root<T>

Returns a constructed 'Root' object with generic type 'T'.
]=]
function Root.new<T>(root: T & Instance): (Root<T>)
    if (root == nil) or (typeof(root) ~= "Instance") then
        e.Throw(Exceptions.InvalidArgument, "Root.new()", "root", "Instance")
        return nil
    end

    local internal = {
        Instance = root,
        Components = {},
        Tags = {},
        Attributes = {},
        Middleware = {},
    }

    local self = {
        internal = internal
    }

    self.internal.DescendantAdded = root.DescendantAdded:Connect(function(instance: Instance)
        RegisterComponent(self, instance)
    end)

    self.internal.DescendantRemoving = root.DescendantRemoving:Connect(function(instance: Instance)
        UnregisterComponent(self, instance)
    end)

    RegisterComponents(self)

    return setmetatable(self, Root)
end


--[=[
@param queryId string
@return Component<T>

Returns the component with the specified id if found, otherwise returning nil.
]=]
function Root:GetById<T>(queryId: string): Component<T>?
    if (queryId == nil) or (type(queryId) ~= "string") then
        e.Throw(Exceptions.InvalidArgument, "Root:GetById()", "queryId", "string")
        return
    end

    return self.internal.Components[queryId]
end

--[=[
@param queryTag string
@return { Component<any> }

Returns a table of components with the specified tag if found, otherwise returning {}.
]=]
function Root:GetByTag(queryTag: string): ({ Component<any> })
    if (queryTag == nil) or (type(queryTag) ~= "string") then
        e.Throw(Exceptions.InvalidArgument, "Root:GetByTag()", "queryTag", "string")
        return {}
    end

    local tagsBucket: { [string]: boolean } = self.internal.Tags[queryTag] or {}
    local returnBucket: { Component<any> } = {}

    for id: any, _: boolean in pairs(tagsBucket) do
        table.insert(returnBucket, self:GetById(id))
    end

    return returnBucket
end

--[=[
@param queryAttribute string
@param value any
@return { Component<any> }

Returns a table of components with the specified attribute and specified value if found, otherwise returning {}.
]=]
function Root:GetByAttribute(queryAttribute: string, value: any): ({ Component<any> })
    if (queryAttribute == nil) or (type(queryAttribute) ~= "string") then
        return {}
    end

    if (value == nil) then
        e.Throw(Exceptions.InvalidArgument, "Root:GetByAttribute()", "value", "any")
        return {}
    end

    if (self.internal.Attributes[queryAttribute] == nil) then
        e.Throw(Exceptions.InvalidTableIndex, "Root:GetByAttribute()", queryAttribute, "self.Attributes")
        return {}
    end
    
    local atrributesBucket: { [string]: boolean } = self.internal.Attributes[queryAttribute][value] or {}
    local returnBucket: { Component<any> } = {}

    for id: string, _: boolean in pairs(atrributesBucket) do
        table.insert(returnBucket, self:GetById(id))
    end

    return returnBucket
end

--[=[
Destroys the root, which includes destroying any related components as well as the instance it wraps.
]=]
function Root:Destroy()
    self.internal.DescendantAdded:Disconnect()
    self.internal.DescendantRemoving:Disconnect()

    for _, component: Component<any> in pairs(self.internal.Components) do
        component:Destroy()
    end

    pcall(function()
        self.internal.Instance:Destroy()
    end)

    table.clear(self.internal)
    self.internal = nil
end


--// CLASS END
return Root