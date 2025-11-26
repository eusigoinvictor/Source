-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local TeleportController = {}
local Remotes = ReplicatedStorage.Remotes
local RemoteEvent = Remotes.RemoteEvent

-- Functions
local function SpawnEffect(Player: Player): ()
	-- Store Character
	local Character = Player.Character or Player.CharacterAdded:Wait()
	Character.Parent = ReplicatedStorage

	local Spawn = ReplicatedStorage.Assets.Models.Spawn
	local NewSpawn = Spawn:Clone()
	NewSpawn:PivotTo(CFrame.new(Character:GetPivot().Position))
	NewSpawn.Parent = workspace
	
	local NewSpawnVFX = ReplicatedStorage.Assets.VFX.SpawnVFX:Clone()
	NewSpawnVFX.Parent = Character.HumanoidRootPart
	
	Player:SetAttribute("SpawnBoost", true)
	
	task.spawn(function()
		while NewSpawn.Parent and task.wait(0.01) do
			NewSpawn:PivotTo((NewSpawn:GetPivot() * CFrame.fromOrientation(0, math.rad(8), 0)))

			for _, Union in NewSpawn:GetChildren() do
				Union.Size += Vector3.new(1/100, 1/100, 1/100)
			end
		end 
	end)

	task.wait(1/4)

	for _, Union in NewSpawn:GetChildren() do
		for i=1, 25 do
			task.wait(0.01)

			Union.Size -= Vector3.new(8/100, 8/100, 8/100)
			Union.Transparency += 0.04
		end
	end

	Character.Parent = workspace
	
	for _, BasePart in Character:GetChildren() do
		if not BasePart:IsA("BasePart") then
			continue
		end
		
		BasePart.AssemblyLinearVelocity = Vector3.zero
	end

	NewSpawn:Destroy()

	local Humanoid = Character:WaitForChild("Humanoid", math.huge)
	local InitialSpeed = Humanoid.WalkSpeed
	local InitialJumpPower = Humanoid.JumpPower
	local InitialTrail = Player:GetAttribute("EquippedTrail")
	Humanoid.JumpPower = 100
	Humanoid.WalkSpeed = 48

	task.delay(1.5, function(): ()
		if Humanoid and Humanoid.Parent then
			Humanoid.JumpPower = InitialJumpPower	
			
			if Player:GetAttribute("EquippedTrail") and Player:GetAttribute("EquippedTrail") == InitialTrail then
				Humanoid.WalkSpeed = InitialSpeed	
			end
		end
		
		task.wait(1/2)
		
		NewSpawnVFX:Destroy()
		Player:SetAttribute("SpawnBoost", false)
	end)
	
end

local function Respawn(Player: Player): ()
	-- Fetch physical stage
	local Character = Player.Character
	local CurrentStage = Player:WaitForChild("leaderstats").Stage.Value
	local Stage = workspace.Stages:FindFirstChild(tostring(CurrentStage))

	-- Update deaths stat
	local PlayerData = TeleportController.Services.DataController.LoadedData[Player.UserId]
	PlayerData.Deaths += 1
	Player:SetAttribute("Deaths", PlayerData.Deaths)
	
	-- In this case physical stage does not exist, since we can't get Start then return
	if not Stage then
		return warn('Stage not found.')
	end

	local SpawnLocation = Stage:FindFirstChild("Start")

	if not SpawnLocation then
		return warn('Start part not found on stage', Stage)
	end
	
	-- Now that we know that the start exists, we can "spawn" the player
	Character.Parent = ReplicatedStorage

	for _, BasePart: BasePart in Character:GetChildren() do
		if not BasePart:IsA("BasePart") then
			continue
		end
		
		TweenService:Create(BasePart, TweenInfo.new(1/4), {Position = SpawnLocation:GetPivot().Position}):Play()
	end
	
	-- VFX
	task.delay(1/4, function()
		SpawnEffect(Player)
	end)
end

local function SetStage(Player: Player, Stage: number, Unlocking: boolean): ()
	-- Check for Stage existence (This is meant for PlayerAdded)
	if not Stage then
		repeat task.wait() until Player:GetAttribute("Stage")
		
		Stage = Player:GetAttribute("Stage")
	end
	
	-- Fetch Player Data
	local PlayerData = TeleportController.Services.DataController.LoadedData[Player.UserId]
			
	-- Check if player data is enough for this teleport
	if PlayerData.Stage < Stage then
		-- If it isn't, but it's unlocking, then unlock the stage and update the maps in teleportp page
		if Unlocking then
			PlayerData.Stage = Stage

			RemoteEvent:FireClient(Player, "TeleportPageController", {UpdateMaps = true, PlayerData = PlayerData})
		elseif not Unlocking then -- If it isn't, nor is it unlocking, then this is not allowed
			return
		end
	end
	
	-- Rebirth Lock, if player has not unlocked the next stage through rebirth, then they can't teleport
	local RebirthLocked = Stage > (PlayerData.Rebirths + 1) * 10
	
	if RebirthLocked then
		RemoteEvent:FireClient(Player, "HudController", {WarningPrompt = 'You need to perform a <font color="rgb(255, 170, 0)">rebirth</font> to progress further'})
		return
	end
	
	-- Set player current stage
	Player:SetAttribute("CurrentStage", Stage)
	Player.leaderstats.Stage.Value = Stage
	
	RemoteEvent:FireClient(Player, "SoundController", {PlaySound = "PortalUse"})
	
	if not Player.Character then
		return
	end
	
	local Character = Player.Character
	local CurrentStage = Player:WaitForChild("leaderstats").Stage.Value
	local Stage = workspace.Stages:FindFirstChild(tostring(CurrentStage))

	if not Stage then
		return warn('Stage not found.')
	end

	local SpawnLocation = Stage:FindFirstChild("Start")

	if not SpawnLocation then
		return warn('Start part not found on stage', Stage)
	end

	Player:SetAttribute("Loading", true)
	RemoteEvent:FireClient(Player, "LightingController", {Stage = Stage.Name})
	Player.RespawnLocation = SpawnLocation
	
	-- Prime for another loading page
	task.delay(1/2, function()
		Player:SetAttribute("Loading", false)
		
		Character:PivotTo(SpawnLocation:GetPivot())
	end)
	
	SpawnEffect(Player)
end

local function OnServerEvent(Player: Player, Arguments: table): ()
	if table.find({"NextStage", "PreviousStage"}, Arguments[1]) then
		local Stage = Arguments[1] == 'NextStage' and Player.leaderstats.Stage.Value + 1 or Player.leaderstats.Stage.Value - 1	
		
		SetStage(Player, Stage, true)	
	end
	
	if Arguments.TeleportStage then
		SetStage(Player, Arguments.TeleportStage)
	end
	
	if Arguments.Respawn then
		Respawn(Player)
	end
end

local function HandlePlayer(Player: Player): ()
	Player.CharacterAdded:Connect(function(Character: Model)
		SetStage(Player)
	end)
end

local function Init(): ()	
	for _, Player in Players:GetPlayers() do
		HandlePlayer(Player)
	end
	
	Players.PlayerAdded:Connect(HandlePlayer)
end

-- Public
TeleportController.Respawn = Respawn
TeleportController.OnServerEvent = OnServerEvent
TeleportController.SetStage = SetStage
TeleportController.Init = Init

return TeleportController