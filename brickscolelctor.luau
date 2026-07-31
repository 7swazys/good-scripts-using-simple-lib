
-- fuck the games leaderboards up
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()
local Window = SimpleLib:Window("collectprbrickgame")
local mainTab = Window:AddSection("ruin game ecmony")

local isLooping = false
local isUpgradeLooping = false
local isSpawnLooping = false

local function loopInvoke()
    local remote = replicatedStorage:FindFirstChild("GetBitValue")
    if not remote then return end
    
    while isLooping do
        remote:InvokeServer("Yellow Sparkle Time bit")
        task.wait(0.1)
    end
end

local function loopUpgrade()
    local multiplier = replicatedStorage:FindFirstChild("BuyMultiplierUpgrade")
    local speed = replicatedStorage:FindFirstChild("BuySpeedUpgrade")
    
    while isUpgradeLooping do
        if multiplier then
            multiplier:InvokeServer()
        end
        if speed then
            speed:InvokeServer()
        end
        task.wait(0.1)
    end
end

local function loopSpawn()
    local event = replicatedStorage:FindFirstChild("SpawnBit")
    if not event then return end
    
    while isSpawnLooping do
        firesignal(event.OnClientEvent, 
            "Yellow Sparkle Time bit",
            CFrame.new(-0, 15, -120)
        )
        task.wait(0.1)
    end
end

mainTab:Toggle("give bits", false, function(state)
    isLooping = state
    if state then
        spawn(loopInvoke)
    end
end)

mainTab:Toggle("auto upgrade", false, function(state)
    isUpgradeLooping = state
    if state then
        spawn(loopUpgrade)
    end
end)

mainTab:Toggle("spawn bit", false, function(state)
    isSpawnLooping = state
    if state then
        spawn(loopSpawn)
    end
end)
