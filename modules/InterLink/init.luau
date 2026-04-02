--// DEPENDENCIES
local e = require("./Exceptions")

local Root = require("@self/Objects/Root")


--// TYPE DECLARATIONS
type Exception = e.Exception

export type Component<T> = Root.Component<T>
export type Root<T> = Root.Root<T>


--[=[
@class InterLink

A small component framework providing identity, tags, attributes, events, and deterministic lifecycles for Instance hierarchies.
Designed to be lightweight and robust, InterLink aims to reducde bloat and streamline development.

Example Usage:
```lua
--// DEPENDENCIES
local Interlink = require(game.ReplicatedStorage.Modules.InterLink)


--// TYPE DECLARATIONS
type Root<T> = InterLink.Root<T>
type Component<T> = InterLink.Component<T>

--// LOCAL VARIABLES
local randomFolder: Folder = game.Workspace:WaitForChild("RandomFolder")


--// INTERLINK
local Root: Root<Folder> = assert(Interlink.Root.new(randomFolder), "'Root' cannot be nil.")
local testObj1: Component<Part> = assert(Root:GetById("testObj1"), "'testObj1' cannot be nil.")


--// CONNECTION FUNCTIONS
local function partTouched()
	print("testObj1 was touched!")
end

local function testEvent(...)
	print(...)
end


--// CONNECTIONS
testObj1.Touched:Connect(partTouched)

-- Anything referenced in a component that is not a valid property of
-- the component or its instance will automatically be turned into a SignaLuau signal.
testObj1.testEvent:Connect(testEvent)


--// MISC
testObj1.testEvent:Fire("Hello, world!")
```
]=]
return {
    Root = Root
}