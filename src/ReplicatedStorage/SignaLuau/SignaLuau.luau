--// DEPENDENCIES
local Signal = require("@self/Objects/Signal")


--// MODULE DECLARATION
local Framework = {}


--// CLASS DECLARATIONS
Framework.Signal = Signal


--// TYPE EXPORTS
export type SignalConnection = Signal.SignalConnection
export type Signal = Signal.Signal


--// MODULE END
return Framework