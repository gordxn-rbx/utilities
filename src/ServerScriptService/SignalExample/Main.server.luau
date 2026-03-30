local SignaLuau = require("@game/ReplicatedStorage/SignaLuau")
type SignalConnection = SignaLuau.SignalConnection
type Signal = SignaLuau.Signal

local Object = require("@game/ReplicatedStorage/Shared/Object")
type Object = Object.Object

local testObject: Object = Object.new("Test", "")

local testConn: SignalConnection = testObject.ValueUpdated:Connect(function(newValue: string)
    print(newValue)
    print(testObject.Value)
end)

testObject:UpdateValue("testValue1")
testConn:Disconnect()
testObject:UpdateValue("testValue2")