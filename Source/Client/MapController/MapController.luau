-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

-- Variables
local MapController = {}
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage.Remotes
local RemoteEvent = Remotes.RemoteEvent
local BezierModule = require(ReplicatedStorage.Modules.Bezier)
local RollingBallTemplate = ReplicatedStorage.Assets.Models.RollingBall
local Tags = {"PandoraAttract", "PandoraRepel", "Portal", "RollingBall", "Coral", "Spinner", "SharkTrajectory", "BoneDragon", "Meteor", "Base"}

-- Functions
local function AccountDamage(BasePart: BasePart): ()
	local Character = BasePart:FindFirstAncestorWhichIsA("Model")
	local Player = Players:GetPlayerFromCharacter(Character)

	if not Player then
		return
	end
	
	if Player ~= LocalPlayer then
		return
	end

	MapController.Services.CombatController.TakeDamage(50)
end

local TrapFunctions = {
	['PandoraAttract'] = function(PandoraAttractTrajectory: Folder): ()
		repeat task.wait() until #PandoraAttractTrajectory:GetChildren() >= 5

		PandoraAttractTrajectory.PandoraAttract:WaitForChild("Union")
		PandoraAttractTrajectory.PandoraAttract.Union.Touched:Connect(AccountDamage)

		task.spawn(function(): ()
			while PandoraAttractTrajectory.Parent do
				local NewRepelVFX: Model = ReplicatedStorage.Assets.VFX.AttractVFX:Clone()
				local Connection
				NewRepelVFX.Parent = PandoraAttractTrajectory.Parent
				Connection = NewRepelVFX.Hitbox.Touched:Connect(AccountDamage)

				for i=1, 25 do
					task.wait()

					NewRepelVFX:PivotTo(PandoraAttractTrajectory.PandoraAttract:GetPivot())
					NewRepelVFX:ScaleTo(i / 25)
				end

				for i=25, 1, -1 do
					task.wait()

					NewRepelVFX:PivotTo(PandoraAttractTrajectory.PandoraAttract:GetPivot())
					NewRepelVFX:ScaleTo(i / 25)
				end

				Connection:Disconnect()
				NewRepelVFX:Destroy()

				task.wait(2)
			end
		end)

		while PandoraAttractTrajectory.Parent do
			local Point0 = PandoraAttractTrajectory:WaitForChild("Point0", math.huge)
			local Point1 = PandoraAttractTrajectory:WaitForChild("Point1", math.huge)
			local Point2 = PandoraAttractTrajectory:WaitForChild("Point2", math.huge)
			local Point3 = PandoraAttractTrajectory:WaitForChild("Point3", math.huge)

			local P0 = Point0.Position
			local P1 = Point1.Position
			local P2 = Point2.Position
			local P3 = Point3.Position

			local Orientation = Vector3.new(0, 0, 0)

			for i=0, 1, 0.02 do
				local Origin = BezierModule.Quad(P0, P1, P2, i)
				local X, Y, Z = PandoraAttractTrajectory.PandoraAttract:GetPivot():ToOrientation()
				--local Padding = 20
				--X, Y, Z = X + math.rad(math.random(-Padding, Padding)), Y + math.rad(math.random(-Padding, Padding)), Z + math.rad(math.random(-Padding, Padding))
				Orientation += Vector3.new(math.rad(5), math.rad(5), math.rad(5))

				PandoraAttractTrajectory.PandoraAttract:PivotTo(CFrame.new(Origin) * CFrame.fromOrientation(Orientation.X, Orientation.Y, Orientation.Z))

				task.wait(0.01)
			end

			for i=0, 1, 0.02 do
				local Origin = BezierModule.Quad(P2, P3, P0, i)
				local X, Y, Z = PandoraAttractTrajectory.PandoraAttract:GetPivot():ToOrientation()
				--local Padding = 20
				--X, Y, Z = X + math.rad(math.random(-Padding, Padding)), Y + math.rad(math.random(-Padding, Padding)), Z + math.rad(math.random(-Padding, Padding))
				Orientation += Vector3.new(math.rad(5), math.rad(5), math.rad(5))

				PandoraAttractTrajectory.PandoraAttract:PivotTo(CFrame.new(Origin) * CFrame.fromOrientation(Orientation.X, Orientation.Y, Orientation.Z))

				task.wait(0.01)
			end
		end
	end,
	
	['PandoraRepel'] = function(PandoraRepelTrajectory: Folder): ()
		repeat task.wait() until #PandoraRepelTrajectory:GetChildren() >= 5
		
		PandoraRepelTrajectory.PandoraRepel:WaitForChild("Union")
		PandoraRepelTrajectory.PandoraRepel.Union.Touched:Connect(AccountDamage)

		task.spawn(function(): ()
			while PandoraRepelTrajectory.Parent do
				local NewRepelVFX: Model = ReplicatedStorage.Assets.VFX.RepelVFX:Clone()
				local Connection
				NewRepelVFX.Parent = PandoraRepelTrajectory.Parent
				Connection = NewRepelVFX.InwardShockwave.Touched:Connect(AccountDamage)

				for i=1, 25 do
					task.wait(0.01)

					NewRepelVFX:PivotTo(PandoraRepelTrajectory.PandoraRepel:GetPivot())
					NewRepelVFX:ScaleTo(i / 50)
				end
				
				for i=25, 1, -1 do
					task.wait(0.01)

					NewRepelVFX:PivotTo(PandoraRepelTrajectory.PandoraRepel:GetPivot())
					NewRepelVFX:ScaleTo(i / 50)
				end

				Connection:Disconnect()
				NewRepelVFX:Destroy()
				
				task.wait(2)
			end
		end)

		while PandoraRepelTrajectory.Parent do
			local Point0 = PandoraRepelTrajectory:WaitForChild("Point0", math.huge)
			local Point1 = PandoraRepelTrajectory:WaitForChild("Point1", math.huge)
			local Point2 = PandoraRepelTrajectory:WaitForChild("Point2", math.huge)
			local Point3 = PandoraRepelTrajectory:WaitForChild("Point3", math.huge)

			local P0 = Point0.Position
			local P1 = Point1.Position
			local P2 = Point2.Position
			local P3 = Point3.Position
			
			local Orientation = Vector3.new(0, 0, 0)

			for i=0, 1, 0.02 do
				local Origin = BezierModule.Quad(P0, P1, P2, i)
				local X, Y, Z = PandoraRepelTrajectory.PandoraRepel:GetPivot():ToOrientation()
				--local Padding = 20
				--X, Y, Z = X + math.rad(math.random(-Padding, Padding)), Y + math.rad(math.random(-Padding, Padding)), Z + math.rad(math.random(-Padding, Padding))
				Orientation += Vector3.new(math.rad(5), math.rad(5), math.rad(5))

				PandoraRepelTrajectory.PandoraRepel:PivotTo(CFrame.new(Origin) * CFrame.fromOrientation(Orientation.X, Orientation.Y, Orientation.Z))

				task.wait(0.01)
			end

			for i=0, 1, 0.02 do
				local Origin = BezierModule.Quad(P2, P3, P0, i)
				local X, Y, Z = PandoraRepelTrajectory.PandoraRepel:GetPivot():ToOrientation()
				--local Padding = 20
				--X, Y, Z = X + math.rad(math.random(-Padding, Padding)), Y + math.rad(math.random(-Padding, Padding)), Z + math.rad(math.random(-Padding, Padding))
				Orientation += Vector3.new(math.rad(5), math.rad(5), math.rad(5))

				PandoraRepelTrajectory.PandoraRepel:PivotTo(CFrame.new(Origin) * CFrame.fromOrientation(Orientation.X, Orientation.Y, Orientation.Z))

				task.wait(0.01)
			end
		end
	end,
	
	['Spinner'] = function(Spinner: Model): ()
		task.spawn(function(): ()
			local Log = Spinner:WaitForChild("Log", math.huge)

			Log.Touched:Connect(AccountDamage)
		end)
		
		while Spinner.Parent do
			local Log = Spinner:WaitForChild("Log", math.huge)
			local HasInvertedRotation = Spinner:GetAttribute("InvertedRotation")
			local Speed = Spinner:GetAttribute("Speed")
			Speed = HasInvertedRotation and -Speed or Speed
			Speed *= 50
			TweenService:Create(Log, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = Log:GetPivot() * CFrame.Angles(math.rad(Speed), 0, 0)}):Play()
			
			task.wait(1)	
		end
	end,
	
	['Meteor'] = function(Meteor: Model): ()
		local Origin = Meteor:GetPivot()
		local NewMeteor = ReplicatedStorage.Assets.VFX.Meteor:Clone()
		NewMeteor:PivotTo(Origin + Vector3.new(0, 100, 0))
		NewMeteor.Parent = workspace
		
		for _, BasePart in NewMeteor:GetChildren() do
			BasePart.Touched:Connect(AccountDamage)
		end
		
		while Meteor.Parent do
			for _, BasePart in NewMeteor:GetChildren() do
				task.spawn(function(): ()
					if not BasePart:IsA("BasePart") then
						return
					end

					TweenService:Create(BasePart, TweenInfo.new(1), {CFrame = Origin}):Play()

					task.wait(1)

					TweenService:Create(BasePart, TweenInfo.new(1), {Transparency = 1}):Play()

					task.wait(1)

					BasePart.Transparency = 0
					BasePart:PivotTo(Origin + Vector3.new(0, 100, 0))
				end)
			end

			task.wait(3)
		end
		
		NewMeteor:Destroy()
	end,
	
	['BoneDragon'] = function(BoneDragon: Model): ()
		repeat task.wait() until #BoneDragon:GetChildren() >= 3

		for _, BasePart in BoneDragon:GetChildren() do
			BasePart.Touched:Connect(AccountDamage)
		end
		
		local Head = BoneDragon:WaitForChild("Head")
		local HeadOrigin = Head:GetPivot()

		for _, BasePart in BoneDragon:GetChildren() do
			task.spawn(function(): ()
				local BasePartOrigin = BasePart:GetPivot()

				while BoneDragon.Parent do
					if not BasePart:IsA("BasePart") then
						return
					end

					TweenService:Create(BasePart, TweenInfo.new(1/6, Enum.EasingStyle.Linear), {CFrame = BasePartOrigin}):Play()

					task.wait(1/6)

					TweenService:Create(Head, TweenInfo.new(1/3, Enum.EasingStyle.Linear), {CFrame = HeadOrigin * CFrame.fromOrientation(-math.pi/5, math.pi / 3, 0)}):Play()	

					task.wait(1/3)

					TweenService:Create(Head, TweenInfo.new(1/3, Enum.EasingStyle.Linear), {CFrame = HeadOrigin}):Play()	

					task.wait(1/3)

					TweenService:Create(Head, TweenInfo.new(1/3, Enum.EasingStyle.Linear), {CFrame = HeadOrigin* CFrame.fromOrientation(-math.pi/5, -math.pi / 3, 0)}):Play()	

					task.wait(1/3)

					TweenService:Create(Head, TweenInfo.new(1/3, Enum.EasingStyle.Linear), {CFrame = HeadOrigin}):Play()	

					task.wait(1/3)	

					TweenService:Create(BasePart, TweenInfo.new(1/6, Enum.EasingStyle.Linear), {CFrame = BasePartOrigin - Vector3.new(0, 40, 0)}):Play()

					task.wait(1/6)

					task.wait(1.5)
				end
			end)	
		end
	end,
	
	['SharkTrajectory'] = function(SharkTrajectory: Folder): ()
		local Shark = SharkTrajectory:WaitForChild("Shark", math.huge)
		local Hitbox = Shark:WaitForChild("Hitbox", math.huge)

		Hitbox.Touched:Connect(AccountDamage)
		
		while SharkTrajectory.Parent do
			local Point0 = SharkTrajectory:WaitForChild("Point0", math.huge)
			local Point1 = SharkTrajectory:WaitForChild("Point1", math.huge)
			local Point2 = SharkTrajectory:WaitForChild("Point2", math.huge)
			--local Point3 = SharkTrajectory:WaitForChild("Point3", math.huge)
			local Shark = SharkTrajectory:WaitForChild("Shark", math.huge)

			local P0 = Point0.Position
			local P1 = Point1.Position
			local P2 = Point2.Position
			--local P3 = Point3.Position

			for i=0, 1, 0.02 do
				local Origin = CFrame.lookAt(BezierModule.Quad(P0, P1, P2, i), BezierModule.Quad(P0, P1, P2, i + 0.02))

				Shark:PivotTo(Origin)

				task.wait()
			end

			task.wait(1)

			for i=0, 1, 0.02 do
				local Origin = CFrame.lookAt(BezierModule.Quad(P2, P1, P0, i), BezierModule.Quad(P2, P1, P0, i + 0.02))

				Shark:PivotTo(Origin)

				task.wait()
			end
		end
	end,
	
	['Coral'] = function(Coral: Model): ()
		Coral:SetAttribute('InitialSize', Coral.Size)
		Coral.Touched:Connect(AccountDamage)
		
		task.wait(math.random(1, 6))

		while Coral.Parent do
			TweenService:Create(Coral.Highlight, TweenInfo.new(5/7), {FillTransparency = 0.6}):Play()
			TweenService:Create(Coral, TweenInfo.new(5/7), {Size = Vector3.new(18, 24, 18)}):Play()

			task.wait(1)

			TweenService:Create(Coral, TweenInfo.new(1), {Size = Coral:GetAttribute("InitialSize")}):Play()
			TweenService:Create(Coral.Highlight, TweenInfo.new(5/7), {FillTransparency = 1}):Play()

			task.wait(3)
		end
	end,
	
	['RollingBall'] = function(RollingBall: Model): ()
		local Origin = RollingBall:GetPivot()
		local NewRollingBall = RollingBallTemplate:Clone()
		NewRollingBall:PivotTo(RollingBall:GetPivot())
		NewRollingBall.Parent = RollingBall.Parent
		NewRollingBall.Touched:Connect(AccountDamage)
		
		while RollingBall.Parent do
			NewRollingBall:PivotTo(Origin)
			NewRollingBall.AssemblyLinearVelocity = Vector3.new(0, -30, 0)

			task.wait(2.5)
		end
		
		NewRollingBall:Destroy()
	end,
	
	['Portal'] = function(Portal: Model): ()
		local Teleport = Portal:WaitForChild("Teleport", math.huge)
		local ProximityPrompt = Teleport.ProximityPrompt

		ProximityPrompt.Triggered:Connect(function()			
			if LocalPlayer:GetAttribute("TeleportCooldown") then
				return
			end

			if ProximityPrompt.ObjectText == 'Next Stage' then
				RemoteEvent:FireServer("TeleportController", {"NextStage"})
			elseif ProximityPrompt.ObjectText == 'Previous Stage' then
				RemoteEvent:FireServer("TeleportController", {"PreviousStage"})	
			end

			LocalPlayer:SetAttribute("TeleportCooldown", true)

			task.delay(1/2, function()
				LocalPlayer:SetAttribute("TeleportCooldown", false)
			end)
		end)
	end,
	
	['Base'] = function(Base: BasePart): ()
		Base.Touched:Connect(AccountDamage)
	end,
}

