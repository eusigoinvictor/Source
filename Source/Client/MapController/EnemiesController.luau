-- Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Variables
local EnemiesController = {}
local HealthUITemplate = ReplicatedStorage.Assets.UI.EnemyHealthBar
local Database = require(ReplicatedStorage.Modules.Database)
local RespawnTime = 15

-- Functions
local function CreateHealthUI(Enemy: Model): ()
    -- Duplicate and set parent
    local NewHealthBar = HealthUITemplate:Clone()
    NewHealthBar.Parent = Enemy.PrimaryPart

    -- Animate it
    Enemy:GetAttributeChangedSignal("Health"):Connect(function(): ()
        local XSize = Enemy:GetAttribute("Health") / Enemy:GetAttribute("MaxHealth")
        TweenService:Create(NewHealthBar.Fill, TweenInfo.new(1/6), {Size = UDim2.fromScale(XSize, 1)}):Play()
    end)
end

local function InitializeEnemy(Enemy: Model): ()
    local EnemyData = Database.Enemies[Enemy.Name]
    
    if not EnemyData then
        return warn(`Data of enemy {Enemy.Name} not found on Database.`)
    end

    Enemy:SetAttribute("Health", EnemyData.Health)
    Enemy:SetAttribute("Damage", EnemyData.Damage)
    Enemy:SetAttribute("Speed", EnemyData.Speed)
    Enemy:SetAttribute("JumpPower", EnemyData.JumpPower)
    Enemy:SetAttribute("Origin", Enemy:GetPivot())
    Enemy:SetAttribute("MaxHealth", EnemyData.Health)

    local Humanoid = Enemy.Humanoid

    if not Humanoid then
        return warn(`Humanoid not found on {Enemy.Name}`)
    end

    Humanoid.WalkSpeed = EnemyData.Speed
    Humanoid.JumpPower = EnemyData.JumpPower
end

local HitAnimation = EnemiesController.Services.CharacterController.HitAnimation

local function TakeDamage(Enemy: Model, Damage: number): ()
    local CurrentHealth = Enemy:GetAttribute('Health')

    if not Damage then
        return warn('Damage was not provided.')
    end

    if not CurrentHealth then
        return warn(`Health of enemy {Enemy.Name} hasn't been initialized.`)
    end

    local NewHealth = CurrentHealth - Damage
    HitAnimation(Enemy)

    Enemy:SetAttribute("Health", NewHealth)
end

local function DeathAnimation(Enemy: Model): ()
    for _, BasePart in Enemy:GetChildren() do
        if not BasePart:IsA("BasePart") then
            continue 
        end

        TweenService:Create(BasePart, TweenInfo.new(1/3), {Transparency = 1}):Play()
    end
end

local function Respawn(Enemy): ()
    Enemy:PivotTo(Enemy:GetAttribute("Origin"))

    for _, BasePart in Enemy:GetChildren() do
        if not BasePart:IsA("BasePart") then
            continue
        end

        TweenService:Create(BasePart, TweenInfo.new(1/3), {Transparency = 0}):Play()
    end
end

local function Kill(Enemy: Model): ()
    Enemy:SetAttribute("Health", Enemy:GetAttribute("MaxHealth"))

    task.delay(RespawnTime, Respawn, Enemy)
end

local function HandleDeath(Enemy: Model): ()
    Enemy:GetAttributeChangedSignal("Health"):Connect(function(): ()
        local Health  = Enemy:GetAttribute("Health")

        if Health <= 0 then
            DeathAnimation(Enemy) -- Lasts for 2/6
            task.wait(2/6)
            Kill(Enemy)
        end
    end)
end

local function HandleEnemy(Enemy: Model): ()
    InitializeEnemy(Enemy)
end

local function AccountEnemies(): ()
    for _, Enemy in CollectionService:GetTagged("Enemy") do
        HandleEnemy(Enemy)
    end

    CollectionService:GetInstanceAddedSignal("Enemy"):Connect(function(Enemy: Model): ()
        HandleEnemy(Enemy)
    end)
end

local function Init(): ()
    AccountEnemies()
end

-- Public
EnemiesController.Init = Init

return EnemiesController