-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local InfoDisplay = ReplicatedStorage.Assets.UI.InfoDisplay
local CharactersController = {}

-- Functions
local suffixes = {"K", "M", "B", "T", "Q"} -- numbers don't go higher than 'Q' in Lua.

local function AbbreviateNumber(Number: number): ()
	local i = math.floor(math.log(Number, 1e3))
	local v = math.pow(10, i * 3)
	
	return ("%.1f"):format(Number / v):gsub("%.?0+$", "") .. (suffixes[i] or "")
end

local function RemoveCollisions(Character: Model): ()
	for _, BasePart in Character:GetChildren() do
		if not BasePart:IsA("BasePart") then
			continue
		end

		BasePart.CollisionGroup = "Player"
	end
end

local function AccountInfoDisplay(Player: Player): ()
	Player.CharacterAdded:Connect(function(Character: Model): ()
		repeat task.wait() until CharactersController.Services.DataController.LoadedData[Player.UserId]
		
		local LoadedDeaths = CharactersController.Services.DataController.LoadedData[Player.UserId].Deaths
		local NewInfoDisplay = InfoDisplay:Clone()
		NewInfoDisplay.Deaths.Amount.Text = LoadedDeaths
		NewInfoDisplay.Parent = Character
		
		Player:GetAttributeChangedSignal("Deaths"):Connect(function(): ()
			NewInfoDisplay.Deaths.Amount.Text = Player:GetAttribute("Deaths")
			NewInfoDisplay.Deaths.Amount.Text = AbbreviateNumber(NewInfoDisplay.Deaths.Amount.Text)
		end)
	end)
end

local function AccountPlayer(Player: Player): ()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	RemoveCollisions(Character)

	Player.CharacterAdded:Connect(RemoveCollisions)
end

local function Init(): ()
	Players.PlayerAdded:Connect(function(Player: Player): ()
		task.spawn(AccountPlayer, Player)
		task.spawn(AccountInfoDisplay, Player)
	end)
end

-- Public
CharactersController.Init = Init

return CharactersController