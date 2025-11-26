-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variables
local PreloadController = {}
local Player = Players.LocalPlayer

-- Private
local function PreloadAnimations(): ()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	local Animator = Humanoid.Animator
	
	for _, Animation in ReplicatedStorage.Assets.Animations:GetChildren() do
		task.spawn(function()
			local AnimTrack = Animator:LoadAnimation(Animation)		
			AnimTrack:Play()
			
			task.wait(1/10)
					
			AnimTrack:Stop()
		end)
	end
end

-- Public
function PreloadController.Init(): ()
	PreloadAnimations()
end

return PreloadController