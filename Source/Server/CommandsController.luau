-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Database = require(ReplicatedStorage.Modules.Database)

-- Variables
local CommandsController = {}
local Admins = {
	'holeyinone'
}

-- Private
local Commands = {
	['/deaths'] = function(...): ()
		local Player, Deaths = ...
						
		Player = Players:FindFirstChild(Player)
		Deaths = tonumber(Deaths)
		
		if not Player or not Deaths then
			return
		end
		
		CommandsController.Services.DataController.LoadedData[Player.UserId].Deaths = Deaths
		Player:SetAttribute("Deaths", tonumber(Deaths))	
	end,
	
	['/stage'] = function(...): ()
		local Player, Stage = ...

		Player = Players:FindFirstChild(Player)
		Stage = tonumber(Stage)

		if not Player or not Stage then
			return
		end

		CommandsController.Services.DataController.LoadedData[Player.UserId].Stage = tonumber(Stage)
		Player:SetAttribute("CurrentStage", tonumber(Stage))
		CommandsController.Services.TeleportController.SetStage(Player, tonumber(Stage), true)
	end,
	
	['/rebirths'] = function(...): ()
		local Player, Rebirths = ...
		
		Player = Players:FindFirstChild(Player)
		Rebirths = tonumber(Rebirths)
		
		if not Player or not Rebirths then
			return
		end
		
		CommandsController.Services.DataController.LoadedData[Player.UserId].Rebirths = Rebirths
		Player:SetAttribute("Rebirths", Rebirths)
	end,
	
	['/coins'] = function(...): ()
		local Player, Coins = ...
		
		Player = Players:FindFirstChild(Player)
		Coins = tonumber(Coins)
		
		if not Player or not Coins then
			return
		end
		
		CommandsController.Services.DataController.LoadedData[Player.UserId].Coins = Coins
		Player:SetAttribute("Coins", Coins)
	end,
}

local function Init(): ()
	local function Run(Message: string, LocalPlayer: Player): ()
		for CommandName, Function in Commands do
			if not string.find(Message, CommandName) or not string.find(Message, ' ') then
				continue
			end

			local Arg1Position = string.find(Message, ' ')
			local Arg2Position = string.find(Message, ' ', Arg1Position + 1)

			if Arg2Position then
				local Arg1 = Message:sub(Arg1Position + 1, Arg2Position - 1)
				local Arg2 = Message:sub(Arg2Position + 1)

				Function(Arg1, Arg2)
			else
				local Arg1 = Message:sub(Arg1Position + 1)

				Function(Arg1)	
			end
		end
	end

	for _, Player in Players:GetPlayers() do
		if not table.find(Admins, Player.Name) then
			continue
		end

		Player.Chatted:Connect(Run, Player)
	end

	Players.PlayerAdded:Connect(function(Player: Player): ()
		if not table.find(Admins, Player.Name) then
			return
		end

		Player.Chatted:Connect(Run, Player)
	end)
end

-- Public
CommandsController.Init = Init

return CommandsController