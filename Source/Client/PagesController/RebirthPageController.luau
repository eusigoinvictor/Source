-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local RebirthPageController = {}
local Remotes = ReplicatedStorage.Remotes
local LocalPlayer = Players.LocalPlayer
local Pages = LocalPlayer.PlayerGui:WaitForChild("Pages")
local RebirthPage = Pages.Rebirth
local RebirthButton = RebirthPage.RebirthButton
local RemoteEvent = Remotes.RemoteEvent
local RemoteFunction = Remotes.RemoteFunction
local Leaderstats = LocalPlayer:WaitForChild("leaderstats")

-- Function
local function SetStats(): ()
	local Rebirths = Leaderstats.Rebirths
	
	RebirthPage.CurrentLife.Text = Rebirths.Value
	RebirthPage.AfterLife.Text = Rebirths.Value + 1

	RebirthPage.AfterMaxStage.Text = (Rebirths.Value + 2) * 10
	RebirthPage.CurrentMaxStage.Text = (Rebirths.Value + 1) * 10
end

local function AccountStats(): ()	
	local Rebirths: IntValue = Leaderstats.Rebirths
	
	Rebirths:GetPropertyChangedSignal("Value"):Connect(function(): ()
		SetStats()
	end)
end

local function AccountRebirthButton(): ()
	RebirthButton.MouseEnter:Connect(function(): ()
		TweenService:Create(RebirthButton, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(21, 24, 58)}):Play()
		TweenService:Create(RebirthButton.Title, TweenInfo.new(1/6), {TextColor3 = Color3.fromRGB(255, 84, 84)}):Play()
		
		RebirthPageController.Services.SoundController.PlaySound("UIHover")	
	end)
	
	RebirthButton.MouseLeave:Connect(function(): ()
		TweenService:Create(RebirthButton, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(255, 84, 84)}):Play()
		TweenService:Create(RebirthButton.Title, TweenInfo.new(1/6), {TextColor3 = Color3.fromRGB(21, 24, 58)}):Play()
	end)
	
	RebirthButton.Button.Activated:Connect(function(): ()
		local PlayerData = RemoteFunction:InvokeServer("DataController")
		local Leaderstats = LocalPlayer:WaitForChild("leaderstats")
		local MaxStage = PlayerData.Stage
		local Rebirths = PlayerData.Rebirths
		
		if math.floor(MaxStage / 10) < (Rebirths + 1) then
			TweenService:Create(RebirthPage, TweenInfo.new(1/6), {Size = UDim2.fromScale(0.45, 0.45)}):Play()
			task.wait(1/6)
			TweenService:Create(RebirthPage, TweenInfo.new(1/6), {Size = UDim2.fromScale(0.5, 0.5)}):Play()
		else
			RemoteEvent:FireServer("StatsController", {Rebirth = true})

			TweenService:Create(RebirthPage, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()	
			
			RebirthPageController.Services.HudController.SwitchHudVisibility(true)	
		end
		
		RebirthPageController.Services.SoundController.PlaySound("UIClick")	
	end)
end

local function Init(): ()
	SetStats()
	AccountStats()
	AccountRebirthButton()	
end

-- Public
RebirthPageController.Init = Init

return RebirthPageController