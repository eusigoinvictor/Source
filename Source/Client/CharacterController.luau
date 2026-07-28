-- Roblox: holeyinone, Discord: quatyzz
-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local CharacterController = {}
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage.Remotes
local RemoteEvent = Remotes.RemoteEvent
local Database = require(ReplicatedStorage.Modules.Database)
local JumpVFX = ReplicatedStorage.Assets.VFX.Jump
local PlayerGui = LocalPlayer.PlayerGui
local HealthBar = PlayerGui:WaitForChild("Hud", math.huge).StatBars.HealthBar

-- Functions
local function VFXJump(Character: Model): ()
	local NewJumpVFX = JumpVFX:Clone()
	NewJumpVFX:PivotTo(Character:GetPivot() - Vector3.new(0, 1, 0))
	NewJumpVFX.Parent = workspace
	
	local EquippedTrail = LocalPlayer:GetAttribute("EquippedTrail")
	
	if EquippedTrail then
		local Color = Database.Trails[EquippedTrail].Color
		
		if Color then
			NewJumpVFX.ParticleEmitter.Color = ColorSequence.new(Color3.new(1, 1, 1))--ColorSequence.new(Color)
			NewJumpVFX.Color = Color
		else
			warn(`{EquippedTrail} color was not defined on database.`)
		end
	end

	NewJumpVFX.ParticleEmitter:Emit(50)

	TweenService:Create(NewJumpVFX, TweenInfo.new(1/3), {CFrame = NewJumpVFX:GetPivot() * CFrame.fromOrientation(0, math.rad(180), 0)}):Play()

	task.wait(1/3)

	TweenService:Create(NewJumpVFX, TweenInfo.new(1/3), {Size = Vector3.new(13, 2, 13), Transparency = 1}):Play()

	task.wait(1/3)

	NewJumpVFX:Destroy()
end

local function HandleJumpState(Character: Model): ()
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

	Humanoid.StateChanged:Connect(function(State: Enum.HumanoidStateType): ()
		if State == Enum.HumanoidStateType.Landed then
			LocalPlayer:SetAttribute("JumpAmount", 0)
		end
	end)
end

local function HandleDoubleJump(): ()
	HandleJumpState(LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait())
	LocalPlayer.CharacterAdded:Connect(HandleJumpState)
	
	if not UserInputService.TouchEnabled then
		UserInputService.InputBegan:Connect(function(Key: InputObject, IsProcessed: boolean): ()
			local Key = Key.KeyCode.Name

			if Key ~= 'Space' then
				return
			end

			if tonumber(LocalPlayer:GetAttribute("Rebirths")) < 1 then
				return
			end

			local Character = LocalPlayer.Character

			if not Character then
				return
			end

			local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

			if not Humanoid then
				return
			end

			if Humanoid.FloorMaterial ~= Enum.Material.Air then
				return
			end

			local JumpAmount = LocalPlayer:GetAttribute("JumpAmount") and LocalPlayer:GetAttribute("JumpAmount") or 0

			if JumpAmount >= LocalPlayer:GetAttribute("Rebirths") then		
				return
			end

			task.spawn(VFXJump, Character)

			Humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations['Edge Jump']):Play()
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			LocalPlayer:SetAttribute("JumpAmount", JumpAmount + 1)
		end)
	else
		UserInputService.JumpRequest:Connect(function(): ()
			if tonumber(LocalPlayer:GetAttribute("Rebirths")) < 1 then
				return
			end

			local Character = LocalPlayer.Character

			if not Character then
				return
			end

			local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

			if not Humanoid then
				return
			end

			if Humanoid.FloorMaterial ~= Enum.Material.Air then
				return
			end

			local JumpAmount = LocalPlayer:GetAttribute("JumpAmount") and LocalPlayer:GetAttribute("JumpAmount") or 0

			if JumpAmount >= LocalPlayer:GetAttribute("Rebirths") then		
				return
			end

			task.spawn(VFXJump, Character)

			Humanoid.Animator:LoadAnimation(ReplicatedStorage.Assets.Animations['Edge Jump']):Play()
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			LocalPlayer:SetAttribute("JumpAmount", JumpAmount + 1)
		end)
	end
