local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("mace")
local main = win:AddSection("main")

local spamming = false
local delayTime = 0.1
local autoWin = false
local winDelay = 0.5
local rebirthing = false
local claimSpam = false
local claimDelay = 0.1
local trailSpam = false
local trailDelay = 0.5

local function fireMace()
    local target = workspace:FindFirstChild("testTargets")
    if not target then return end
    local children = target:GetChildren()
    local targetPart = children[40]
    if not targetPart then return end
    
    local ev = game:GetService("ReplicatedStorage").Events.MaceAttack
    if ev then
        pcall(function()
            ev:FireServer(targetPart, true, -113.06228637695)
        end)
    end
end

local function tpWin()
    local plr = game:GetService("Players").LocalPlayer
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = CFrame.new(3297, 473, 3792)
end

local function fireRebirth()
    local ev = game:GetService("ReplicatedStorage").Events.RequestRebirth
    if ev then
        pcall(function()
            ev:InvokeServer()
        end)
    end
end

local function fireClaim()
    local ev = game:GetService("ReplicatedStorage").Events.ClaimPlaytimeReward
    if ev then
        for i = 1, 6 do
            pcall(function()
                ev:FireServer("Reward" .. i)
            end)
        end
    end
end

local function fireTrail()
    local ev = game:GetService("ReplicatedStorage").Events.TrailAction
    if ev then
        pcall(function()
            ev:FireServer("BuyWins", "CosmicTrail")
            task.wait(0.1)
            ev:FireServer("Equip", "CosmicTrail")
        end)
    end
end

main:Toggle("toggle", false, function(v)
    spamming = v
    if spamming then
        spawn(function()
            while spamming do
                fireMace()
                task.wait(delayTime)
            end
        end)
    end
end)

main:Slider("delay", 0.001, 1, 0.1, function(v)
    delayTime = v
end)

main:Toggle("auto win", false, function(v)
    autoWin = v
    if autoWin then
        spawn(function()
            while autoWin do
                tpWin()
                task.wait(winDelay)
            end
        end)
    end
end)

main:Slider("win delay", 0.05, 2, 0.5, function(v)
    winDelay = v
end)

main:Toggle("auto rebirth", false, function(v)
    rebirthing = v
    if rebirthing then
        spawn(function()
            while rebirthing do
                fireRebirth()
                task.wait()
            end
        end)
    end
end)

main:Toggle("auto claim", false, function(v)
    claimSpam = v
    if claimSpam then
        spawn(function()
            while claimSpam do
                fireClaim()
                task.wait(claimDelay)
            end
        end)
    end
end)

main:Slider("claim delay", 0.05, 2, 0.1, function(v)
    claimDelay = v
end)

main:Toggle("auto trail", false, function(v)
    trailSpam = v
    if trailSpam then
        spawn(function()
            while trailSpam do
                fireTrail()
                task.wait(trailDelay)
            end
        end)
    end
end)

main:Slider("trail delay", 0.05, 2, 0.5, function(v)
    trailDelay = v
end)
