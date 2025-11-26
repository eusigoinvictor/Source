-- Services
local ServerStorage = game:GetService("ServerStorage")

-- Variables
local MapController = {}

-- Functions
local function Init(): ()
	ServerStorage.Stages.Parent = workspace
end

-- Public
MapController.Init = Init

return MapController