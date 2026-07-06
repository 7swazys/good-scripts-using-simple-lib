local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("clicker")
local main = win:AddSection("main")

local clicking = false

main:Toggle("toggle", false, function(v)
    clicking = v
    if clicking then
        spawn(function()
            while clicking do
                local e = game:GetService("ReplicatedStorage").FastSignals.ClickFast
                e:FireServer()
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

local padsTab = win:AddSection("pads")

local padEnabled = false
local padNumber = 1

local function touchPad(num)
    local plr = game:GetService("Players").LocalPlayer
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pads = workspace:FindFirstChild("Activations")
    if not pads then return end
    local padGroup = pads:FindFirstChild("Pads")
    if not padGroup then return end
    local pad = padGroup:FindFirstChild(tostring(num))
    if not pad then return end
    local hitbox = pad:FindFirstChild("Hitbox")
    if not hitbox then return end
    local ti = hitbox:FindFirstChild("TouchInterest")
    if not ti then return end
    pcall(function()
        firetouchinterest(root, hitbox, 0)
        task.wait(0.05)
        firetouchinterest(root, hitbox, 1)
    end)
end

padsTab:Toggle("toggle", false, function(v)
    padEnabled = v
    if padEnabled then
        spawn(function()
            while padEnabled do
                touchPad(padNumber)
                task.wait()
            end
        end)
    end
end)

padsTab:TextBox("pad number", 1, function(v)
    local num = tonumber(v)
    if num and num >= 1 and num <= 20 then
        padNumber = num
    end
end)
