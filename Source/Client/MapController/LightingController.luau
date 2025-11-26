-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variables
local LightingController = {}
local LocalPlayer = Players.LocalPlayer

-- Functions
local function ConvertStageOffsetToTime(StageOffset: number): number
	local Times = {
		'Morning',
		'Day',
		'Afternoon',
		'Night',
		'Overnight'
	}
	
	return Times[StageOffset]
end

local function ConvertStageToMapIndex(Stage: number): string
	if Stage % 5 == 0 then
		return Stage / 5
	elseif Stage % 5 ~= 0 then
		while Stage % 5 ~= 0 do
			Stage += 1
		end
		
		return Stage / 5
	end
end

local function LoadLighting(Stage: number): ()
	Stage = tonumber(Stage)
	
	local MapIndex = ConvertStageToMapIndex(Stage)
	local StageOffset = Stage - (MapIndex - 1) * 5
	local MapConfig = ReplicatedStorage.Assets.Lighting:FindFirstChild(MapIndex)
	
	if not MapConfig then
		return warn(`Lighting of MapIndex {MapIndex} not found.`)
	end
	
	local Time: string = ConvertStageOffsetToTime(StageOffset)
	local LightingSettings = MapConfig[Time]

	for AttributeName, AttributeValue in LightingSettings:GetAttributes() do
		Lighting[AttributeName] = AttributeValue
	end

	for _, LightingObject in Lighting:GetChildren() do
		LightingObject:Destroy()
	end

	for _, LightingObject in LightingSettings:GetChildren() do
		local NewLightingObject = LightingObject:Clone()
		NewLightingObject.Parent = Lighting
	end
end

local function OnClientEvent(Arguments: table): ()
	LoadLighting(1)
	LoadLighting(Arguments.Stage)
end

local function Init(): ()
end

-- Public
LightingController.LoadLighting = LoadLighting
LightingController.Init = Init
LightingController.OnClientEvent = OnClientEvent

return LightingController