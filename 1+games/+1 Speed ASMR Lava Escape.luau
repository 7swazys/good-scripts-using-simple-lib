--for +1 Speed ASMR Lava Escape
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("anotherslopgame")
local mainTab = win:AddSection("main")

local doing = false

local function touch()
    local plr = game:GetService("Players").LocalPlayer
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    pcall(function()
        root.CFrame = CFrame.new(-1167, 116, -3071)
        task.wait(0.2)
    end)

    local giveWins = workspace:FindFirstChild("GiveWins")
    if not giveWins then return end

    local children = giveWins:GetChildren()
    for i = 1, 11 do
        local target = children[i]
        if target then
            local touch = target:FindFirstChild("Touch")
            if touch then
                local ti = touch:FindFirstChild("TouchInterest")
                if ti then
                    pcall(function()
                        firetouchinterest(root, ti.Parent, 0)
                        task.wait(0.05)
                        firetouchinterest(root, ti.Parent, 1)
                    end)
                end
            end
        end
    end
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
                e:FireServer("BuyWins", "EruptionTrail", nil)
                task.wait()
                local e2 = game:GetService("ReplicatedStorage").Events.TrailAction
                e2:FireServer("Equip", "EruptionTrail")
                task.wait()
            end
        end)
    end
end)

local claimTab = win:AddSection("claim")

for i = 1, 6 do
    claimTab:Button("claim " .. i, function()
        local e = game:GetService("ReplicatedStorage").Events.PlaytimeRewardAction
        e:FireServer("Claim", i)
    end)
end

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
