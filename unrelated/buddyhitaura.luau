--[[
u need 2 equip broom and buddy needs to spawn in first 
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local remote = replicatedStorage:FindFirstChild("ChillAhhRemotes")

if remote then
    remote = remote:FindFirstChild("WeaponsEtc")
    if remote then
        remote = remote:FindFirstChild("AttackObj")
    end
end

if not remote then
    print("remote not found")
    return
end

local buddy = workspace:FindFirstChild("BUDDYTV")
if not buddy then
    print("BUDDYTV not found")
    return
end

local BD = buddy:FindFirstChild("BuddyCollision")
if not BD then
    print("BuddyCollision not found")
    return
end

local isLooping = true

spawn(function()
    while isLooping do
        local buddyPos = BD.Position
        remote:FireServer(
            BD,
            {
                CFrame = CFrame.new(buddyPos.X, buddyPos.Y, buddyPos.Z)
            }
        )
        task.wait(0.1)
    end
end)

