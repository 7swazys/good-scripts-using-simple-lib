local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("tp")
local main = win:AddSection("main")

local doing = false
local waitTime = 0.5

local function go()
    local plr = game:GetService("Players").LocalPlayer
    if plr.Character then
        pcall(function()
            plr.Character:PivotTo(CFrame.new(37561, 6, 57))
        end)
    end
end

main:Toggle("toggle", false, function(v)
    doing = v
    if doing then
        spawn(function()
            while doing do
                go()
                task.wait(waitTime)
            end
        end)
    end
end)

main:Slider("slider", 0.05, 2, 0.5, function(v)
    waitTime = v
end)
