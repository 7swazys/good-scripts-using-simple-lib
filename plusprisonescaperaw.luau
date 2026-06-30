local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("gameprisonshitbrainrotgamefuck")
local main = win:AddSection("main")

local doing = false
local waitTime = 0.5
local rebirth = false
local speed = false

local function go()
    local plr = game:GetService("Players").LocalPlayer
    if plr.Character then
        pcall(function()
            plr.Character:PivotTo(CFrame.new(-5897, 95, -969))
        end)
    end
end

main:Toggle("toggle", false, function(v)
    doing = v
    if doing then
        spawn(function()
            while doing do
                go()
                task.wait(waitTime)
            end
        end)
    end
end)

main:Slider("slider", 0.05, 2, 0.5, function(v)
    waitTime = v
end)

main:Toggle("auto rebirth", false, function(v)
    rebirth = v
    if rebirth then
        spawn(function()
            while rebirth do
                local e = game:GetService("ReplicatedStorage").Events.RequestRebirth
                e:InvokeServer()
                task.wait()
            end
        end)
    end
end)

main:Toggle("auto speed", false, function(v)
    speed = v
    if speed then
        spawn(function()
            while speed do
                local e = game:GetService("ReplicatedStorage").Events.AddSpeed
                e:FireServer()
                task.wait()
            end
        end)
    end
end)
