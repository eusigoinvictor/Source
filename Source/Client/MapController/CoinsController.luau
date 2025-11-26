-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Hud = PlayerGui:WaitForChild("Hud")
local Remotes = ReplicatedStorage.Remotes
local RemoteFunction = Remotes.RemoteFunction
local RemoteEvent = Remotes.RemoteEvent
local CoinsController = {}

-- Functions
local function CoinPickupAnimation(Coin: MeshPart): ()
	local Origin = Coin:GetPivot()
	TweenService:Create(Coin, TweenInfo.new(1/3), {CFrame = Coin:GetPivot() * CFrame.fromOrientation(0, math.rad(180), 0) + Vector3.new(0, 2, 0), Transparency = 1}):Play()
	
	repeat task.wait() until Coin:GetAttribute(LocalPlayer.UserId)
	
	repeat task.wait() until not Coin:GetAttribute(LocalPlayer.UserId)
	
	TweenService:Create(Coin, TweenInfo.new(1), {CFrame = Origin, Transparency = 0}):Play()
end

local function CoinIdleAnimation(Coin: MeshPart): ()
	while task.wait(1) do
		if Coin:GetAttribute(LocalPlayer.UserId) then
			continue
		end
		
		TweenService:Create(Coin, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = Coin:GetPivot() * CFrame.fromOrientation(0, math.pi, 0)}):Play()
	end		
end

local function CoinsIdleAnimation(): ()
	local Coins = CollectionService:GetTagged("Coin")
	
	CollectionService:GetInstanceAddedSignal("Coin"):Connect(CoinIdleAnimation)
	
	for _, Coin in Coins do
		task.spawn(CoinIdleAnimation, Coin)
	end
end

local function AddOneCoinToHud(Player: Player): ()
	local PlayerGui = 	Player.PlayerGui
	local Hud = PlayerGui:WaitForChild("Hud")
	local TextLabel = Hud.Currency.Coins.TextLabel
	local CurrentAmount = tonumber(TextLabel.Text)
	Hud.Currency.Coins.TextLabel.Text = CurrentAmount + 1 
end

local function OnCoinPickup(BasePart: BasePart, Coin: MeshPart): ()
	local ModelAncestor = BasePart:FindFirstAncestorWhichIsA("Model")
	local Player = Players:GetPlayerFromCharacter(ModelAncestor)

	if not Player then
		return
	end
	
	if Player ~= LocalPlayer then
		return
	end

	if Coin:GetAttribute(LocalPlayer.UserId) then
		return -- Coin is in cooldown
	end
	
	local CoinUUID = Coin:GetAttribute("UUID")
	Coin:SetAttribute(LocalPlayer.UserId, true)

	CoinsController.Services.SoundController.PlaySound("CoinPickup")

	RemoteEvent:FireServer("EconomyController", {CoinPickup = CoinUUID})
	CoinPickupAnimation(Coin)
end

local function ListenCoinPickup(Coin: MeshPart): ()
	Coin.Touched:Connect(function(BasePart: BasePart): ()
		OnCoinPickup(BasePart, Coin)
	end)	
end

local function ListenCoinsPickup(): ()
	local Coins = CollectionService:GetTagged("Coin")
	
	for _, Coin in Coins do
		ListenCoinPickup(Coin)
	end
	
	CollectionService:GetInstanceAddedSignal("Coin"):Connect(ListenCoinPickup)
end

local function Init(): ()
	ListenCoinsPickup()
	CoinsIdleAnimation()
end

-- Public
CoinsController.Init = Init

return CoinsController