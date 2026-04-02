--// SERVICES
local Players: Players = game:GetService("Players")
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService: TweenService = game:GetService("TweenService")


--// DEPENDENCIES
local InterLink = require(ReplicatedStorage.Modules.InterLink)


--// TYPE DECLARATIONS
type Root<T> = InterLink.Root<T>
type Component<T> = InterLink.Component<T>


--// LOCAL VARIABLES
local Plr: Player = Players.LocalPlayer
local PlrGui: PlayerGui = Plr.PlayerGui
local BankDemoUi: ScreenGui = PlrGui:WaitForChild("BankDemoUi")


--// INTERLINK SET UP
local Root: Root<ScreenGui> = assert(InterLink.Root.new(BankDemoUi), "'uiRoot' cannot be nil.")
print(Root)
local balancesContainerComponent: Component<Frame> = assert(Root:GetById("balancesContainer"), "'transferAmountInput' cannot be nil.")

local transferAmountInput: Component<TextBox> = assert(Root:GetById("transferAmountInput"), "'transferAmountInput' cannot be nil.")
local transferFromInput: Component<TextBox> = assert(Root:GetById("transferFromInput"), "'transferFromInput' cannot be nil.")
local transferToInput: Component<TextBox> = assert(Root:GetById("transferToInput"), "'transferToInput' cannot be nil.")
local transferConfirmBtn: Component<TextBox> = assert(Root:GetById("transferConfirmBtn"), "'transformConfirmBtn' cannot be nil.")

local uiCloseBtn: Component<TextButton> = assert(Root:GetById("closeUiBtn"), "'closeUiBtn' cannot be nil.")


--// TWEEN INITIALIZATION
local hoverTween: TweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--// LOCAL PRIMARY FUNCTIONS


--// LOCAL CONNECTION FUNCTIONS
local function InitiateTransfer()
	local transferTextStripped: string = transferAmountInput.Text:gsub("%$", "")
	local transferAmount:number = tonumber(transferTextStripped) :: number
	local fromAccount:string = transferFromInput.Text
	local toAccount:string = transferToInput.Text

	print(`Initiating transfering of ${transferAmount} from {fromAccount} to {toAccount}.`)
end


local function AmountInputChanged(): ()
	local inputText: string = transferAmountInput.Text
	local filteredText: string = inputText:gsub("%D", "")
	local finalText: string = `${filteredText}`
	
	transferAmountInput.Text = finalText
	transferAmountInput.Instance.CursorPosition = (#finalText + 1)
end

local function Close()
	Root:Destroy()
end


--// CONNECTIONS
transferConfirmBtn.MouseButton1Click:Connect(InitiateTransfer)
uiCloseBtn.MouseButton1Click:Connect(Close)

transferAmountInput:GetPropertyChangedSignal("Text"):Connect(AmountInputChanged)

--// TWEEN-HANDLERS
transferConfirmBtn.MouseEnter:Connect(function()
	TweenService:Create(
		transferConfirmBtn.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.1, 1.1)}
	):Play()
end)

transferAmountInput.MouseEnter:Connect(function()
	TweenService:Create(
		transferAmountInput.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.1, 0.575)}
	):Play()
end)

transferFromInput.MouseEnter:Connect(function()
	TweenService:Create(
		transferFromInput.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.1, 0.575)}
	):Play()
end)

transferToInput.MouseEnter:Connect(function()
	TweenService:Create(
		transferToInput.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.1, 0.575)}
	):Play()
end)

transferConfirmBtn.MouseLeave:Connect(function()
	TweenService:Create(
		transferConfirmBtn.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.0, 1.0)}
	):Play()
end)

transferAmountInput.MouseLeave:Connect(function()
	TweenService:Create(
		transferAmountInput.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.0, 0.55)}
	):Play()
end)

transferFromInput.MouseLeave:Connect(function()
	TweenService:Create(
		transferFromInput.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.0, 0.55)}
	):Play()
end)

transferToInput.MouseLeave:Connect(function()
	TweenService:Create(
		transferToInput.Instance,
		hoverTween,
		{Size = UDim2.fromScale(1.0, 0.55)}
	):Play()
end)