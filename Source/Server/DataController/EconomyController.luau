-- Services
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Variables
local EconomyController = {}
local CoinInterval = 15
local RemoteEvent = Remotes.RemoteEvent
local Database = require(ReplicatedStorage.Modules.Database)

-- Functions
local function GenerateCoinsUUID(): ()
	local Coins = CollectionService:GetTagged("Coin")
	
	for _, Coin in Coins do
		Coin:SetAttribute("UUID", HttpService:GenerateGUID())
		Coin:SetAttribute("Origin", Coin:GetPivot())
	end
end

local function BuyItem(Player: Player, Arguments: table): boolean
	local ItemName = Arguments.ItemName
	local Category = Arguments.Category
	local ItemData = Database[Category][ItemName]

	if not ItemData then
		return warn(`Unable to find item data of {Category}: {ItemName} while attempting a purchase.`)
	end

	local Cost = ItemData.Cost
	local PlayerData = EconomyController.Services.DataController.LoadedData[Player.UserId]

	if PlayerData.Coins >= Cost then
		PlayerData.Coins -= Cost
		table.insert(PlayerData.Items[Category], ItemName)
		Player:SetAttribute("Coins", PlayerData.Coins)

		return true	
	end

	return false
end

local function CoinPickup(Player: Player, PlayerCoinUUID: string): ()
	local Coins = CollectionService:GetTagged("Coin")
	local PlayerCoin
		
	for _, Coin in Coins do
		local UUID = Coin:GetAttribute("UUID")
		
		if not UUID then
			warn('One of the coins has no UUID')
			
			continue	
		end
		
		if PlayerCoinUUID ~= UUID then
			continue
		end
		
		PlayerCoin = Coin
	end
	
	if not PlayerCoin then
		return warn('UUID of coin sent by player has no matches in server.')
	end
	
	if PlayerCoin:GetAttribute(Player.UserId) then
		return warn('Player has already picked up this coin in set interval.')
	end
	
	local PlayerData = EconomyController.Services.DataController.LoadedData[Player.UserId]
	PlayerData.Coins += 1
	PlayerCoin:SetAttribute(Player.UserId, true)
	
	task.delay(CoinInterval, function(): ()
		PlayerCoin:SetAttribute(Player.UserId, nil)
	end)	
	
	Player:SetAttribute("Coins", PlayerData.Coins)
end

local function OnServerInvoke(Player: Player, Arguments: table): boolean
	if Arguments.Buy then
		return BuyItem(Player, Arguments)
	end
end

local function OnServerEvent(Player: Player, Arguments: table): ()
	if Arguments.CoinPickup then
		CoinPickup(Player, Arguments.CoinPickup)
	end
end

local function Init(): ()
	GenerateCoinsUUID()
end

-- Public
EconomyController.Init = Init
EconomyController.OnServerInvoke = OnServerInvoke
EconomyController.OnServerEvent = OnServerEvent

return EconomyController