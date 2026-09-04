local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()
local Window = SimpleLib:Window("infinite")
local mainTab = Window:AddSection("main")

local healthRemote = replicatedStorage:FindFirstChild("Events")
if healthRemote then
    healthRemote = healthRemote:FindFirstChild("ChangingPlayerHealth")
end

local genRemote = replicatedStorage:FindFirstChild("Events")
if genRemote then
    genRemote = genRemote:FindFirstChild("ChangingGeneratorHealth")
end

if not healthRemote then
    print("ChangingPlayerHealth remote not found")
end

if not genRemote then
    print("ChangingGeneratorHealth remote not found")
end

local isHealthLooping = false
local isGenLooping = false

mainTab:Toggle("inf hp", false, function(state)
    isHealthLooping = state
end)

mainTab:Toggle("inf gen hp", false, function(state)
    isGenLooping = state
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isHealthLooping and healthRemote then
            healthRemote:FireServer(-1333333333333, true)
        end
        if isGenLooping and genRemote then
            genRemote:FireServer()
        end
    end
end)
