--when i saw the thumbnail i kne wi had to click 

local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("cash tp")
local main = win:AddSection("main")

local doing = false
local waitTime = 0.5
local step = false
local rebirth = false

local function go()
    local plr = game:GetService("Players").LocalPlayer
    if plr.Character then
        pcall(function()
            plr.Character:PivotTo(CFrame.new(1, 10, -9076))
        end)
    end
end

main:Toggle("autocash", false, function(v)
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

main:Slider("slider 4 auto cash speed", 0.05, 2, 0.5, function(v)
    waitTime = v
end)

main:Toggle("auto level", false, function(v)
    step = v
    if step then
        spawn(function()
            while step do
                local e = game:GetService("ReplicatedStorage").Remotes.StepTaken
                e:FireServer(1339999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999, false)
                task.wait()
            end
        end)
    end
end)

main:Toggle("auto rebirth", false, function(v)
    rebirth = v
    if rebirth then
        spawn(function()
            while rebirth do
                local e = game:GetService("ReplicatedStorage").Remotes.RequestRebirth
                e:FireServer("free")
                task.wait()
            end
        end)
    end
end)
