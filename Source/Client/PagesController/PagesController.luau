-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local Pages = LocalPlayer.PlayerGui:WaitForChild("Pages")
local PagesController = {}

-- Functions
local function AccountCloseButtons(): ()
	for _, Page in Pages:GetChildren() do
		local CloseButton = Page:FindFirstChild("CloseButton")
		
		if not CloseButton then
			warn(`Close button not found on page {Page.Name}`)
			
			continue	
		end
		
		CloseButton.MouseEnter:Connect(function()
			TweenService:Create(CloseButton.X, TweenInfo.new(1/6), {Rotation = 22.5}):Play()
			
			PagesController.Services.SoundController.PlaySound("UIHover")
		end)

		CloseButton.MouseLeave:Connect(function()
			TweenService:Create(CloseButton.X, TweenInfo.new(1/6), {Rotation = 0}):Play()
		end)

		CloseButton.Button.Activated:Connect(function()
			TweenService:Create(Page, TweenInfo.new(1/6), {Position = UDim2.fromScale(0.5, 3)}):Play()
			PagesController.Services.HudController.SwitchHudVisibility(true)
			PagesController.Services.SoundController.PlaySound("UIClick")	
		end)
	end
end

local function Init(): ()
	AccountCloseButtons()
end

-- Public
PagesController.Init = Init

return PagesController