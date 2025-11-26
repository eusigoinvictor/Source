-- Services
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")
local ServerStorage = game:GetService("ServerStorage")

-- Variables
local LeaderboardsController = {}
local TemplateCoinsLeaderboardPlayer = ReplicatedStorage.Assets.UI.CoinsLeaderboardPlayer
local CoinsLeaderboardData: OrderedDataStore = DataStoreService:GetOrderedDataStore("CoinsLeaderboard")

-- Functions
local function CreateLeaderboardPlayer(PlayerId: number, Rank: number, Coins: number): ()
	local NewPlayer = TemplateCoinsLeaderboardPlayer:Clone()
	PlayerId = tonumber(PlayerId)
	NewPlayer.Avatar.Image = Players:GetUserThumbnailAsync(PlayerId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
	NewPlayer.CoinsAmount.Text = Coins
	
	local UserData = UserService:GetUserInfosByUserIdsAsync({PlayerId})[1]
	
	pcall(function(): ()
		if UserData then
			NewPlayer.PlayerName.Text = UserData.DisplayName..`(@`..Players:GetNameFromUserIdAsync(PlayerId)..`)`
		else
			NewPlayer.PlayerName.Text = Players:GetNameFromUserIdAsync(PlayerId)..`(@{Players:GetNameFromUserIdAsync(PlayerId)})`
		end
	end)
	
	NewPlayer.PlayerPosition.Text = `#{Rank}`
	NewPlayer.LayoutOrder = Rank
	NewPlayer.Parent = ServerStorage.CoinsLeaderboardData
end

local function CreateCoinsLeaderboards(): ()
	local StorageLeaderboard = Instance.new("Folder", ServerStorage)
	StorageLeaderboard.Name = 'CoinsLeaderboardData'
	
	local Pages = CoinsLeaderboardData:GetSortedAsync(false, 50, 0, 10^10)
	local Page = Pages:GetCurrentPage()
	local Done = 0
	
	for Rank, Data in Page do
		local PlayerUserId = Data.key
		local Coins = Data.value
		
		if not PlayerUserId or not Coins then
			continue
		end
				
		task.spawn(CreateLeaderboardPlayer, PlayerUserId, Rank, Coins)
	end
	
	repeat task.wait() until #StorageLeaderboard:GetChildren() >= #Page
	
	for _, CoinsLeaderboard in CollectionService:GetTagged("CoinsLeaderboard") do
		for _, PlayerFrame in StorageLeaderboard:GetChildren() do
			local NewPlayerFrame = PlayerFrame:Clone()
			NewPlayerFrame.Parent = CoinsLeaderboard.Display.LeaderboardGui.Container
		end
	end
end

local function SyncCoinsLeaderboards(): ()
	local DataStore = DataStoreService:GetDataStore("PlayerData")
	local Pages: DataStorePages = DataStore:ListKeysAsync()
	
	while true do
		local KeyDatas = Pages:GetCurrentPage()
		
		for _, Data in KeyDatas do
			local Key = Data.KeyName
			
			pcall(function(): ()
				local PlayerData = DataStore:GetAsync(Key)
				
				if PlayerData and PlayerData.Coins then
					CoinsLeaderboardData:SetAsync(tonumber(Key), PlayerData.CoinsEarned)	
				end
			end)
		end
		
		if Pages.IsFinished then
			return
		end
		
		Pages:AdvanceToNextPageAsync()
		
		task.wait(1)
	end
end

local function Init(): ()
	CreateCoinsLeaderboards()
end

-- Public
LeaderboardsController.Init = Init

return LeaderboardsController