end

local function AdjustCharacter(): ()
	local Leaderstats = LocalPlayer:FindFirstChild("leaderstats")

	if not Leaderstats then
		return
	end

	local Stage = Leaderstats.Stage.Value
	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	local PhysicalStage = workspace.Stages:FindFirstChild(Stage)

	if not PhysicalStage then
		return
	end

	local Start = PhysicalStage:FindFirstChild("Start")

	if not Start then
		return-- warn(`Start not found on stage {Stage}.`)
	end

	Character:PivotTo(Character:GetPivot() + Vector3.new(-Character:GetPivot().Position.X + Start:GetPivot().Position.X, 0, 0))
end

local function Respawn(): ()
	local Character = LocalPlayer.Character

	if not Character then
		return
	end

	if Character:GetAttribute("Respawning") then
		return
	end

	Character:SetAttribute("Respawning", true)
	CharacterController.Services.SoundController.PlaySound("Death")
	RemoteEvent:FireServer("TeleportController", {Respawn = true})
	task.wait(1)
	Character:SetAttribute("Respawning", false)
	
	task.delay(1/6, function()
		LocalPlayer:SetAttribute("Health", 100)
		TweenService:Create(HealthBar.Fill, TweenInfo.new(1/6), {Size = UDim2.fromScale(1, 1)}):Play()
	end)
end

local function InitializeAttributes(): ()
    LocalPlayer:SetAttribute("Health", 100)
end

local function HitAnimation(Character: Model): ()
	task.spawn(function(): ()
	    if not Character then
			return
		end

		local Highlight = Character:FindFirstChild("HitAnimation") or Instance.new("Highlight", Character)
		Highlight.FillTransparency = 1
		Highlight.OutlineTransparency = 1
		Highlight.FillColor = Color3.fromRGB(222, 66, 23)
		Highlight.Name = 'HitAnimation'

		TweenService:Create(Highlight, TweenInfo.new(1/6), {FillTransparency = 0.3}):Play()
		task.wait(1/6)
		TweenService:Create(Highlight, TweenInfo.new(1/6), {FillTransparency = 1}):Play()
		task.wait(1/6)
		Highlight:Destroy()
	end)
end

local function TakeDamage(Damage: number): ()
	-- Calculations
    local MaxHealth = 100
    local NewHealth = LocalPlayer:GetAttribute("Health") - Damage
    local BarPositionX = NewHealth / MaxHealth
    
	-- Immunity Frame Check
    if LocalPlayer:GetAttribute("TookDamage") then
        return
    end

	-- Prevent negative health and respawn
    if NewHealth <= 0 then
        NewHealth = 0
        CharacterController.Services.CharacterController.Respawn()
    end

	-- Animate the health bar
    TweenService:Create(HealthBar.Fill, TweenInfo.new(1/6), {Size = UDim2.fromScale(BarPositionX, 1)}):Play()
    
	-- Hit animation
	local Character = LocalPlayer.Character
		
	if Character then
		HitAnimation(Character)
	end

	-- Enable immunity frame and update health attribute
	LocalPlayer:SetAttribute("Health", NewHealth)
    LocalPlayer:SetAttribute("TookDamage", true)

	-- Disable immunity frame
    task.delay(1/3, function()
        LocalPlayer:SetAttribute("TookDamage", false)
    end)
end

local function Init(): ()
	HandleDoubleJump()
	InitializeAttributes()
	
	RunService.RenderStepped:Connect(function()
		AdjustCharacter()
	end)
end

-- Module
CharacterController.HitAnimation = HitAnimation
CharacterController.TakeDamage = TakeDamage
CharacterController.Respawn = Respawn
CharacterController.Init = Init

return CharacterController
