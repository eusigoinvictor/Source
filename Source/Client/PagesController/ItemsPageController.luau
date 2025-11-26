-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Variables
local Player = Players.LocalPlayer
local Pages = Player.PlayerGui:WaitForChild("Pages")
local ItemsPage = Pages.Items
local RemoteFunction = ReplicatedStorage.Remotes.RemoteFunction
local RemoteEvent = ReplicatedStorage.Remotes.RemoteEvent
local Database = require(ReplicatedStorage.Modules.Database)

-- Private
local ItemsPageController = {}

local function AccountTrail(Trail: Frame): ()
	if not Trail:IsA("Frame") then
		return
	end

	Trail.MouseEnter:Connect(function()
		TweenService:Create(Trail.Background, TweenInfo.new(1/6), {BackgroundTransparency = 0.5}):Play()
		
		ItemsPageController.Services.SoundController.PlaySound("UIHover")		
	end)

	Trail.MouseLeave:Connect(function()
		TweenService:Create(Trail.Background, TweenInfo.new(1/6), {BackgroundTransparency = 0}):Play()
	end)

	Trail.Button.Activated:Connect(function()
		ItemsPage.ItemInfo.Description.Text = Database.Trails[Trail.Name].Description
		ItemsPage.ItemInfo.ItemName.Text = Trail.Name..' Trail'
		ItemsPage.ItemInfo.Icon.Image = Trail.Icon.Image
		
		ItemsPage.ItemInfo:SetAttribute("Category", 'Trails')
		ItemsPage.ItemInfo:SetAttribute("ItemName", Trail.Name)
		
		local PlayerData = RemoteFunction:InvokeServer("DataController")
		local ItemData = Database.Trails[Trail.Name]
		
		if not ItemData then
			return warn('Item data does not exist.')
		end
		
		if table.find(PlayerData.Items.Trails, Trail.Name) then
			ItemsPage.ItemInfo.Cost.Visible = false
			
			if PlayerData.EquippedItems['Trails'] == Trail.Name then
				ItemsPage.ItemInfo.ActionButton.Title.Text = 'Unequip'
			else
				ItemsPage.ItemInfo.ActionButton.Title.Text = 'Equip'
			end
		else
			ItemsPage.ItemInfo.ActionButton.Title.Text = 'Buy'
			ItemsPage.ItemInfo.Cost.Visible = true
			ItemsPage.ItemInfo.Cost.Text = ItemData.Cost
		end
		
		ItemsPageController.Services.SoundController.PlaySound("UIClick")	
	end)
end

local function AccountTrails(): ()
	local TrailContainer = ItemsPage.Sections.Trails
	
	for _, Trail in TrailContainer:GetChildren() do
		AccountTrail(Trail)
	end
	
	TrailContainer.ChildAdded:Connect(AccountTrail)
end

local function AccountActionButton(): ()
	local ItemInfo = ItemsPage.ItemInfo
	local ActionButton = ItemInfo.ActionButton
	
	ActionButton.MouseEnter:Connect(function(): ()
		TweenService:Create(ActionButton, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(164, 166, 255)}):Play()
		TweenService:Create(ActionButton.Title, TweenInfo.new(1/6), {TextColor3 = Color3.fromRGB(21, 24, 58)}):Play()
		ItemsPageController.Services.SoundController.PlaySound("UIHover")		
	end)
	
	ActionButton.MouseLeave:Connect(function(): ()
		TweenService:Create(ActionButton, TweenInfo.new(1/6), {BackgroundColor3 = Color3.fromRGB(21, 24, 58)}):Play()
		TweenService:Create(ActionButton.Title, TweenInfo.new(1/6), {TextColor3 = Color3.fromRGB(164, 166, 255)}):Play()
	end)
	
	ActionButton.Button.Activated:Connect(function(): ()
		local PlayerData = RemoteFunction:InvokeServer("DataController")
		local Category = ItemsPage.ItemInfo:GetAttribute("Category")
		local ItemName = ItemsPage.ItemInfo:GetAttribute("ItemName")
		
		ItemsPageController.Services.SoundController.PlaySound("UIClick")	
		
		if not Category then
			return warn("Category not found")
		end
		
		if not ItemName then
			return warn("ItemName not found")
		end
		
		local OwnItem = table.find(PlayerData.Items[Category], ItemName)
		local EquippedItem = PlayerData.EquippedItems[Category]
		
		if OwnItem then
			if EquippedItem == ItemName then
				ActionButton.Title.Text = 'Equip'
				
				RemoteEvent:FireServer("ItemsController", {['Unequip'] = true, Category = Category})
			elseif EquippedItem ~= ItemName then
				ActionButton.Title.Text = 'Unequip'
				
				RemoteEvent:FireServer("ItemsController", {['Equip'] = true, ItemName = ItemName, Category = Category})
			end
		else
			local Sucess = RemoteFunction:InvokeServer("EconomyController", {['Buy'] = true, ItemName = ItemName, Category = Category})
			
			if Sucess then
				ItemsPage.ItemInfo.Cost.Visible = false
				ActionButton.Title.Text = 'Equip'
				ItemsPage.Sections[Category][ItemName].Locked.Visible = false
			end	
		end
	end)
end

local function AddTrail(TrailName: string, PlayerData: table): ()
	local TrailData = Database.Trails[TrailName]
	local PlayerOwns = table.find(PlayerData.Items.Trails, TrailName)
	local TrailTemplate = ReplicatedStorage.Assets.UI.TrailTemplate:Clone()
	TrailTemplate.Icon.Image = TrailData.Icon
	TrailTemplate.Title.Text = TrailName
	TrailTemplate.Title.Rotation = math.random(-5, 5)
	TrailTemplate.Name = TrailName
	TrailTemplate.Locked.Visible = not PlayerOwns
	TrailTemplate.LayoutOrder = TrailData.LayoutOrder
	TrailTemplate.Parent = ItemsPage.Sections.Trails
end

local function GenerateTrails(PlayerData: table): ()
	for TrailName, TrailData in Database.Trails do
		AddTrail(TrailName, PlayerData)
	end
end

local function RefreshTrails(PlayerData: table): ()
	ItemsPage.ItemInfo.Icon.Image = ''
	ItemsPage.ItemInfo.Description.Text = ''
	ItemsPage.ItemInfo.ItemName.Text = ''
	ItemsPage.ItemInfo.ActionButton.Title.Text = ''
		
	for _, Trail: Frame in ItemsPage.Sections.Trails:GetChildren() do
		if not Trail:IsA("Frame") then
			continue
		end
				
		local TrailData = Database.Trails[Trail.Name]
		local PlayerOwns = table.find(PlayerData.Items.Trails, Trail.Name)
		Trail.Icon.Image = TrailData.Icon
		Trail.Title.Text = Trail.Name
		Trail.Title.Rotation = math.random(-5, 5)
		Trail.Name = Trail.Name
		Trail.Locked.Visible = not PlayerOwns
		Trail.LayoutOrder = TrailData.LayoutOrder
	end
end

local function OnClientEvent(Arguments: table): ()
	if Arguments.GenerateTrails then
		GenerateTrails(Arguments.PlayerData)
	end
	
	if Arguments.RefreshTrails then
		RefreshTrails(Arguments.PlayerData)
	end
end

local function Init(): ()
	AccountTrails()
	AccountActionButton()
end

-- Public
ItemsPageController.Init = Init
ItemsPageController.OnClientEvent = OnClientEvent
ItemsPageController.AddTrail = AddTrail
ItemsPageController.GenerateTrails = GenerateTrails

return ItemsPageController