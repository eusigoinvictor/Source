-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local TeleportPageController = {}
local Database = require(ReplicatedStorage.Modules.Database)
local Remotes = ReplicatedStorage.Remotes
local RemoteFunction = Remotes.RemoteFunction
local RemoteEvent = Remotes.RemoteEvent
local LocalPlayer = Players.LocalPlayer
local Pages = LocalPlayer.PlayerGui:WaitForChild("Pages")
local TeleportPage = Pages.Teleport

-- Functions
local function UpdateMapsAvailability(Stage: number): ()
	for _, Map: Frame in TeleportPage.Container:GetChildren() do
		if not Map:IsA("Frame") then
			continue
		end
		
		for _, JoinButton in Map:GetChildren() do
			local ButtonStage = tonumber(JoinButton.Name)
			
			if not ButtonStage then
				continue
			end
			
			local IsLocked = ButtonStage + (Map:GetAttribute("Index") - 1) * 5 > Stage
			JoinButton.Locked.Visible = IsLocked
			JoinButton.Title.TextTransparency = IsLocked and 1 or 0	
		end
	end
end

local function AddMaps(): ()
	local PlayerData = RemoteFunction:InvokeServer("DataController")
		
	for MapIndex, MapSettings in Database.Maps do
		local MapName = MapSettings.Name
		local MapImageId = MapSettings.Image
		
		local NewMap = ReplicatedStorage.Assets.UI.Map:Clone()
		NewMap.Title.Text = MapName
		NewMap.Thumbnail.Image = MapImageId
		NewMap:SetAttribute("Index", MapIndex)
		NewMap.LayoutOrder = MapIndex
		NewMap.Name = MapName
		NewMap.Locked.Visible = MapIndex > PlayerData.Stage
		NewMap.Parent = TeleportPage.Container		
	end
end

local function AccountJoinButtons(): ()
	for _, Map in TeleportPage.Container:GetChildren() do
		if not Map:IsA("Frame") then
			continue
		end
		
		for _, JoinButton in Map:GetChildren() do
			if not tonumber(JoinButton.Name) then
				continue
			end
			
			JoinButton.MouseEnter:Connect(function(): ()
				TeleportPageController.Services.SoundController.PlaySound("UIHover")	
				TweenService:Create(JoinButton, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(164, 166, 255)}):Play()
			end)

			JoinButton.MouseLeave:Connect(function(): ()
				TweenService:Create(JoinButton, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(21, 24, 58)}):Play()
			end)

			JoinButton.Button.Activated:Connect(function(): ()
				TeleportPageController.Services.SoundController.PlaySound("UIClick")	
				TeleportPageController.Services.HudController.SwitchHudVisibility(true)
				RemoteEvent:FireServer("TeleportController", {TeleportStage = tonumber(JoinButton.Name) + (Map:GetAttribute("Index") - 1) * 5})
				TweenService:Create(TeleportPage, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()
			end)
		end
	end
end

local function OnClientEvent(Arguments: table): ()
	if Arguments.UpdateMaps then
		UpdateMapsAvailability(Arguments.PlayerData.Stage)
	end
end

local function Init(): ()
	AddMaps()
	AccountJoinButtons()
	
	repeat task.wait() until LocalPlayer:GetAttribute("CurrentStage")
	
	UpdateMapsAvailability(LocalPlayer:GetAttribute("CurrentStage"))
end

-- Public
TeleportPageController.OnClientEvent = OnClientEvent
TeleportPageController.Init = Init

return TeleportPageController