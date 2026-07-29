local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()
local Window = SimpleLib:Window("sub to vaehz")
local mainTab = Window:AddSection("main")

local isLooping = false

local function getButton()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("RingUI")
    if not gui then return nil end
    local children = gui:GetChildren()
    if not children[13] then return nil end
    return children[13]:FindFirstChild("TextButton")
end

local function loopBet()
    while isLooping do
        local button = getButton()
        if button then
            local connections = getconnections(button.Activated)
            if connections and connections[1] then
                local closure = connections[1].Function
                if closure then
                    debug.setupvalue(closure, 6, 999999999)
                    debug.setupvalue(closure, 4, 0)
                    button:Activate()
                end
            end
        end
        task.wait(0.1)
    end
end

mainTab:Toggle("inf money", false, function(state)
    isLooping = state
    if state then
        spawn(loopBet)
    end
end)
