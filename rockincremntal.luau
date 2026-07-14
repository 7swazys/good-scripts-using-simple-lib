local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("rockgameicnremntal")
local main = win:AddSection("main")

local coords = {
    Vector3.new(55.279624938964844, 7.893322944641113, -197.06536865234375),
    Vector3.new(32.62126541137695, 7.994151592254639, -197.0240020751953),
    Vector3.new(27.63102912902832, 7.926741600036621, -193.0339813232422),
    Vector3.new(58.319786071777344, 7.993975639343262, -192.20826721191406),
    Vector3.new(62.5992431640625, 7.926564693450928, -189.54527282714844),
    Vector3.new(26.142751693725586, 7.993866920471191, -190.3249053955078),
    Vector3.new(23.456140518188477, 7.960134983062744, -188.16163635253906),
    Vector3.new(63.109493255615234, 7.960139274597168, -187.23011779785156),
    Vector3.new(63.03409957885742, 7.960143089294434, -183.63096618652344),
    Vector3.new(23.24785614013672, 7.960124492645264, -184.45407104492188),
    Vector3.new(62.07160949707031, 7.993790626525879, -180.48768615722656),
    Vector3.new(24.223970413208008, 7.993772506713867, -181.65834045410156),
    Vector3.new(24.075395584106445, 7.993764877319336, -176.9939727783203),
    Vector3.new(62.86204528808594, 7.993751049041748, -176.0153350830078),
    Vector3.new(62.73359680175781, 7.993746757507324, -169.88339233398438),
    Vector3.new(24.2064151763916, 7.993758678436279, -170.1871337890625),
    Vector3.new(23.980302810668945, 7.993713855743408, -165.7923583984375),
    Vector3.new(59.801292419433594, 7.9937262535095215, -164.03988647460938),
    Vector3.new(57.16554641723633, 7.993716239929199, -160.46910095214844),
    Vector3.new(28.40406608581543, 7.993720054626465, -161.9465789794922),
    Vector3.new(31.404766082763672, 7.960103988647461, -158.21340942382812),
    Vector3.new(53.787315368652344, 7.993706703186035, -157.38800048828125)
}

local tweening = false
local speed = 1
local currentIndex = 1

local function tweenToNext()
    if not tweening then return end
    local plr = game:GetService("Players").LocalPlayer
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local target = coords[currentIndex]
    if not target then
        currentIndex = 1
        target = coords[currentIndex]
    end
    
    local distance = (root.Position - target).Magnitude
    local time = distance / (speed * 10)
    
    local tween = game:GetService("TweenService"):Create(root, TweenInfo.new(time, Enum.EasingStyle.Linear), {
        CFrame = CFrame.new(target)
    })
    tween:Play()
    tween.Completed:Wait()
    
    currentIndex = currentIndex + 1
    if currentIndex > #coords then
        currentIndex = 1
    end
end

main:Toggle("toggle", false, function(v)
    tweening = v
    if tweening then
        spawn(function()
            while tweening do
                tweenToNext()
            end
        end)
    end
end)

main:Slider("speed", 0.1, 5, 1, function(v)
    speed = v
end)

local bonkEnabled = false
local bonkDelay = 0.1

local function fireBonk()
    local ev = game:GetService("ReplicatedStorage").Remotes.BonkClick
    if ev then
        pcall(function()
            ev:FireServer()
        end)
    end
end

main:Toggle("auto bonk", false, function(v)
    bonkEnabled = v
    if bonkEnabled then
        spawn(function()
            while bonkEnabled do
                fireBonk()
                task.wait(bonkDelay)
            end
        end)
    end
end)

main:Slider("bonk delay", 0.001, 1, 0.1, function(v)
    bonkDelay = v
end)

local upgradesTab = win:AddSection("upgrades")

local upgrading = false
local upgradeDelay = 0.5

local function fireUpgrades()
    local remotes = game:GetService("ReplicatedStorage").Remotes
    local upgrades = {
        "FasterRocks",
        "MaxRocks",
        "MoreRocks",
        "FasterRocksRebirth",
        "MoreRadius",
        "MoreRocksRebirth",
        "AutoClickerBonk",
        "MoreRocksBonk",
        "MoreRebirthsBonk"
    }
    for _, name in pairs(upgrades) do
        local ev = remotes:FindFirstChild("BuyUpgrade")
        if ev then
            pcall(function()
                ev:FireServer(name, "max")
            end)
        end
    end
end

upgradesTab:Toggle("auto upgrade", false, function(v)
    upgrading = v
    if upgrading then
        spawn(function()
            while upgrading do
                fireUpgrades()
                task.wait(upgradeDelay)
            end
        end)
    end
end)

upgradesTab:Slider("upgrade delay", 0.05, 2, 0.5, function(v)
    upgradeDelay = v
end)

local rebirthTab = win:AddSection("rebirth")

local rebirthing = false

local function fireRebirth()
    local ev = game:GetService("ReplicatedStorage").Remotes.RequestRebirth
    if ev then
        pcall(function()
            ev:FireServer()
        end)
    end
end

rebirthTab:Toggle("auto rebirth", false, function(v)
    rebirthing = v
    if rebirthing then
        spawn(function()
            while rebirthing do
                fireRebirth()
                task.wait()
            end
        end)
    end
end)
