local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("clicker")
local main = win:AddSection("main")

local clicking = false

main:Toggle("toggle", false, function(v)
    clicking = v
    if clicking then
        spawn(function()
            while clicking do
                local e = game:GetService("ReplicatedStorage").Click.Click
                e:FireServer()
                task.wait()
            end
        end)
    end
end)

local upgradeEnabled = false

local function fireUpgrades()
    local shop = game:GetService("ReplicatedStorage"):FindFirstChild("Shop")
    if shop then
        for _, child in pairs(shop:GetChildren()) do
            if child:IsA("RemoteEvent") then
                pcall(function()
                    child:FireServer()
                end)
            end
        end
    end
    local fish = game:GetService("ReplicatedStorage"):FindFirstChild("FishUpgrades")
    if fish then
        for _, child in pairs(fish:GetChildren()) do
            if child:IsA("RemoteEvent") then
                pcall(function()
                    child:FireServer()
                end)
            end
        end
    end
end

main:Toggle("auto upgrade", false, function(v)
    upgradeEnabled = v
    if upgradeEnabled then
        spawn(function()
            while upgradeEnabled do
                fireUpgrades()
                task.wait()
            end
        end)
    end
end)

local fishEnabled = false

main:Toggle("auto fish", false, function(v)
    fishEnabled = v
    if fishEnabled then
        spawn(function()
            while fishEnabled do
                local e = game:GetService("ReplicatedStorage").CurrencyTransaction
                e:FireServer("add", 1133344444444444444444499999999999999999999)
                task.wait()
            end
        end)
    end
end)

local rebirthEnabled = false

main:Toggle("auto rebirth", false, function(v)
    rebirthEnabled = v
    if rebirthEnabled then
        spawn(function()
            while rebirthEnabled do
                local e = game:GetService("ReplicatedStorage").Rebirth
                e:FireServer()
                task.wait()
            end
        end)
    end
end)
