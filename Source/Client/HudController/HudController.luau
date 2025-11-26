-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGUI = game:GetService("StarterGui")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Hud = LocalPlayer.PlayerGui:WaitForChild("Hud")
local Pages = LocalPlayer.PlayerGui:WaitForChild("Pages")
local SpawnBoostBar = Hud.StatBars.SpawnBoostBar

-- Private
local HudController = {}

local function AnimateSpawnBoostBar(): ()
	LocalPlayer:GetAttributeChangedSignal("SpawnBoost"):Connect(function(): ()
		if LocalPlayer:GetAttribute("SpawnBoost")  then
			TweenService:Create(SpawnBoostBar.Fill, TweenInfo.new(1.25), {Size = UDim2.fromScale(1, 1)}):Play()
			task.wait(1.25)
			TweenService:Create(SpawnBoostBar.Fill, TweenInfo.new(3), {Size = UDim2.fromScale(0, 1)}):Play()			
		end
	end)
end

local function HandleCoinsDisplay(): ()
	local CoinsLabel = LocalPlayer.PlayerGui:WaitForChild("Hud").Currency.Coins.TextLabel
	CoinsLabel.Text = LocalPlayer:GetAttribute("Coins") and LocalPlayer:GetAttribute("Coins") or 0
	
	local PlayerGui = 	LocalPlayer.PlayerGui
	local Hud = PlayerGui:WaitForChild("Hud")
	local TextLabel = Hud.Currency.Coins.TextLabel
	local CurrentAmount = tonumber(TextLabel.Text)	
	local Leaderstats = LocalPlayer.leaderstats
	local Coins = Leaderstats.Coins

	LocalPlayer:GetAttributeChangedSignal("Coins"):Connect(function(): ()	
		TextLabel.Text = LocalPlayer:GetAttribute("Coins")
		Coins.Value = LocalPlayer:GetAttribute("Coins")
	end)	
end

local function WarningPrompt(ContentText: string): ()
	local NewWarningPrompt = ReplicatedStorage.Assets.UI.WarningPrompt:Clone()
	NewWarningPrompt.Content.Text = ContentText
	NewWarningPrompt.Parent = Hud
	
	TweenService:Create(NewWarningPrompt, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 0.5)}):Play()

	NewWarningPrompt.Confirm.MouseEnter:Connect(function(): ()
		HudController.Services.SoundController.PlaySound('UIHover')
		TweenService:Create(NewWarningPrompt.Confirm, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(164, 197, 0)}):Play()
	end)

	NewWarningPrompt.Confirm.MouseLeave:Connect(function(): ()
		TweenService:Create(NewWarningPrompt.Confirm, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(212, 255, 0)}):Play()
	end)

	NewWarningPrompt.Confirm.Button.Activated:Connect(function(): ()
		HudController.Services.SoundController.PlaySound('UIClick')
		
		TweenService:Create(NewWarningPrompt, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 1.5)}):Play()
		
		task.wait(1/6)
		
		NewWarningPrompt:Destroy()
	end)
end

local function SwitchHudVisibility(Show: boolean): ()
	if not Show then
		for _, Button in Hud.Buttons:GetChildren() do
			TweenService:Create(Button, TweenInfo.new(1/4), {Position = UDim2.fromScale(-0.5, Button.Position.Y.Scale)}):Play()
		end
		
		TweenService:Create(Hud.StageIndicator, TweenInfo.new(1/4), {Position = UDim2.fromScale(Hud.StageIndicator.Position.X.Scale, 1.2)}):Play()
		TweenService:Create(Hud.Currency.Coins, TweenInfo.new(1/4), {Position = UDim2.fromScale(-0.5, Hud.Currency.Coins.Position.Y.Scale)}):Play()
	elseif Show then
		for _, Button in Hud.Buttons:GetChildren() do
			TweenService:Create(Button, TweenInfo.new(1/4), {Position = UDim2.fromScale(0.056, Button.Position.Y.Scale)}):Play()
		end
		
		TweenService:Create(Hud.StageIndicator, TweenInfo.new(1/4), {Position = UDim2.fromScale(Hud.StageIndicator.Position.X.Scale, 0.95)}):Play()
		TweenService:Create(Hud.Currency.Coins, TweenInfo.new(1/4), {Position = UDim2.fromScale(0.056, Hud.Currency.Coins.Position.Y.Scale)}):Play()
	end
end

local function DisableResetButton(): ()
	repeat
		local success = pcall(function() 
			StarterGUI:SetCore("ResetButtonCallback", false) 
		end)
		
		task.wait(1)
	until success
end

local function AccountButtons(): ()
	for _, Button in Hud.Buttons:GetChildren() do
		Button.MouseEnter:Connect(function(): ()
			TweenService:Create(Button, TweenInfo.new(1/6), {Rotation = math.random(1, 2) == 1 and -5 or 5, Size = UDim2.fromScale(0.175, 0.0875)}):Play()
			TweenService:Create(Button.Icon, TweenInfo.new(1/6), {Rotation = math.random(1, 2) == 1 and -10 or 10}):Play()
			HudController.Services.SoundController.PlaySound("UIHover")	
		end)
		
		Button.MouseLeave:Connect(function(): ()
			TweenService:Create(Button, TweenInfo.new(1/6), {Rotation = 0, Size = UDim2.fromScale(0.2, 0.1)}):Play()
			TweenService:Create(Button.Icon, TweenInfo.new(1/6), {Rotation = 0}):Play()
		end)
		
		Button.Button.Activated:Connect(function(): ()
			local Page = Pages:FindFirstChild(Button.Name)
			
			SwitchHudVisibility(false)
			
			for _, Page in Pages:GetChildren() do
				TweenService:Create(Page, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()
			end
			
			if Page.Position ~= UDim2.fromScale(0.5, 0.5) then
				TweenService:Create(Page, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 0.5)}):Play()
			else
				TweenService:Create(Page, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()
			end
			
			HudController.Services.SoundController.PlaySound("UIClick")	
		end)
	end
end

local function OnClientEvent(Arguments: table): ()
	if Arguments.WarningPrompt then
		WarningPrompt(Arguments.WarningPrompt)
	end
end

local function Init(): ()
	task.spawn(AnimateSpawnBoostBar)
	task.spawn(DisableResetButton)
	task.spawn(AccountButtons)
	task.spawn(HandleCoinsDisplay)	
end

-- Public
HudController.OnClientEvent = OnClientEvent
HudController.WarningPrompt = WarningPrompt
HudController.SwitchHudVisibility = SwitchHudVisibility
HudController.Init = Init

return HudController