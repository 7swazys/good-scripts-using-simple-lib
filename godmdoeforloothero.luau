local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("ts2funnylol")
local main = win:AddSection("main")

local spamming = false
local delayTime = 0.1
local godmode = false
local infChoices = false

local types = {"Gold", "Amethyst", "Sapphire"}
local currentType = 1

local defaultChoices = {"Spades", "Trident", "Meteor", "Darkflame", "Tornado", "Bullet", "Anchor", "Toxin", "Giant", "Tower", "Nimble", "Skull", "Venom", "Rocket", "Ammo", "Knight", "Bandage", "Target", "Storm", "Apple", "Dice", "Arrows", "Bloodlust"}
local configFile = "LootHeroConfig.txt"

local function loadConfig()
    if not isfile then return defaultChoices end
    if not isfile(configFile) then
        writefile(configFile, table.concat(defaultChoices, ","))
        return defaultChoices
    end
    local content = readfile(configFile)
    if content == "" then return defaultChoices end
    local choices = {}
    for _, name in pairs(string.split(content, ",")) do
        local trimmed = name:gsub("^%s*(.-)%s*$", "%1")
        if trimmed ~= "" then
            table.insert(choices, trimmed)
        end
    end
    if #choices == 0 then return defaultChoices end
    return choices
end

local allChoices = loadConfig()

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

local function fireChoice(choice)
    local ev = game:GetService("ReplicatedStorage").Remotes.Choice
    if ev then
        pcall(function()
            ev:FireServer(choice)
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

main:Toggle("inf choices", false, function(v)
    infChoices = v
    if infChoices then
        spawn(function()
            local idx = 1
            while infChoices do
                fireChoice(allChoices[idx])
                idx = idx % #allChoices + 1
                task.wait(0.05)
            end
        end)
    end
end)

main:TextBox("edit config (comma separated)", 1, function(v)
    if v and v ~= "" then
        local newChoices = {}
        for _, name in pairs(string.split(v, ",")) do
            local trimmed = name:gsub("^%s*(.-)%s*$", "%1")
            if trimmed ~= "" then
                table.insert(newChoices, trimmed)
            end
        end
        if #newChoices > 0 then
            allChoices = newChoices
            if isfile then
                writefile(configFile, table.concat(newChoices, ","))
            end
        end
    end
end)
