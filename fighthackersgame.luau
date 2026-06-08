local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local Window = SimpleLib:Window("dumb remote abuse")
local MainTab = Window:AddSection("killaura")

local hitboxLooping = false
local hitboxThread = nil

MainTab:Toggle("hit aura (u need hold bat)", false, function(state)
    hitboxLooping = state
    if hitboxLooping then
        hitboxThread = task.spawn(function()
            while hitboxLooping do
                local Event = game:GetService("ReplicatedStorage").RemoteEvents.Server.HitboxDetection
                Event:FireServer()
                task.wait()
            end
        end)
    else
        hitboxLooping = false
        if hitboxThread then
            task.cancel(hitboxThread)
            hitboxThread = nil
        end
    end
end)
