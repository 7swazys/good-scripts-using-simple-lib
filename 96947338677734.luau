local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("player")
local mainTab = win:AddSection("main")

local doing = false

local function touch()
    local plr = game:GetService("Players").LocalPlayer
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local btn = workspace:FindFirstChild("GiveWins")
    if not btn then return end
    local btn12 = btn:FindFirstChild("Button12")
    if not btn12 then return end
    local touch = btn12:FindFirstChild("Touch")
    if not touch then return end
    local ti = touch:FindFirstChild("TouchInterest")
    if not ti then return end
    pcall(function()
        firetouchinterest(root, ti.Parent, 0)
        task.wait(0.1)
        firetouchinterest(root, ti.Parent, 1)
    end)
end

mainTab:Toggle("autowin", false, function(v)
    doing = v
    if doing then
        spawn(function()
            while doing do
                touch()
                task.wait()
            end
        end)
    end
end)

local autoStep = false

mainTab:Toggle("autosteps", false, function(v)
    autoStep = v
    if autoStep then
        spawn(function()
            while autoStep do
                local e = game:GetService("ReplicatedStorage").Events.AddSpeed
                e:FireServer()
                task.wait()
            end
        end)
    end
end)

local rebirth = false

mainTab:Toggle("auto rebirth", false, function(v)
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

local trail = false

mainTab:Toggle("auto trail", false, function(v)
    trail = v
    if trail then
        spawn(function()
            while trail do
                local e = game:GetService("ReplicatedStorage").Events.TrailAction
                e:FireServer("BuyWins", "InfinityTrail")
                task.wait()
                local e2 = game:GetService("ReplicatedStorage").Events.TrailAction
                e2:FireServer("Equip", "InfinityTrail")
                task.wait()
            end
        end)
    end
end)

local playerTab = win:AddSection("player")

local speedEnabled = false
local speedValue = 16

local function setSpeed()
    local plr = game:GetService("Players").LocalPlayer
    if not plr.Character then return end
    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = speedValue
end

playerTab:Toggle("toggle", false, function(v)
    speedEnabled = v
    if speedEnabled then
        spawn(function()
            while speedEnabled do
                setSpeed()
                task.wait(0.5)
            end
        end)
    end
end)

playerTab:TextBox("walkspeed", 1, function(v)
    local num = tonumber(v)
    if num then
        speedValue = num
    end
end)
