-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage.Remotes

-- Variables
local Database = require(ReplicatedStorage.Modules.Database)
local RemoteEvent = Remotes.RemoteEvent
local ItemsController = {}

-- Functions
local function UnequipItem(Player: Player, Character: Model, Category: string): ()
	local PlayerData = ItemsController.Services.DataController.LoadedData[Player.UserId]
	PlayerData.EquippedItems[Category] = nil
	
	if Category == 'Trails' then
		local Humanoid = Character:FindFirstChild("Humanoid")
		local RightArm = Character:FindFirstChild("Right Arm")
		local LeftArm = Character:FindFirstChild("Left Arm")

		if not Humanoid then
			return warn('Humanoid not found.')
		end

		if not RightArm or not LeftArm then
			return warn('One of the arms not found.')
		end
		
		if RightArm:FindFirstChild("Trail") then
			RightArm.Trail:Destroy()
		end
		
		if LeftArm:FindFirstChild("Trail") then
			LeftArm.Trail:Destroy()
		end
		
		Player:SetAttribute("EquippedTrail", nil)
		
		Humanoid.WalkSpeed = 16
	end
end

local function EquipItem(Player: Player, Character: Model, Category: string, Name: string): ()
	local ItemData = Database[Category][Name]
		
	if not ItemData then
		return warn(`Item {Name} of {Category} category wasn't found.`)
	end
	
	local PlayerData = ItemsController.Services.DataController.LoadedData[Player.UserId]
	PlayerData.EquippedItems[Category] = Name
	
	if Category == 'Trails' then
		local Trail = ReplicatedStorage.Assets.Trails:FindFirstChild(Name)
		
		if not Trail then
			return warn(`Trail {Name} doesn't exist on Trails folder.`)
		end
				
		local Humanoid = Character:FindFirstChild("Humanoid")
		local LeftArm = Character:FindFirstChild("Left Arm")
		local RightArm = Character:FindFirstChild("Right Arm")
		
		if not Humanoid then
			return warn('Humanoid not found.')
		end
		
		if not LeftArm or not RightArm then
			return warn('Arms not found.')
		end
		
		if LeftArm:FindFirstChild("Trail") then
			LeftArm.Trail:Destroy()
		end
		
		if RightArm:FindFirstChild("Trail") then
			RightArm.Trail:Destroy()
		end
		
		Player:SetAttribute("EquippedTrail", Name)
		
		Humanoid.WalkSpeed = ItemData.WalkSpeed
		
		local Attachment0 = LeftArm:FindFirstChild("TrailAttachment0") or Instance.new("Attachment")
		Attachment0.Position = Vector3.one * -0.1
		Attachment0.Name = 'TrailAttachment0'
		Attachment0.Parent = LeftArm
		
		local Attachment1 = LeftArm:FindFirstChild("TrailAttachment1") or Instance.new("Attachment")
		Attachment1.Position = Vector3.one * 0.1
		Attachment1.Name = 'TrailAttachment1'
		Attachment1.Parent = LeftArm
		
		local NewTrail: Trail = Trail:Clone()
		NewTrail.Attachment0 = Attachment0
		NewTrail.Attachment1 = Attachment1
		NewTrail.Name = 'Trail'
		NewTrail.Parent = LeftArm
		
		-- Right
		
		local Attachment0 = RightArm:FindFirstChild("TrailAttachment0") or Instance.new("Attachment")
		Attachment0.Position = Vector3.one * -0.1
		Attachment0.Name = 'TrailAttachment0'
		Attachment0.Parent = RightArm

		local Attachment1 = RightArm:FindFirstChild("TrailAttachment1") or Instance.new("Attachment")
		Attachment1.Position = Vector3.one * 0.1
		Attachment1.Name = 'TrailAttachment1'
		Attachment1.Parent = RightArm

		local NewTrail: Trail = Trail:Clone()
		NewTrail.Attachment0 = Attachment0
		NewTrail.Attachment1 = Attachment1
		NewTrail.Name = 'Trail'
		NewTrail.Parent = RightArm
	end
end

local function EquipItems(Player: Player, Character: Model, PlayerData: table): ()
	for EquippedItemCategory, EquippedItemName in PlayerData.EquippedItems do
		EquipItem(Player, Character, EquippedItemCategory, EquippedItemName)	
	end
end

local function LoadItems(Player: Player, PlayerData: table): ()
	RemoteEvent:FireClient(Player, "ItemsPageController", {['GenerateTrails'] = true, PlayerData = PlayerData})
end

local function OnServerEvent(Player: Player, Arguments: table): ()
	local Character = Player.Character or Player.CharacterAdded:Wait()
		
	if Arguments.Equip then
		EquipItem(Player, Character, Arguments.Category, Arguments.ItemName)
	elseif Arguments.Unequip then
		UnequipItem(Player, Character, Arguments.Category)	
	end
end

local function Init(): ()	
	Players.PlayerAdded:Connect(function(Player: Player): ()
		local PlayerData = ItemsController.Services.DataController.LoadedData[Player.UserId]
		
		repeat 
			PlayerData = ItemsController.Services.DataController.LoadedData[Player.UserId]
			task.wait()
		until PlayerData
		
		local CoinsLabel = Player.PlayerGui:WaitForChild("Hud").Currency.Coins.TextLabel
		CoinsLabel.Text = PlayerData.Coins
		
		LoadItems(Player, PlayerData)
		EquipItems(Player, Player.Character or Player.CharacterAdded:Wait(), PlayerData)
		
		Player.CharacterAdded:Connect(function(Character: Model): ()
			EquipItems(Player, Character, PlayerData)
		end)
	end)
end

-- Public
ItemsController.UnequipItem = UnequipItem
ItemsController.OnServerEvent = OnServerEvent
ItemsController.Init = Init

return ItemsController