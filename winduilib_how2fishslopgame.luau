local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local CommandNet = game:GetService("ReplicatedStorage"):WaitForChild("CommandNet")
local PickUpRemote = CommandNet:WaitForChild("Invoke")
local FireRemote = CommandNet:WaitForChild("Fire")

local Window = WindUI:CreateWindow({
    Title = "How to slop",
    Icon = "solar:folder-2-bold-duotone",
    Folder = "howtofish",
    NewElements = true,
    HideSearchBar = false,
    Topbar = { Height = 44, ButtonsType = "Mac" },
})

local MainTab = Window:Tab({ Title = "Main", Icon = "solar:home-2-bold" })
local TPTab = Window:Tab({ Title = "Teleport", Icon = "solar:map-point-bold" })

local autoPickup = false
local autoPunch = false
local espEnabled = false
local autoEat = false

local highlightObjects = {}
local nameTags = {}

local espWhitelist = {
    ["Clam"] = true,
}

local function isWhitelisted(obj)
    return espWhitelist[obj.Name] == true
end

local function getRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function getPickables()
    local list = {}
    for _, obj in ipairs(workspace:GetChildren()) do
        if (obj:IsA("Model") or obj:IsA("BasePart")) 
            and not Players:GetPlayerFromCharacter(obj) 
            and obj ~= LocalPlayer.Character 
        then
            table.insert(list, obj)
        end
    end
    return list
end

local function getNearestPickable()
    local root = getRoot()
    if not root then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, obj in ipairs(getPickables()) do
        local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
        if part then
            local dist = (root.Position - part.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = part
            end
        end
    end
    return nearest
end

local function getNearestClam()
    local root = getRoot()
    if not root then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, obj in ipairs(getPickables()) do
        if isWhitelisted(obj) then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (root.Position - part.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = part
                end
            end
        end
    end
    return nearest
end

local function createESP(obj)
    if highlightObjects[obj] then return end
    if not isWhitelisted(obj) then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(100, 200, 255)
    highlight.FillTransparency = 0.7
    highlight.OutlineColor = Color3.fromRGB(150, 220, 255)
    highlight.OutlineTransparency = 0.3
    highlight.Adornee = obj
    highlight.Parent = obj

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = obj.Name
    label.TextColor3 = Color3.fromRGB(100, 200, 255)
    label.TextStrokeTransparency = 0.3
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    highlightObjects[obj] = highlight
    nameTags[obj] = {billboard = billboard, label = label}
end

local function removeESP(obj)
    if highlightObjects[obj] then
        highlightObjects[obj]:Destroy()
        highlightObjects[obj] = nil
    end
    if nameTags[obj] then
        nameTags[obj].billboard:Destroy()
        nameTags[obj] = nil
    end
end

local function scanESP()
    for _, obj in ipairs(getPickables()) do
        if isWhitelisted(obj) then
            createESP(obj)
        end
    end
end

local function clearESP()
    for obj, _ in pairs(highlightObjects) do
        removeESP(obj)
    end
end

local function pickUpAll()
    for _, obj in ipairs(getPickables()) do
        pcall(function()
            PickUpRemote:InvokeServer("PickUp", {target = obj})
        end)
    end
end

local function punch()
    local side = math.random(1, 2) == 1 and "Right" or "Left"
    local dir = Vector3.new(
        math.random() * 2 - 1,
        -0.3 - math.random() * 0.5,
        math.random() * 2 - 1
    )
    pcall(function()
        FireRemote:FireServer("Punch", {side = side, dir = dir})
    end)
end

local function eat()
    pcall(function()
        FireRemote:FireServer("Eat", nil)
    end)
end

spawn(function()
    while true do
        task.wait(0.15)
        if autoPickup then pickUpAll() end
        if autoPunch then punch() end
        if autoEat then eat() end
    end
end)

workspace.ChildAdded:Connect(function(child)
    if espEnabled and (child:IsA("Model") or child:IsA("BasePart")) then
        if isWhitelisted(child) then
            task.wait(0.1)
            createESP(child)
        end
    end
end)

workspace.ChildRemoved:Connect(function(child)
    if highlightObjects[child] then
        removeESP(child)
    end
end)

MainTab:Toggle({
    Title = "Auto Pickup",
    Desc = "Try to pick up everything in workspace",
    Value = false,
    Callback = function(state)
        autoPickup = state
        WindUI:Notify({Title = "Auto Pickup", Content = state and "ON" or "OFF", Icon = state and "check" or "x", Duration = 2})
    end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "Auto Punch",
    Desc = "Punch randomly",
    Value = false,
    Callback = function(state)
        autoPunch = state
        WindUI:Notify({Title = "Auto Punch", Content = state and "ON" or "OFF", Icon = state and "check" or "x", Duration = 2})
    end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "Auto Eat",
    Value = false,
    Callback = function(state)
        autoEat = state
        WindUI:Notify({Title = "Auto Eat", Content = state and "ON" or "OFF", Icon = state and "check" or "x", Duration = 2})
    end,
})

MainTab:Space()

MainTab:Toggle({
    Title = "Clam ESP",
    Desc = "Only highlight Clams",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if state then scanESP() else clearESP() end
        WindUI:Notify({Title = "Clam ESP", Content = state and "ON" or "OFF", Icon = state and "check" or "x", Duration = 2})
    end,
})

TPTab:Button({
    Title = "TP to Nearest Clam",
    Callback = function()
        local clam = getNearestClam()
        local root = getRoot()
        if clam and root then
            root.CFrame = CFrame.new(clam.Position + Vector3.new(0, 3, 0))
        end
    end,
})

TPTab:Space()

TPTab:Button({
    Title = "TP to Nearest Item",
    Callback = function()
        local item = getNearestPickable()
        local root = getRoot()
        if item and root then
            root.CFrame = CFrame.new(item.Position + Vector3.new(0, 3, 0))
        end
    end,
})