local function HandleTraps(): ()
	for _, Tag in Tags do
		local AddFunction = TrapFunctions[Tag]

		for _, Trap in CollectionService:GetTagged(Tag) do
			if Trap:GetAttribute("Accounted") then
				continue
			end
			
			Trap:SetAttribute("Accounted", true)
			
			task.spawn(AddFunction, Trap)
		end

		CollectionService:GetInstanceAddedSignal(Tag):Connect(function(Trap: Instance): ()
			if Trap:GetAttribute("Accounted") then
				return
			end
			
			Trap:SetAttribute("Accounted", true)
			
			task.spawn(AddFunction, Trap)
		end)
	end
end

local function HandleMap(): ()
	repeat task.wait() until LocalPlayer:GetAttribute("Stage")
	
	local CurrentStage = ReplicatedStorage.Assets.Stages[LocalPlayer:GetAttribute("CurrentStage")]
	CurrentStage:SetAttribute("StageIndex", CurrentStage.Name)
	CurrentStage.Name = 'CurrentMap'
	CurrentStage.Parent = workspace
	
	LocalPlayer:GetAttributeChangedSignal("CurrentStage"):Connect(function(): ()
		local CurrentMap = workspace.CurrentMap
		CurrentMap.Name = CurrentMap:GetAttribute("StageIndex")
		CurrentMap.Parent = ReplicatedStorage.Assets.Stages
		
		local NewCurrentStage = ReplicatedStorage.Assets.Stages[LocalPlayer:GetAttribute("CurrentStage")]
		NewCurrentStage:SetAttribute("StageIndex", CurrentStage.Name)
		NewCurrentStage.Name = 'CurrentMap'
		NewCurrentStage.Parent = workspace
	end)
end

local function Init(): ()
	--HandleMap()
	HandleTraps()
end

-- Public
MapController.Init = Init
MapController.AccountDamage = AccountDamage

return MapController