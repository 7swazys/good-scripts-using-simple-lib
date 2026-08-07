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

local event = replicatedStorage:FindFirstChild("SpawnBit")
local bitNames = {}
for _, bit in ipairs(workspace.Bits:GetChildren()) do
    if bit.Name ~= "ZZZZZZZ" then
        table.insert(bitNames, bit.Name)
    end
end

local function loopInvoke()
    local remote = replicatedStorage:FindFirstChild("GetBitValue")
    if not remote then return end
    
    while isLooping do
        remote:InvokeServer("Unknown bit")
        task.wait(0.01)
    end
end


local function loopUpgrade()
    local multiplier = replicatedStorage:FindFirstChild("BuyMultiplierUpgrade")
    local speed = replicatedStorage:FindFirstChild("BuySpeedUpgrade")
    local brickspeed = replicatedStorage:FindFirstChild("BuySpawnSpeedUpgrade")
    
    while isUpgradeLooping do
        if multiplier then
            multiplier:InvokeServer()
        end
        if speed then
            speed:InvokeServer()
        end
        if brickspeed then
            brickspeed:InvokeServer()
        end
        task.wait(0.01)
    end
end

local function loopSpawn()
    if not event then return end
    local index = 1
    
    while isSpawnLooping do
        local bitName = bitNames[index]
        if bitName then
            firesignal(event.OnClientEvent, 
                bitName,
                CFrame.new(-0, 15, -120)
            )
        end
        index = index + 1
        if index > #bitNames then
            index = 1
        end
        task.wait(0.01)
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
