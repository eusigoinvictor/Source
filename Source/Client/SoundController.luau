-- Services
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local SoundController = {}
local LocalPlayer = Players.LocalPlayer
local Music: Sound

-- Functions
local function PlayRandomMusic(): ()
	if Music then
		Music:Stop()
	end
	
	Music = SoundService.Musics:GetChildren()[math.random(#SoundService.Musics:GetChildren())]
	Music.Ended:Once(PlayRandomMusic)
	Music:Play()
end

local function PlaySound(SoundName: string): ()
	local SoundToPlay = SoundService:FindFirstChild(SoundName)

	if not SoundToPlay then
		return warn(`Sound {SoundToPlay} not found.`)
	end

	SoundService:PlayLocalSound(SoundToPlay)
end

local function OnClientEvent(Arguments: table): ()
	if Arguments.PlaySound then
		PlaySound(Arguments.PlaySound)
	end
end

local function Init(): ()
	PlayRandomMusic()
	
	LocalPlayer:GetAttributeChangedSignal("CurrentStage"):Connect(PlayRandomMusic)
end

-- Public
SoundController.Init = Init
SoundController.PlaySound = PlaySound
SoundController.OnClientEvent = OnClientEvent

return SoundController