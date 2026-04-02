--// DEPENDENCIES
local e = require("../../Exceptions")

--// TYPE DECLARATIONS
type Exception = e.Exception

return {
    InvalidArgument = e.new("'%s' must be a valid argument of type '%s' and not nil.", true, warn),
    InvalidTableIndex = e.new("Index of '%s' was not found in table '%s'.", true, warn),
    InvalidComponentId = e.new("Component's 'id' of '%s' is not a valid string.", true, warn),
    ComponentAlreadyExists = e.new("Component with 'id' of '%s' was found more than once, using the first element found.", true, warn)
} :: {
    [string]: Exception
}