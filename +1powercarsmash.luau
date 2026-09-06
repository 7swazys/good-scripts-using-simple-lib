local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()
local Window = SimpleLib:Window("carsmashgame")
local mainTab = Window:AddSection("main")
local winTab = Window:AddSection("win required")
local glovesTab = Window:AddSection("gloves")
local petsTab = Window:AddSection("pets")
local trainingTab = Window:AddSection("training")

local buyRemote = replicatedStorage:FindFirstChild("Shared")
if buyRemote then
    buyRemote = buyRemote:FindFirstChild("Packages")
    if buyRemote then
        buyRemote = buyRemote:FindFirstChild("Net")
        if buyRemote then
            buyRemote = buyRemote:FindFirstChild("RE/GloveNet_Buy")
        end
    end
end

local equipRemote = replicatedStorage:FindFirstChild("Shared")
if equipRemote then
    equipRemote = equipRemote:FindFirstChild("Packages")
    if equipRemote then
        equipRemote = equipRemote:FindFirstChild("Net")
        if equipRemote then
            equipRemote = equipRemote:FindFirstChild("RE/GloveNet_Equip")
        end
    end
end

local clickRemote = replicatedStorage:FindFirstChild("Shared")
if clickRemote then
    clickRemote = clickRemote:FindFirstChild("Packages")
    if clickRemote then
        clickRemote = clickRemote:FindFirstChild("Net")
        if clickRemote then
            clickRemote = clickRemote:FindFirstChild("RE/ClickNet_Click")
        end
    end
end

local winRemote = replicatedStorage:FindFirstChild("Shared")
if winRemote then
    winRemote = winRemote:FindFirstChild("Packages")
    if winRemote then
        winRemote = winRemote:FindFirstChild("Net")
        if winRemote then
            winRemote = winRemote:FindFirstChild("RE/WinNet_Claim")
        end
    end
end

local rebirthRemote = replicatedStorage:FindFirstChild("Shared")
if rebirthRemote then
    rebirthRemote = rebirthRemote:FindFirstChild("Packages")
    if rebirthRemote then
        rebirthRemote = rebirthRemote:FindFirstChild("Net")
        if rebirthRemote then
            rebirthRemote = rebirthRemote:FindFirstChild("RE/RebirthNet_Rebirth")
        end
    end
end

local eggRemote = replicatedStorage:FindFirstChild("Shared")
if eggRemote then
    eggRemote = eggRemote:FindFirstChild("Packages")
    if eggRemote then
        eggRemote = eggRemote:FindFirstChild("Net")
        if eggRemote then
            eggRemote = eggRemote:FindFirstChild("RF/PetNet_OpenEgg")
        end
    end
end

local boostRemote = replicatedStorage:FindFirstChild("Shared")
if boostRemote then
    boostRemote = boostRemote:FindFirstChild("Packages")
    if boostRemote then
        boostRemote = boostRemote:FindFirstChild("Net")
        if boostRemote then
            boostRemote = boostRemote:FindFirstChild("RE/BoostNet_Upgrade")
        end
    end
end

local upgradeRemote = replicatedStorage:FindFirstChild("Shared")
if upgradeRemote then
    upgradeRemote = upgradeRemote:FindFirstChild("Packages")
    if upgradeRemote then
        upgradeRemote = upgradeRemote:FindFirstChild("Net")
        if upgradeRemote then
            upgradeRemote = upgradeRemote:FindFirstChild("RE/UpgradeNet_Upgrade")
        end
    end
end

if not buyRemote then
    print("RE/GloveNet_Buy remote not found")
end

if not equipRemote then
    print("RE/GloveNet_Equip remote not found")
end

if not clickRemote then
    print("RE/ClickNet_Click remote not found")
end

if not winRemote then
    print("RE/WinNet_Claim remote not found")
end

if not rebirthRemote then
    print("RE/RebirthNet_Rebirth remote not found")
end

if not eggRemote then
    print("RF/PetNet_OpenEgg remote not found")
end

if not boostRemote then
    print("RE/BoostNet_Upgrade remote not found")
end

if not upgradeRemote then
    print("RE/UpgradeNet_Upgrade remote not found")
end

local isClickLooping = false
local isWinLooping = false
local isRebirthLooping = false
local isEggLooping = false
local isBoostLooping = false
local isUpgradeLooping = false
local eggType = 7

local boostTypes = {"Damage", "Wins", "Luck", "TitleLuck"}
local statTypes = {"WalkSpeed", "TrainSpeed", "AttackSpeed"}

local trainingPositions = {
    {1907, 10, -64},
    {1937, 11, -64},
    {1975, 11, -62},
    {1996, 11, -62},
    {2032, 11, -61},
    {1904, 11, -105}
}

local function buyGloves()
    if not buyRemote then return end
    for i = 1, 16 do
        buyRemote:FireServer(i)
        task.wait(0.05)
    end
    print("bought all gloves")
end

local function equipGloves()
    if not equipRemote then return end
    for i = 1, 16 do
        equipRemote:FireServer(i)
        task.wait(0.05)
    end
    print("equipped all gloves")
end

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos[1], pos[2], pos[3])
    end
end

mainTab:Toggle("auto click", false, function(state)
    isClickLooping = state
end)

mainTab:Toggle("auto rebirth", false, function(state)
    isRebirthLooping = state
end)

winTab:Toggle("auto win", false, function(state)
    isWinLooping = state
end)

winTab:Toggle("auto boost upgrade", false, function(state)
    isBoostLooping = state
end)

winTab:Toggle("auto stat upgrade", false, function(state)
    isUpgradeLooping = state
end)

glovesTab:Button("buy gloves", function()
    buyGloves()
end)

glovesTab:Button("equip gloves", function()
    equipGloves()
end)

petsTab:Toggle("auto open egg", false, function(state)
    isEggLooping = state
end)

petsTab:Slider("egg type", 1, 7, 7, function(value)
    eggType = math.floor(value)
end)

for i, pos in ipairs(trainingPositions) do
    trainingTab:Button("tp to training " .. i, function()
        teleportTo(pos)
    end)
end

spawn(function()
    while true do
        task.wait(0.1)
        if isClickLooping and clickRemote then
            clickRemote:FireServer()
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isWinLooping and winRemote then
            winRemote:FireServer(1, 15, false)
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isRebirthLooping and rebirthRemote then
            rebirthRemote:FireServer()
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isEggLooping and eggRemote then
            eggRemote:InvokeServer(eggType)
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isBoostLooping and boostRemote then
            for _, boost in ipairs(boostTypes) do
                boostRemote:FireServer(boost)
                task.wait(0.05)
            end
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.1)
        if isUpgradeLooping and upgradeRemote then
            for _, stat in ipairs(statTypes) do
                upgradeRemote:FireServer(stat)
                task.wait(0.05)
            end
        end
    end
end)
