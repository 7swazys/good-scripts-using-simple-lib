local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("godmodelol")
local main = win:AddSection("main")

local spamming = false
local delayTime = 0.1
local godmode = false

local types = {"Gold", "Amethyst", "Sapphire"}
local currentType = 1

local function fireMoney()
    local ev = game:GetService("ReplicatedStorage").Remotes.Money
    if ev then
        pcall(function()
            ev:FireServer(types[currentType])
            currentType = currentType % #types + 1
        end)
    end
end

local function fireHeal()
    local ev = game:GetService("ReplicatedStorage").Remotes.Heal
    if ev then
        pcall(function()
            ev:FireServer()
        end)
    end
end

main:Toggle("toggle", false, function(v)
    spamming = v
    if spamming then
        spawn(function()
            while spamming do
                fireMoney()
                task.wait(delayTime)
            end
        end)
    end
end)

main:Slider("delay", 0.001, 1, 0.1, function(v)
    delayTime = v
end)

main:Toggle("godmode", false, function(v)
    godmode = v
    if godmode then
        spawn(function()
            while godmode do
                fireHeal()
                task.wait(0.05)
            end
        end)
    end
end)
