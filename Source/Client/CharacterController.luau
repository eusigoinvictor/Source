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
end

local function Init(): ()
	HandleDoubleJump()
	
	RunService.RenderStepped:Connect(function()
		AdjustCharacter()
	end)
end

-- Module
CharacterController.Respawn = Respawn
CharacterController.Init = Init

return CharacterController