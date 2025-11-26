-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local StatsController = {}
local Remotes = ReplicatedStorage.Remotes
local RemoteEvent = Remotes.RemoteEvent
local Database = require(ReplicatedStorage.Modules.Database)

-- Functions
local function RefreshLeaderstats(Player: Player): ()
	local Leaderstats = Player:WaitForChild("leaderstats")
	local PlayerData = StatsController.Services.DataController.LoadedData[Player.UserId]
		
	for _, Stat in Leaderstats:GetChildren() do
		if PlayerData[Stat.Name] then
			Stat.Value = PlayerData[Stat.Name]
		end
	end
end

local function OnServerEvent(Player: Player, Arguments: table): ()
	local PlayerData = StatsController.Services.DataController.LoadedData[Player.UserId]	
		
	if Arguments.Rebirth then
		local PlayerStage = PlayerData.Stage
		local NewStartingStage = math.floor(PlayerStage / 10) * 10 - 9
		
		if math.floor(PlayerStage / 10) > PlayerData.Rebirths then
			local PlayerLeaderstats = Player:WaitForChild("leaderstats")
			PlayerData.Items = {['Trails'] = {'Basic'}}
			PlayerData.EquippedItems = {['Trails'] = nil}
			PlayerData.Coins = 0
			PlayerData.Stage = NewStartingStage
			PlayerData.Rebirths = (PlayerStage / 10)
			
			RefreshLeaderstats(Player)
		end
		
		Player:SetAttribute("Coins", PlayerData.Coins)
		Player:SetAttribute("Rebirths", PlayerData.Rebirths)
		
		RemoteEvent:FireClient(Player, "ItemsPageController", {RefreshTrails = true, PlayerData = PlayerData})

		StatsController.Services.ItemsController.UnequipItem(Player, Player.Character or Player.CharacterAdded:Wait(), 'Trails')
		StatsController.Services.TeleportController.SetStage(Player, NewStartingStage)
	end	
end

-- Public
StatsController.RefreshLeaderstats = RefreshLeaderstats
StatsController.OnServerEvent = OnServerEvent

return StatsController