local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()
local Window = SimpleLib:Window("brainrot grabr")
local main = Window:AddSection("main")
local rarity = Window:AddSection("raritys")

local loop = false
local sell = false
local sellDelay = 1

local gf = workspace:FindFirstChild("GameFolder")
if not gf then return end

local bf = gf:FindFirstChild("Brainrots")
if not bf then return end

local currentType = "Common"
local currentFolder = bf:FindFirstChild("Common")

local remote = RS:FindFirstChild("Remotes")
if remote then remote = remote:FindFirstChild("GrabBrainrot") end
if not remote then return end

local sellRemote = RS:FindFirstChild("Events")
if sellRemote then sellRemote = sellRemote:FindFirstChild("SellDialogue") end
if not sellRemote then return end

local TCS = game:GetService("TextChatService")

local function msg(text, success)
    pcall(function()
        TCS:DisplaySystemMessage(text, success and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0))
    end)
end

local function getBrainrots()
    if not currentFolder then return {} end
    local c = currentFolder:GetChildren()
    if #c == 0 then msg("No brainrots in " .. currentType, false) else msg("Found " .. #c .. " in " .. currentType, true) end
    return c
end

local function switchType(name)
    local folder = bf:FindFirstChild(name)
    if folder then
        currentType = name
        currentFolder = folder
        local c = folder:GetChildren()
        if #c == 0 then msg("No brainrots in " .. name, false) else msg("Switched to " .. name .. " (" .. #c .. ")", true) end
    else
        msg(name .. " folder not found", false)
    end
end

local types = {
    "Legendary (RECOMENDED)",
    "Celestial",
    "Common",
    "Epic",
    "Godly",
    "Mythic",
    "Rare",
    "Secret"
}

for _, name in ipairs(types) do
    local cleanName = name:gsub(" %(RECOMENDED%)", "")
    rarity:Button(name, function() switchType(cleanName) end)
end

main:Toggle("spam", false, function(s) loop = s end)
main:Toggle("sell", false, function(s) sell = s end)
main:TextBox("sell delay", 1, function(t)
    local n = tonumber(t)
    if n then sellDelay = math.clamp(n, 1, 100); msg("Delay set to " .. sellDelay .. "s", true) else msg("Invalid number", false) end
end)

spawn(function()
    while true do
        task.wait(0.01)
        if loop then
            for _, b in ipairs(getBrainrots()) do
                remote:FireServer(b)
                task.wait(0.01)
            end
        end
    end
end)

spawn(function()
    while true do
        task.wait(sellDelay)
        if sell then sellRemote:InvokeServer("SellAll") end
    end
end)
