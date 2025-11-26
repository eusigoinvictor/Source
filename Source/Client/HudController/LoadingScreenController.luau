-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

-- Variables
local LoadingScreenController = {}
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local LoadingScreen = PlayerGui:WaitForChild("Hud", math.huge).Loading
local MovingFrame = LoadingScreen.MovingFrame
local Title = LoadingScreen.Title
local Database = require(ReplicatedStorage.Modules.Database)

-- Functions
local function SetLoadingScreenVisibility(Visible: boolean): ()
	TweenService:Create(LoadingScreen, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, Visible and 0.5 or 3)}):Play()
	
	task.wait(1/6)
	
	LoadingScreen.Visible = Visible
end

local function LoadBiomes(): ()
	for Index, Map in Database.Maps do
		local NewBiome = ReplicatedStorage.Assets.UI.LoadingScreenBiome:Clone()
		NewBiome.Image = Map.MinimapId
		NewBiome.LayoutOrder = Index
		NewBiome.Parent = MovingFrame
	end
	
	local NewBiome = ReplicatedStorage.Assets.UI.LoadingScreenBiome:Clone()
	NewBiome.Image = Database.Maps[1].MinimapId
	NewBiome.LayoutOrder = #Database.Maps + 1
	NewBiome.Parent = MovingFrame
end

local function AnimateBiomes(): ()
	local Time = 4
	Time = Time * #Database.Maps
	
	local InitialX = MovingFrame.Position.X.Scale
	
	while true do
		TweenService:Create(MovingFrame, TweenInfo.new(Time, Enum.EasingStyle.Linear), {Position = UDim2.fromScale(InitialX - 0.57 * #Database.Maps, 0.75)}):Play()
		task.wait(Time)
		MovingFrame.Position = UDim2.fromScale(InitialX, 0.75)
	end
end

local function AnimateTitle(): ()
	local Style = Enum.EasingStyle.Linear
	local Direction = Enum.EasingDirection.In
	local Time = 6
	
	while true do
		TweenService:Create(Title, TweenInfo.new(Time, Style, Direction), {Rotation = 6, Size = UDim2.fromScale(0.3, 0.3)}):Play()
		
		task.wait(Time)
		
		TweenService:Create(Title, TweenInfo.new(Time, Style, Direction), {Rotation = 0, Size = UDim2.fromScale(0.225, 0.25)}):Play()
			
		task.wait(Time)

		TweenService:Create(Title, TweenInfo.new(Time, Style, Direction), {Rotation = -6, Size =UDim2.fromScale(0.3, 0.3)}):Play()
		
		task.wait(Time)	
		
		TweenService:Create(Title, TweenInfo.new(Time, Style, Direction), {Rotation = 0, Size = UDim2.fromScale(0.225, 0.25)}):Play()

		task.wait(Time)
	end
end

local function ListenLoad(): ()
	LocalPlayer:GetAttributeChangedSignal("Loading"):Connect(function(): ()		
		if not LocalPlayer:GetAttribute("Loading") then
			return
		end
		
		SetLoadingScreenVisibility(true)
		task.wait(3)
		SetLoadingScreenVisibility(false)
	end)
end

local function Init(): ()
	task.spawn(LoadBiomes)
	task.spawn(AnimateBiomes)
	task.spawn(AnimateTitle)
	task.spawn(ListenLoad)
	
	SetLoadingScreenVisibility(true)
	
	task.wait(10)
	
	SetLoadingScreenVisibility(false)
end

-- Public
LoadingScreenController.Init = Init

return LoadingScreenController