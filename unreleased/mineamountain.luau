local Event = game:GetService("ReplicatedStorage").Remotes.DigRequest
local SellEvent = game:GetService("ReplicatedStorage").Remotes.SellRequest
local RagdollDeactivate = game:GetService("ReplicatedStorage").RagdollSystemPackage.RagdollSystem.Remotes.DeactivateRagdollRemote
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local SimpleLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"))()
local Window = SimpleLib:Window("mining farm")
local mainTab = Window:AddSection("main")
local tpsTab = Window:AddSection("tps")

local isMouseMine = false
local isOrbitMine = false
local isAntiRagdoll = false
local angle = 0
local radius = 10
local points = 8

local pickaxes = {
    "Astral Rend", "Celestial Apex", "Chipped Stone", "Copper Pick",
    "Diamond Pickaxe", "Eclipse Fang", "Emerald Carver", "Frostbite Pick",
    "Hardened Iron", "Nebular Throne", "Obsidian Edge", "Reinforced Steel",
    "Rusty Scrapper", "Shark Pickaxe", "Singularity", "Tempest Pick",
    "The Terminus", "Titanium Spike", "Voidreign", "Volcano Basalt",
    "Weathered Wood"
}

local function getEquippedPickaxe()
    local backpack = player:FindFirstChild("Backpack")
    if not backpack then return "Titanium Spike" end
    
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, name in ipairs(pickaxes) do
                if tool.Name == name then
                    return name
                end
            end
        end
    end
    
    local character = player.Character
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, name in ipairs(pickaxes) do
                    if tool.Name == name then
                        return name
                    end
                end
            end
        end
    end
    
    return "Titanium Spike"
end

local function getOrbitPositions()
    local positions = {}
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return positions end
    
    local center = hrp.Position
    local step = (2 * math.pi) / points
    
    for i = 0, points - 1 do
        local currentAngle = angle + (i * step)
        local x = center.X + radius * math.cos(currentAngle)
        local z = center.Z + radius * math.sin(currentAngle)
        
        local rayOrigin = Vector3.new(x, center.Y + 10, z)
        local rayDirection = Vector3.new(0, -20, 0)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {player.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
        
        if result then
            table.insert(positions, result.Position)
        else
            table.insert(positions, Vector3.new(x, center.Y, z))
        end
    end
    
    return positions
end

local function sell()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local originalPos = hrp.Position
    hrp.CFrame = CFrame.new(-41, 29, 1066)
    task.wait(0.5)
    SellEvent:FireServer("all")
    task.wait(0.5)
    hrp.CFrame = CFrame.new(originalPos)
end

mainTab:Toggle("mousemine", false, function(state)
    isMouseMine = state
end)

mainTab:Toggle("orbit mine", false, function(state)
    isOrbitMine = state
    if not state then angle = 0 end
end)

mainTab:Toggle("antiragdol", false, function(state)
    isAntiRagdoll = state
end)

mainTab:Button("sell", function()
    sell()
end)

tpsTab:Button("tp to mine", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(-7, 28, 927)
    end
end)

tpsTab:Button("tp to pickaxe shop", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(7, 29, 1087)
    end
end)

tpsTab:Button("tp to upgrades shop", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(9, 29, 1067)
    end
end)

tpsTab:Button("tp to bombs shop", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(10, 29, 1050)
    end
end)

spawn(function()
    while true do
        task.wait(0.03)
        
        local equipped = getEquippedPickaxe()
        
        if isMouseMine then
            local targetPos = mouse.Hit.Position
            Event:FireServer(equipped, Vector3.new(targetPos.X, targetPos.Y, targetPos.Z))
        end
        
        if isOrbitMine then
            local positions = getOrbitPositions()
            for _, pos in ipairs(positions) do
                Event:FireServer(equipped, Vector3.new(pos.X, pos.Y, pos.Z))
            end
            angle = angle + 0.15
        end
    end
end)

spawn(function()
    while true do
        task.wait(0.05)
        if isAntiRagdoll then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    if humanoid:GetState() == Enum.HumanoidStateType.Physics then
                        RagdollDeactivate:FireServer()
                    end
                end
            end
        end
    end
end)
