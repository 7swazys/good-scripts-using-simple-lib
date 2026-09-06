local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("click")
local main = win:AddSection("main")

local clicking = false
local selling = false
local batch1 = false
local batch2 = false
local batch3 = false
local batch4 = false
local batch5 = false
local batch6 = false
local batch7 = false
local batch8 = false
local batch9 = false

local function fireClick()
    local ev = game:GetService("ReplicatedStorage").Remotes.Server.Click
    if ev then pcall(function() ev:FireServer() end) end
end

local function fireSell()
    local ev = game:GetService("ReplicatedStorage").Remotes.Server.SellAllLoot
    if ev then pcall(function() ev:FireServer() end) end
end

local function fireWall(a, b)
    local ev = game:GetService("ReplicatedStorage").Remotes.Server.HitWall
    if ev then pcall(function() ev:FireServer(a, b) end) end
end

main:Toggle("toggle", false, function(v)
    clicking = v
    if clicking then
        spawn(function()
            while clicking do
                fireClick()
                task.wait()
            end
        end)
    end
end)

main:Toggle("auto sell", false, function(v)
    selling = v
    if selling then
        spawn(function()
            while selling do
                fireSell()
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 1 (1,1-3)", false, function(v)
    batch1 = v
    if batch1 then
        spawn(function()
            while batch1 do
                fireWall(1, 1)
                task.wait()
                fireWall(1, 2)
                task.wait()
                fireWall(1, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 2 (2,1-3)", false, function(v)
    batch2 = v
    if batch2 then
        spawn(function()
            while batch2 do
                fireWall(2, 1)
                task.wait()
                fireWall(2, 2)
                task.wait()
                fireWall(2, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 3 (3,1-3)", false, function(v)
    batch3 = v
    if batch3 then
        spawn(function()
            while batch3 do
                fireWall(3, 1)
                task.wait()
                fireWall(3, 2)
                task.wait()
                fireWall(3, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 4 (4,1-3)", false, function(v)
    batch4 = v
    if batch4 then
        spawn(function()
            while batch4 do
                fireWall(4, 1)
                task.wait()
                fireWall(4, 2)
                task.wait()
                fireWall(4, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 5 (5,1-3)", false, function(v)
    batch5 = v
    if batch5 then
        spawn(function()
            while batch5 do
                fireWall(5, 1)
                task.wait()
                fireWall(5, 2)
                task.wait()
                fireWall(5, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 6 (6,1-3)", false, function(v)
    batch6 = v
    if batch6 then
        spawn(function()
            while batch6 do
                fireWall(6, 1)
                task.wait()
                fireWall(6, 2)
                task.wait()
                fireWall(6, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 7 (7,1-3)", false, function(v)
    batch7 = v
    if batch7 then
        spawn(function()
            while batch7 do
                fireWall(7, 1)
                task.wait()
                fireWall(7, 2)
                task.wait()
                fireWall(7, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 8 (8,1-3)", false, function(v)
    batch8 = v
    if batch8 then
        spawn(function()
            while batch8 do
                fireWall(8, 1)
                task.wait()
                fireWall(8, 2)
                task.wait()
                fireWall(8, 3)
                task.wait()
            end
        end)
    end
end)

main:Toggle("batch 9 (9,1-3)", false, function(v)
    batch9 = v
    if batch9 then
        spawn(function()
            while batch9 do
                fireWall(9, 1)
                task.wait()
                fireWall(9, 2)
                task.wait()
                fireWall(9, 3)
                task.wait()
            end
        end)
    end
end)
