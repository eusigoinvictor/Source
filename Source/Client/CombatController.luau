-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Variables
local CombatController = {}
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local HealthBar = PlayerGui:WaitForChild("Hud").StatBars.HealthBar

-- Functions
local function TakeDamage(Damage: number): ()
    local MaxHealth = 100
    local NewHealth = LocalPlayer:GetAttribute("Health") - Damage
    local BarPositionX = NewHealth / MaxHealth
    
    if LocalPlayer:GetAttribute("TookDamage") then
        return
    end

    if NewHealth <= 0 then
        NewHealth = 0
        CombatController.Services.CharacterController.Respawn()  
    end

    TweenService:Create(HealthBar, TweenInfo.new(1/6), {Size = UDim2.fromScale(BarPositionX, 1)}):Play()
    LocalPlayer:SetAttribute("Health", NewHealth)
    LocalPlayer:SetAttribute("TookDamage", true)

    task.delay(1/2, function()
        LocalPlayer:SetAttribute("TookDamage", false)
    end)
end

local function InitializeAttributes(): ()
    LocalPlayer:SetAttribute("Health", 100)
end

local function Init(): ()
    InitializeAttributes()
end

-- Public
CombatController.TakeDamage = TakeDamage
CombatController.Init = Init

return CombatController