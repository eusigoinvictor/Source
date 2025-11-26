-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local CameraController = {}
local LocalPlayer = Players.LocalPlayer
local RemoteFunction = ReplicatedStorage.Remotes.RemoteFunction
local ViewMode = 'Normal'
local Camera = workspace.CurrentCamera

-- Private
local function RemoveBlur(): ()
	if not Lighting:FindFirstChild("Blur") then
		return
	end

	TweenService:Create(Lighting.Blur, TweenInfo.new(1/6), {Size = 0}):Play()	
end

local function CreateBlur(Size: number): ()	
	local CameraBlur = Lighting:FindFirstChild("Blur") or Instance.new("BlurEffect", Lighting)
	TweenService:Create(CameraBlur, TweenInfo.new(1/6), {Size = Size}):Play()
end

local function FixCamera(): ()
	local LastZ: CFrame
	
	RunService.RenderStepped:Connect(function()
		if not LocalPlayer.Character then
			return
		end
		
		if Camera.CameraType ~= Enum.CameraType.Scriptable then
			Camera.CameraType = Enum.CameraType.Scriptable
		end

		local Character = LocalPlayer.Character
		
		if ViewMode ~= 'Normal' then
			return	
		end

		local CharacterPosition = Character:GetPivot().Position
		local CharacterDirection = Character:GetPivot().LookVector * Vector3.new(0, 1, 1)
		local SidewaysPivot = CFrame.lookAt(CharacterPosition + Vector3.new(22.5, 10, 0), CharacterPosition)
		local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
		
		if not HumanoidRootPart then
			return
		end
		
		SidewaysPivot = SidewaysPivot + CharacterDirection * 2
		Camera:PivotTo(SidewaysPivot)
	end)
end

local function CameraAnimation(): ()
	local Camera = workspace.CurrentCamera	
	local Mouse = LocalPlayer:GetMouse()
	local MaxTilt = 12

	task.spawn(function()
		while task.wait() do
			local Scene = workspace:FindFirstChild("Scene") or ReplicatedStorage:FindFirstChild("Scene")
			
			if not Scene then
				continue
			end
			
			local SceneCamera = Scene:FindFirstChild("Camera")
			
			if not SceneCamera then
				continue
			end
			
			if ViewMode ~= 'Fixed' then
				continue
			end
			
			Camera.CFrame = SceneCamera:GetPivot() * CFrame.Angles(
				math.rad((((Mouse.Y - Mouse.ViewSizeY) / 2) / Mouse.ViewSizeY) * -MaxTilt),
				math.rad((((Mouse.X - Mouse.ViewSizeX) / 2) / Mouse.ViewSizeX) * -MaxTilt),
				0
			)
		end
	end)
end

local ViewModes = {
	['Fixed'] = function()
		local Hud = LocalPlayer.PlayerGui:WaitForChild("Hud")
		Hud.Enabled = false

		CreateBlur(24)

		task.wait(1/10)

		Camera.CameraType = Enum.CameraType.Scriptable
	end,

	['Normal'] = function()
		local Hud = LocalPlayer.PlayerGui:WaitForChild("Hud")
		Hud.Enabled = true

		RemoveBlur()
	end,
}

local function ChangeView(Arguments: table): ()	
	CameraController.LastArgs = Arguments
	ViewModes[Arguments.Mode]()
	ViewMode = Arguments.Mode
end

local function Init(): ()
	FixCamera()
	CameraAnimation()
end

-- Public
CameraController.Init = Init
CameraController.ChangeView = ChangeView
CameraController.OnClientEvent = CameraController.ChangeView

LocalPlayer.CharacterAdded:Connect(ViewModes[ViewMode])

return CameraController