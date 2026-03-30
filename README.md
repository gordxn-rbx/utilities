# SignaLuau

SignaLuau is a lightweight, consumer-grade Luau module for implementing custom signals and signal connections, designed to closely mimic the built-in `RBXScriptSignal` and `RBXScriptConnection` behavior in Roblox. It is ideal for use in both game and library development, providing a familiar and robust event system.

---

## Features

- **Familiar API:** Nearly identical to Roblox's built-in signals (`Connect`, `Once`, `Wait`, `Fire`, `FireAsync`, `Destroy`).
- **Lightweight:** Minimal overhead, no dependencies, and no use of userdata or weak tables.
- **Type Safety:** Full type annotations for use with Luau type checking.
- **Safe Callback Handling:** Iterates over a copy of listeners to avoid mutation issues.
- **Connection State:** Exposes a `.Connected` property on connections.
- **Immutability:** Prevents accidental property assignment on signals and connections.

---

## Installation

Place the `SignaLuau` folder in your `ReplicatedStorage` or another shared location in your Roblox project. Require it as a module:

```lua
local SignaLuau = require("path/to/SignaLuau")
```

---

## API Reference

### Signal

#### Methods

- **`Signal.new(): Signal`**  
	Creates a new signal instance.

- **`Signal:Connect(callback: (...any) -> ...any): SignalConnection`**  
	Connects a callback to the signal. Returns a `SignalConnection` object.

- **`Signal:Once(callback: (...any) -> ...any): SignalConnection`**  
	Connects a callback that will be called only once, then automatically disconnected.

- **`Signal:Wait(): ...any`**  
	Yields the current thread until the signal is fired, then returns the arguments.

- **`Signal:Fire(...: any): ()`**  
	Invokes all connected callbacks with the given arguments synchronously.

- **`Signal:FireAsync(...: any): ()`**  
	Invokes all connected callbacks asynchronously using `task.spawn`.

- **`Signal:Destroy(): ()`**  
	Disconnects all listeners and renders the signal unusable.

---

### SignalConnection

#### Properties

- **`SignalConnection.Connected: boolean`**  
	Indicates whether the connection is still active.

#### Methods

- **`SignalConnection:Disconnect(): ()`**  
	Disconnects the callback from the signal.

---

## Usage Examples

### Basic Signal Usage

```lua
local SignaLuau = require("@game/ReplicatedStorage/SignaLuau")
local Signal = SignaLuau.Signal

local mySignal = Signal.new()

local connection = mySignal:Connect(function(message)
		print("Received:", message)
end)

mySignal:Fire("Hello, world!") -- Output: Received: Hello, world!

connection:Disconnect()
mySignal:Fire("This will not be printed")
```

---

### Using `Once` and `Wait`

```lua
local SignaLuau = require("@game/ReplicatedStorage/SignaLuau")
local Signal = SignaLuau.Signal

local mySignal = Signal.new()

mySignal:Once(function(msg)
		print("Once received:", msg)
end)

mySignal:Fire("First") -- Output: Once received: First
mySignal:Fire("Second") -- No output

-- Wait for a signal in a coroutine
task.spawn(function()
		local result = mySignal:Wait()
		print("Waited for:", result)
end)

task.wait(3)
mySignal:Fire("Waited value") -- Output: Waited for: Waited value
```

---

### Integrating with Custom Objects

```lua
local SignaLuau = require("@game/ReplicatedStorage/SignaLuau")
local Signal = SignaLuau.Signal

local Object = {}
Object.__index = Object

function Object.new(name, value)
		local self = setmetatable({}, Object)
		self.Name = name
		self.Value = value
		self.ValueUpdated = Signal.new()
		return self
end

function Object:UpdateValue(newValue)
		self.Value = newValue
		self.ValueUpdated:Fire(newValue)
end

-- Usage
local obj = Object.new("Test", "Initial")
obj.ValueUpdated:Connect(function(newVal)
		print("Value updated to:", newVal)
end)
obj:UpdateValue("New Value") -- Output: Value updated to: New Value
```

---

## Best Practices

- Always disconnect connections you no longer need to avoid memory leaks.
- Use `Once` for one-time events to simplify cleanup.
- Use `Destroy` on signals when the owning object is destroyed to clean up all listeners.

---

## License

MIT License

---

## Credits

SignaLuau is inspired by the Roblox engine's signal system and aims to provide a familiar, robust, and lightweight alternative for custom use cases.
