local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")

local underground = false
local tweenOffset = 300
local underConnection = nil
local noclipConnection = nil
local camConnection = nil
local targetY = 0
local originalCamPos = nil

local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if not player.Character then return end
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function startUnderground()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    originalCamPos = camera.CFrame
    targetY = root.Position.Y - tweenOffset
    
    root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
    
    startNoclip()
    
    if camConnection then camConnection:Disconnect() end
    camConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not underground then return end
        if not player.Character then return end
        
        local camPos = camera.CFrame.Position
        local targetCamPos = Vector3.new(camPos.X, originalCamPos.Position.Y, camPos.Z)
        camera.CFrame = CFrame.new(targetCamPos, targetCamPos + camera.CFrame.LookVector)
    end)
    
    if underConnection then underConnection:Disconnect() end
    underConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if not underground then return end
        local currentChar = player.Character
        if not currentChar then return end
        local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
        if not currentRoot then return end
        
        if math.abs(currentRoot.Position.Y - targetY) > 0.5 then
            currentRoot.CFrame = CFrame.new(currentRoot.Position.X, targetY, currentRoot.Position.Z)
        end
    end)
end

local function stopUnderground()
    if underConnection then
        underConnection:Disconnect()
        underConnection = nil
    end
    if camConnection then
        camConnection:Disconnect()
        camConnection = nil
    end
    
    stopNoclip()
    
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local origin = root.Position + Vector3.new(0, 10, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {player.Character}
    local result = workspace:Raycast(origin, Vector3.new(0, -100, 0), params)
    
    local groundPos
    if result then
        groundPos = result.Position + Vector3.new(0, 3, 0)
    else
        groundPos = root.Position + Vector3.new(0, tweenOffset, 0)
    end
    
    root.CFrame = CFrame.new(root.Position.X, groundPos.Y, root.Position.Z)
    
    originalCamPos = nil
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        underground = not underground
        if underground then
            startUnderground()
        else
            stopUnderground()
        end
    end
end)

print("Underground toggled with G key")

local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera

local espEnabled = true
local nameEnabled = true
local distanceEnabled = true
local fontSize = 12
local espObjects = {}
local playersList = {}

local function NewText()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Text = ""
    text.Size = fontSize
    text.Color = Color3.fromRGB(255, 255, 255)
    text.Font = 3
    text.Outline = true
    text.OutlineColor = Color3.fromRGB(0, 0, 0)
    text.Center = true
    return text
end

local function DestroyESP(plr)
    local lib = espObjects[plr]
    if lib then
        if lib.highlight then
            lib.highlight:Destroy()
        end
        if lib.name then
            lib.name:Remove()
        end
        if lib.distance then
            lib.distance:Remove()
        end
        if lib.connection then
            lib.connection:Disconnect()
        end
        espObjects[plr] = nil
    end
end

local function updateESP(plr)
    if not espEnabled then
        local lib = espObjects[plr]
        if lib then
            if lib.highlight then lib.highlight.Enabled = false end
            if lib.name then lib.name.Visible = false end
            if lib.distance then lib.distance.Visible = false end
        end
        return
    end
    
    local lib = espObjects[plr]
    if not lib then return end
    
    local char = plr.Character
    if not char then
        if lib.highlight then lib.highlight.Enabled = false end
        if lib.name then lib.name.Visible = false end
        if lib.distance then lib.distance.Visible = false end
        return
    end

    if not lib.highlight then
        lib.highlight = Instance.new("Highlight")
        lib.highlight.FillTransparency = 1
        lib.highlight.OutlineTransparency = 0
        lib.highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        lib.highlight.Adornee = char
        lib.highlight.Parent = char
        lib.highlight.Enabled = true
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        if lib.name then lib.name.Visible = false end
        if lib.distance then lib.distance.Visible = false end
        return
    end

    local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        if lib.name then lib.name.Visible = false end
        if lib.distance then lib.distance.Visible = false end
        return
    end

    local dist = (root.Position - camera.CFrame.Position).Magnitude
    local centerX = rootPos.X
    local centerY = rootPos.Y - 50

    if not lib.name then
        lib.name = NewText()
        lib.distance = NewText()
    end

    if nameEnabled then
        lib.name.Text = plr.Name
        lib.name.Size = fontSize
        lib.name.Color = Color3.fromRGB(255, 255, 255)
        lib.name.Position = Vector2.new(centerX, centerY)
        lib.name.Visible = true
    else
        lib.name.Visible = false
    end

    if distanceEnabled then
        lib.distance.Text = math.floor(dist) .. "m"
        lib.distance.Size = fontSize - 2
        lib.distance.Color = Color3.fromRGB(255, 255, 255)
        lib.distance.Position = Vector2.new(centerX, centerY + 20)
        lib.distance.Visible = true
    else
        lib.distance.Visible = false
    end
end

local function createESP(plr)
    if espObjects[plr] then return end
    espObjects[plr] = {}
    playersList[plr] = true
    
    local connection = game:GetService("RunService").RenderStepped:Connect(function()
        updateESP(plr)
    end)
    espObjects[plr].connection = connection
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
    if plr ~= player then
        task.wait(1)
        createESP(plr)
    end
end)

game:GetService("Players").PlayerRemoving:Connect(function(plr)
    playersList[plr] = nil
    DestroyESP(plr)
end)

for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
    if plr ~= player then
        createESP(plr)
    end
end

task.spawn(function()
    while true do
        task.wait(5)
        for plr, _ in pairs(playersList) do
            if not plr.Parent then
                playersList[plr] = nil
                DestroyESP(plr)
            end
        end
    end
end)
