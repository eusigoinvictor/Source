-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local StageIndicatorController = {}
local ArrowIndicatorTemplate = ReplicatedStorage.Assets.UI.ArrowIndicator
local LocalPlayer = Players.LocalPlayer
local Database = require(ReplicatedStorage.Modules.Database)
local PlayerGui = LocalPlayer.PlayerGui
local Hud = PlayerGui:WaitForChild("Hud")
local StageIndicator = Hud.StageIndicator

-- Functions
local function FetchCurrentMapIndex(): number
	local LocalPlayerStage = LocalPlayer:GetAttribute("CurrentStage")
	local MapIndex: number

	-- Fetch max stage on current map
	if LocalPlayerStage % 5 == 0 then
		MapIndex = LocalPlayerStage / 5
	elseif LocalPlayerStage % 5 ~= 0 then
		local MaxStage = LocalPlayerStage

		while MaxStage % 5 ~= 0 do
			MaxStage += 1
		end

		MapIndex = MaxStage / 5
	end
	
	return MapIndex
end

local function UpdateMinimap(): ()
	local Minimap = Hud.StageIndicator.Image
	local CurrentStage = tonumber(LocalPlayer:GetAttribute("CurrentStage"))
	local CurrentMap = Database.Maps[FetchCurrentMapIndex()]

	if not CurrentMap or CurrentMap and not CurrentMap.MinimapId then
		Minimap.Image = ''
	end

	Minimap.Image = CurrentMap.MinimapId
end

local function HandleMinimap(): ()
	LocalPlayer:GetAttributeChangedSignal("CurrentStage"):Connect(UpdateMinimap)	
end

local function FetchArrowAvailability(Player: Player, Stage: number): boolean
	local LocalPlayerStage = LocalPlayer:GetAttribute("CurrentStage")
	local StageDifference = LocalPlayerStage - Stage
	
	-- Fetch max stage on current map
	if LocalPlayerStage % 5 == 0 then
		if StageDifference <= 4 and StageDifference >= 0 then
			return true
		end
	elseif LocalPlayerStage % 5 ~= 0 then
		local MaxStage = LocalPlayerStage
		
		while MaxStage % 5 ~= 0 do
			MaxStage += 1
		end
		
		StageDifference = MaxStage - Stage
		
		if StageDifference <= 4 and StageDifference >= 0 then
			return true
		end
	end
end

local function UpdateArrowIndicator(ArrowIndicator: Frame): ()
	local PlayerId = ArrowIndicator:GetAttribute("PlayerId")
	local Player = Players:GetPlayerByUserId(PlayerId)
	
	if not Player then
		return
	end
	
	local Character = Player.Character
	local Stage = tonumber(Player:GetAttribute("CurrentStage"))
	
	if not Stage then
		return
	end
	
	if not Character then
		return
	end
		
	while Stage > 5 do
		Stage -= 5
	end
	
	local PhysicalStage = workspace.Stages:FindFirstChild(Player:GetAttribute("CurrentStage"))
	
	if not PhysicalStage then
		return
	end
	
	if not FetchArrowAvailability(Player, tonumber(PhysicalStage.Name)) then
		ArrowIndicator.Visible = false
		
		return
	end	
	
	local Start = PhysicalStage:FindFirstChild("Start")
	
	if not Start then
		return
	end
	
	local InitialPosition = UDim2.fromScale(1/6 + (Stage - 1) * 1/6, 0.1)
	local Offset = (Start:GetPivot().Position.Z - Character:GetPivot().Position.Z) / 312
	ArrowIndicator.Position = InitialPosition + UDim2.fromScale(Offset / 6, 0)
	ArrowIndicator.Visible = true	
end

local function DeleteArrowIndicator(Player: Player): ()
	for _, ArrowIndicator in StageIndicator:GetChildren() do
		if ArrowIndicator.Name ~= 'ArrowIndicator' then
			continue
		end
		
		if ArrowIndicator:GetAttribute("PlayerId") ~= Player.UserId then
			continue
		end
				
		ArrowIndicator:Destroy()
	end
end

local function CreateArrowIndicator(Player: Player): ()
	local ArrowIndicator = ArrowIndicatorTemplate:Clone()
	local ChosenColor = Player == LocalPlayer and Color3.new(1, 1, 1) or Color3.new(math.random(0, 8) / 10, math.random(0, 8) / 10, math.random(0, 8) / 10)
	ArrowIndicator.Icon.ImageColor3 = ChosenColor
	ArrowIndicator:SetAttribute("PlayerId", Player.UserId)
	ArrowIndicator.Avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	ArrowIndicator.Avatar.UIStroke.Color = ChosenColor
	ArrowIndicator.Parent = StageIndicator
	
	ArrowIndicator.Avatar.MouseEnter:Connect(function(): ()
		TweenService:Create(ArrowIndicator, TweenInfo.new(1/4), {Size = UDim2.fromScale(0.6, 0.6)}):Play()
	end)
	
	ArrowIndicator.Avatar.MouseLeave:Connect(function(): ()
		TweenService:Create(ArrowIndicator, TweenInfo.new(1/4), {Size = UDim2.fromScale(0.3, 0.3)}):Play()
	end)
		
	while RunService.RenderStepped:Wait() do
		UpdateArrowIndicator(ArrowIndicator)
	end
end

local function Init(): ()
	if not LocalPlayer:GetAttribute("CurrentStage") then
		repeat task.wait() until LocalPlayer:GetAttribute("CurrentStage")
	end
	
	for _, Player in Players:GetPlayers() do
		task.spawn(function(): ()
			CreateArrowIndicator(Player)	
		end)
	end
	
	UpdateMinimap()
	HandleMinimap()
	
	Players.PlayerRemoving:Connect(DeleteArrowIndicator)
	Players.PlayerAdded:Connect(CreateArrowIndicator)
end

-- Public
StageIndicatorController.Init = Init

return StageIndicatorController