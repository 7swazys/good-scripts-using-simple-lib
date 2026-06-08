local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local Window = SimpleLib:Window("cube game")
local MainTab = Window:AddSection("remote")

local cubeLooping = false
local cubeThread = nil

MainTab:Toggle("get cubes", false, function(state)
    cubeLooping = state
    if cubeLooping then
        cubeThread = task.spawn(function()
            while cubeLooping do
                local Event = game:GetService("ReplicatedStorage").Remotes.CollectCube
                Event:FireServer(
                    100000000000000000000000000000000000000,
                    1000000000000000000000000000099999999999999999999,
                    true
                )
                task.wait()
            end
        end)
    else
        cubeLooping = false
        if cubeThread then
            task.cancel(cubeThread)
            cubeThread = nil
        end
    end
end)
