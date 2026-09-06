local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()

local win = SimpleLib:Window("+ 1 game keybaord")
local main = win:AddSection("main")

local moving = false
local waitTime = 0.5

local points = {
    CFrame.new(2032, 543, -1602),
    CFrame.new(2033, 545, -1627)
}
local current = 1

local function move()
    local plr = game:GetService("Players").LocalPlayer
    if not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = points[current]
    current = current % #points + 1
end

main:Toggle("toggle", false, function(v)
    moving = v
    if moving then
        spawn(function()
            while moving do
                move()
                task.wait(waitTime)
            end
        end)
    end
end)

main:Slider("slider", 0.05, 2, 0.5, function(v)
    waitTime = v
end)
