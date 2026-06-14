local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local Event = game:GetService("ReplicatedStorage").Network_Unreliable

local Window = SimpleLib:Window("keypressgame")
local MainTab = Window:AddSection("Main")

local isLooping = false
local loopConnection = nil

local function fireKey()
    Event:FireServer("pressKey", position, "Diamond")
end

MainTab:Toggle("keypress", false, function(state)
    isLooping = state
    if isLooping then
        loopConnection = game:GetService("RunService").Heartbeat:Connect(function()
            fireKey()
        end)
    else
        if loopConnection then
            loopConnection:Disconnect()
            loopConnection = nil
        end
    end
end)

local isCodeThockLooping = false
local codeThockConnection = nil

local function fireCodeThock()
    Event:FireServer("attemptThock")
    Event:FireServer("attemptCode")
end

MainTab:Toggle("code-thock loop idfk", false, function(state)
    isCodeThockLooping = state
    if isCodeThockLooping then
        codeThockConnection = game:GetService("RunService").Heartbeat:Connect(function()
            fireCodeThock()
        end)
    else
        if codeThockConnection then
            codeThockConnection:Disconnect()
            codeThockConnection = nil
        end
    end
end)

local isBronzeLooping = false
local bronzeConnection = nil

local function fireBronze()
    Event:FireServer("attemptTreeUpgrade", "2-1")
end

MainTab:Toggle("auto bronze", false, function(state)
    isBronzeLooping = state
    if isBronzeLooping then
        bronzeConnection = game:GetService("RunService").Heartbeat:Connect(function()
            fireBronze()
        end)
    else
        if bronzeConnection then
            bronzeConnection:Disconnect()
            bronzeConnection = nil
        end
    end
end)

local isKeyValueLooping = false
local keyValueConnection = nil

local function fireKeyValue()
    Event:FireServer("attemptUpgrade", "upgrades", "upgrades")
end

MainTab:Toggle("auto keyvalue", false, function(state)
    isKeyValueLooping = state
    if isKeyValueLooping then
        keyValueConnection = game:GetService("RunService").Heartbeat:Connect(function()
            fireKeyValue()
        end)
    else
        if keyValueConnection then
            keyValueConnection:Disconnect()
            keyValueConnection = nil
        end
    end
end)

local isExpansionLooping = false
local expansionConnection = nil

local function fireExpansion()
    Event:FireServer("attemptUpgrade", "upgrades", "upgrades")
end

MainTab:Toggle("auto expansion", false, function(state)
    isExpansionLooping = state
    if isExpansionLooping then
        expansionConnection = game:GetService("RunService").Heartbeat:Connect(function()
            fireExpansion()
        end)
    else
        if expansionConnection then
            expansionConnection:Disconnect()
            expansionConnection = nil
        end
    end
end)

local isPopupRateLooping = false
local popupRateConnection = nil

local function firePopupRate()
    Event:FireServer("attemptUpgrade", "upgrades", "upgrades")
end

MainTab:Toggle("auto popuprate", false, function(state)
    isPopupRateLooping = state
    if isPopupRateLooping then
        popupRateConnection = game:GetService("RunService").Heartbeat:Connect(function()
            firePopupRate()
        end)
    else
        if popupRateConnection then
            popupRateConnection:Disconnect()
            popupRateConnection = nil
        end
    end
end)
