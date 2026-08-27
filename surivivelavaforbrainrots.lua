--any skids wanna make the script better go do that ig 

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()
local Window = SimpleLib:Window("brainrot autograb thing")
local mainTab = Window:AddSection("main")

local isLooping = false
local isSellLooping = false

local brainrots = workspace:FindFirstChild("GameFolder")
if brainrots then
    brainrots = brainrots:FindFirstChild("Brainrots")
    if brainrots then
        brainrots = brainrots:FindFirstChild("Common")
    end
end

if not brainrots then
    print("Common brainrots folder not found")
    return
end

local remote = replicatedStorage:FindFirstChild("Remotes")
if remote then
    remote = remote:FindFirstChild("GrabBrainrot")
end

if not remote then
    print("GrabBrainrot remote not found")
    return
end

local sellRemote = replicatedStorage:FindFirstChild("Events")
if sellRemote then
    sellRemote = sellRemote:FindFirstChild("SellDialogue")
end

if not sellRemote then
    print("SellDialogue remote not found")
    return
end

local function getBrainrots()
    return brainrots:GetChildren()
end

mainTab:Toggle("spam brainrot", false, function(state)
    isLooping = state
end)

mainTab:Toggle("auto sell", false, function(state)
    isSellLooping = state
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isLooping then
            local children = getBrainrots()
            for _, brainrot in ipairs(children) do
                remote:FireServer(brainrot)
                task.wait(0.05)
            end
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isSellLooping then
            sellRemote:InvokeServer("SellAll")
        end
    end
end)
