-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Database = require(ReplicatedStorage.Modules.Database)

-- Variables
local Player = Players.LocalPlayer
local Pages = Player.PlayerGui:WaitForChild("Pages")
local LeaderboardSelection = Pages.LeaderboardSelection
local RemoteFunction = ReplicatedStorage.Remotes.RemoteFunction
local RemoteEvent = ReplicatedStorage.Remotes.RemoteEvent

-- Private
local LeaderboardSelectionController = {}

local function GenerateMapButtons(): ()
	local MapContainer = ReplicatedStorage.Assets.UI.LeaderboardSelection.Map

	for MapIndex, Data in Database.Maps do
		local NewMapContainer = MapContainer:Clone() 
		NewMapContainer.Title.Text = Data.Name
		NewMapContainer.Icon.Image = Data.Image
		NewMapContainer.Credits.Text = Data.Credits and `By @{Data.Credits}` or ''
		NewMapContainer.Parent = LeaderboardSelection.Container
	end
end

local function MapButtonEvents(): ()
	for _, MapContainer in LeaderboardSelection.Container:GetChildren() do
		if not MapContainer:IsA("Frame") then
			continue
		end

		MapContainer.MouseEnter:Connect(function()
			TweenService:Create(MapContainer.Background, TweenInfo.new(1/6), {BackgroundTransparency = 0.3}):Play()
			TweenService:Create(MapContainer.UIScale, TweenInfo.new(1/6), {Scale = 1.0625}):Play()
		end)

		MapContainer.MouseLeave:Connect(function()
			TweenService:Create(MapContainer.Background, TweenInfo.new(1/6), {BackgroundTransparency = 0.5}):Play()
			TweenService:Create(MapContainer.UIScale, TweenInfo.new(1/6), {Scale = 1}):Play()
		end)

		MapContainer.Button.Activated:Connect(function()
			TweenService:Create(Pages.LeaderboardSelection, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()
			TweenService:Create(Pages.GlobalLeaderboards, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
			RemoteEvent:FireServer("LeaderboardsController", {MapName = MapContainer.Title.Text})
		end)
	end
end

local function GlobalCloseButton(): ()
	Pages.GlobalLeaderboards.CloseButton.MouseEnter:Connect(function()
		TweenService:Create(LeaderboardSelection.CloseButton.X, TweenInfo.new(1/6), {Rotation = 22.5}):Play()
	end)

	Pages.GlobalLeaderboards.CloseButton.MouseLeave:Connect(function()
		TweenService:Create(LeaderboardSelection.CloseButton.X, TweenInfo.new(1/6), {Rotation = 0}):Play()
	end)

	Pages.GlobalLeaderboards.CloseButton.Button.Activated:Connect(function()
		TweenService:Create(Pages.GlobalLeaderboards, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()

		for _, Playerstat in Pages['GlobalLeaderboards'].Container:GetChildren() do
			if Playerstat.Name ~= 'GlobalPlayerStats' then
				continue
			end

			Playerstat:Destroy()
		end

		TweenService:Create(Pages.LeaderboardSelection, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
	end)
end

local function CloseButton(): ()
	LeaderboardSelection.CloseButton.MouseEnter:Connect(function()
		TweenService:Create(LeaderboardSelection.CloseButton.X, TweenInfo.new(1/6), {Rotation = 22.5}):Play()
	end)

	LeaderboardSelection.CloseButton.MouseLeave:Connect(function()
		TweenService:Create(LeaderboardSelection.CloseButton.X, TweenInfo.new(1/6), {Rotation = 0}):Play()
	end)

	LeaderboardSelection.CloseButton.Button.Activated:Connect(function()
		TweenService:Create(LeaderboardSelection, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()

		LeaderboardSelectionController.Services.MenuController.SwitchButtonsVisibility()
	end)
end

local function Init(): ()
	GenerateMapButtons()
	MapButtonEvents()
	CloseButton()
	GlobalCloseButton()
end

-- Public
LeaderboardSelectionController.Init = Init

return LeaderboardSelectionController