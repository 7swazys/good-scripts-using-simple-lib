local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local Window = SimpleLib:Window("ramp gaem")
local MainTab = Window:AddSection("remotes")

local cashLooping = false
local rebirthLooping = false
local multiplierLooping = false

local cashThread = nil
local rebirthThread = nil
local multiplierThread = nil

local cashValue = 1000000000000000000000000000000000
local cashAmount = 1

MainTab:Toggle("money giver", false, function(state)
    cashLooping = state
    if cashLooping then
        cashThread = task.spawn(function()
            while cashLooping do
                local Event = game:GetService("ReplicatedStorage").CashOutEvent
                Event:FireServer(cashValue, cashAmount)
                task.wait(0.1)
            end
        end)
    else
        cashLooping = false
        if cashThread then
            task.cancel(cashThread)
            cashThread = nil
        end
    end
end)

MainTab:Toggle("rebirth", false, function(state)
    rebirthLooping = state
    if rebirthLooping then
        rebirthThread = task.spawn(function()
            while rebirthLooping do
                local Event = game:GetService("ReplicatedStorage").RebirthEvent
                Event:FireServer("Single")
                task.wait(0.1)
            end
        end)
    else
        rebirthLooping = false
        if rebirthThread then
            task.cancel(rebirthThread)
            rebirthThread = nil
        end
    end
end)

MainTab:Toggle("cash muti", false, function(state)
    multiplierLooping = state
    if multiplierLooping then
        multiplierThread = task.spawn(function()
            while multiplierLooping do
                local Event = game:GetService("ReplicatedStorage").BuyMultiplierEvent
                Event:FireServer()
                task.wait(0.1)
            end
        end)
    else
        multiplierLooping = false
        if multiplierThread then
            task.cancel(multiplierThread)
            multiplierThread = nil
        end
    end
end)

