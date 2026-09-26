local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local AttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attack")

local ORBIT_RADIUS = 5     
local ORBIT_SPEED = 8      
local MAX_TRACK_RANGE = 50 

local isAutofarming = false
local farmConnection = nil
local angle = 0

local function getClosestTarget()
    local character = LocalPlayer.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    local container = workspace:FindFirstChild("PlayersContainer")
    
    if not myRoot or not container then return nil, nil end
    
    local closestHitbox = nil
    local closestFolder = nil
    local shortestDistance = MAX_TRACK_RANGE
    
    for _, targetFolder in ipairs(container:GetChildren()) do
        if targetFolder.Name ~= LocalPlayer.Name then
            local hitbox = targetFolder:FindFirstChild("Hitbox")
            if hitbox and hitbox:IsA("BasePart") then
                local distance = (hitbox.Position - myRoot.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestHitbox = hitbox
                    closestFolder = targetFolder
                end
            end
        end
    end
    
    return closestHitbox, closestFolder
end

local function startOrbitFarm()
    farmConnection = RunService.Heartbeat:Connect(function(deltaTime)
        local myCharacter = LocalPlayer.Character
        local myRoot = myCharacter and myCharacter:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        
        local targetHitbox, targetFolder = getClosestTarget()
        
        if targetHitbox then
            angle = angle + (ORBIT_SPEED * deltaTime)
            
            local offsetX = math.cos(angle) * ORBIT_RADIUS
            local offsetZ = math.sin(angle) * ORBIT_RADIUS
            
            local newPosition = Vector3.new(targetHitbox.Position.X + offsetX, targetHitbox.Position.Y, targetHitbox.Position.Z + offsetZ)
            myRoot.CFrame = CFrame.new(newPosition, targetHitbox.Position) -- Faces the enemy while orbiting
            
            if AttackRemote then
                pcall(function()
                    local direction = (targetHitbox.Position - myRoot.Position).Unit
                    AttackRemote:FireServer(direction, targetHitbox)
                end)
            end
        else
            task.wait(0.1)
        end
    end)
end

local function stopOrbitFarm()
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then
        isAutofarming = not isAutofarming
        if isAutofarming then
            print("Orbit Autofarm: ACTIVE")
            startOrbitFarm()
        else
            print("Orbit Autofarm: INACTIVE")
            stopOrbitFarm()
        end
    end
end)

