--// DEPENDENCIES
local Signal = require("@self/Objects/Signal")






--// TYPE EXPORTS
export type SignalConnection = Signal.SignalConnection
export type Signal<T...> = Signal.Signal<T...>


--[=[
@module SignaLuau

A lightweight, consumer-grade Luau module for implementing custom signals and signal connections, designed to closely mimic the built-in `RBXScriptSignal` and `RBXScriptConnection` behavior in Roblox.
]=]
return Signal