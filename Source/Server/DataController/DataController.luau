-- Services
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local DataStore = DataStoreService:GetDataStore("PlayerData")

-- Variables
local CoinsLeaderboard = DataStoreService:GetOrderedDataStore("CoinsLeaderboard")
local DataController = {
	['LoadedData'] = {}
}

local Template = {
	['Stage'] = 1,
	['Coins'] = 0,
	['CoinsEarned'] = 0,
	['Rebirths'] = 0,
	['Deaths'] = 0,
	['Items'] = {
		['Trails'] = {'Basic'}
	},
	
	['EquippedItems'] = {
		['Trails'] = 'Basic',
	}
}

-- Functions
local function DeepCopyTable(Table: table): table
	local Copy = {}

	for Key, Data in Table do
		if type(Data) == "table" then
			Copy[Key] = DeepCopyTable(Data)
		else
			Copy[Key] = Data
		end
	end
	
	return Copy
end

local function ReconcileTable(PlayerData: table, Template: table): ()
	for Key, Data in Template do
		if PlayerData[Key] == nil then
			if type(Data) == "table" then
				PlayerData[Key] = DeepCopyTable(Data)
			else
				PlayerData[Key] = Data
			end
		elseif type(PlayerData[Key]) == "table" and type(Data) == "table" then
			ReconcileTable(PlayerData[Key], Data)
		end
	end
end

local function Save(Player: Player): ()
	if not DataController.LoadedData[Player.UserId] then
		return warn('PlayerData not loaded on save.')	
	end
	
	local Sucess, Result = pcall(function() 
		return CoinsLeaderboard:SetAsync(Player.UserId, DataController.LoadedData[Player.UserId].CoinsEarned)
	end)
	
	local Sucess, Result = pcall(function() 
		return DataStore:SetAsync(Player.UserId, DataController.LoadedData[Player.UserId])
	end)
end

local function Load(Player: Player): table
	local Sucess, Result = pcall(function()
		return DataStore:GetAsync(Player.UserId)
	end)
	
	if not Sucess then
		Player:Kick('Failed on loading data, please rejoin.')
	end
	
	if not Result then
		Result = Template
	end
	
	ReconcileTable(Result, Template)
	
	DataController.LoadedData[Player.UserId] = Result
end

local function CreateLeaderstats(Player: Player): ()
	local function CreateLeaderstatValue(DataName: string)
		local PlayerData = DataController.LoadedData[Player.UserId]

		if not PlayerData then
			return 
		end

		local LeaderstatValue = Instance.new('IntValue')
		LeaderstatValue.Name = DataName
		LeaderstatValue.Value = PlayerData[DataName]
		LeaderstatValue.Parent = Player.leaderstats
		Player:SetAttribute(DataName, PlayerData[DataName])
		
		Player:GetAttributeChangedSignal(DataName):Connect(function(): ()
			LeaderstatValue.Value = Player:GetAttribute(DataName)
			
			-- Coin Leaderboard Update
			if DataName == 'Coins' then
				PlayerData.CoinsEarned += 1
			end	
		end)
	end
	
	local LeaderStats = Instance.new("Folder")
	LeaderStats.Name = 'leaderstats'
	LeaderStats.Parent = Player
	
	CreateLeaderstatValue('Stage')
	CreateLeaderstatValue('Rebirths')
	CreateLeaderstatValue('Coins')
end

local function OnServerInvoke(Player: Player): table
	return DataController.LoadedData[Player.UserId]
end

local function Init(): ()
	Players.PlayerAdded:Connect(function(Player: Player): ()
		Load(Player)
		CreateLeaderstats(Player)
	end)
	
	Players.PlayerRemoving:Connect(function(Player: Player): ()
		Save(Player)
	end)
end

-- Module
DataController.Init = Init
DataController.Template = Template
DataController.OnServerInvoke = OnServerInvoke

game:BindToClose(function()
	for _, Player in Players:GetPlayers() do
		task.spawn(Save, Player)
	end
	
	task.wait(1)
end)

return DataController