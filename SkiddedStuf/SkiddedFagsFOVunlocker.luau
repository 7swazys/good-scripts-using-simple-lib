--SkiddedFagg Is Here
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local Camera = Workspace.CurrentCamera

local lp = Players.LocalPlayer
local lpGui = lp:WaitForChild("PlayerGui")

local cfg = {
    enabled = false,
    showFov = true,
    fovSize = 150,
    fovOpacity = 0.7,
    fovThickness = 1.5,
    smoothness = 0.35,
    maxDistance = 500,
    fairMode = true,
    fairSpeedCap = 0.20,
    targetPlayers = true,
    targetDummies = false,
    teamCheck = false,
    aimPart = "Head",
    fovColorR = 100,
    fovColorG = 200,
    fovColorB = 255,
    fovRainbow = false,
    fovPulse = false,
    espTracers = true,
    tracerFrom = "Bottom",
    tracerColorR = 255,
    tracerColorG = 80,
    tracerColorB = 80,
    tracerOpacity = 0.75,
    tracerThickness = 1,
    espNames = true,
    espDistance = true,
    espHealthBar = false,
    espBoxes = false,
    behindAlert = true,
    behindMaxDist = 120,
    behindCloseThresh = 25,
    radarEnabled = true,
    radarSize = 100,
    priorityMode = "Distance",
    prediction = true,
    predictionIntensity = 1.0,
    gravityCompensation = false,
    projectileSpeed = 200,
    silentAim = false,
    legitMode = false,
    reactionDelay = 0.08,
    microJitter = 0.0,
    humanizeNoise = 0.012,
}

local currentTarget = nil
local lastTarget = nil
local reactionAccum = 0
local rainbowHue = 0
local pulseT = 0
local flashT = 0

local function findRootPart(char)
    if not char then return nil end
    local v = char:FindFirstChild("HumanoidRootPart")
    if v and v:IsA("BasePart") then return v end
    v = char:FindFirstChild("UpperTorso")
    if v and v:IsA("BasePart") then return v end
    v = char:FindFirstChild("Torso")
    if v and v:IsA("BasePart") then return v end
    v = char:FindFirstChild("Head")
    if v and v:IsA("BasePart") then return v end
    if char.PrimaryPart then return char.PrimaryPart end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function findHumanoid(char)
    if not char then return nil end
    local h = char:FindFirstChildOfClass("Humanoid")
    if h then return h end
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("Humanoid") then return d end
    end
    return nil
end

local function findAimPart(char)
    if not char then return findRootPart(char) end
    local p = char:FindFirstChild(cfg.aimPart)
    if p and p:IsA("BasePart") then return p end
    return findRootPart(char)
end

local function getVelocity(char)
    local root = findRootPart(char)
    if not root then return Vector3.zero end
    local ok, vel = pcall(function() return root.AssemblyLinearVelocity end)
    if ok and vel then return vel end
    ok, vel = pcall(function() return root.Velocity end)
    if ok and vel then return vel end
    return Vector3.zero
end

local function getPing()
    local ping = 0.05
    local ok = pcall(function() ping = lp:GetNetworkPing() end)
    if not ok or ping <= 0 then
        pcall(function()
            ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end)
    end
    return math.clamp(ping, 0.01, 0.6)
end

local function isBehindCamera(worldPos)
    local toTarget = worldPos - Camera.CFrame.Position
    return toTarget:Dot(Camera.CFrame.LookVector) < 0
end

local function getTracerFrom(vpSize, center)
    if cfg.tracerFrom == "Center" then return center
    elseif cfg.tracerFrom == "Top" then return Vector2.new(center.X, 0)
    else return Vector2.new(center.X, vpSize.Y) end
end

local sg = Instance.new("ScreenGui")
sg.Name = "SkiddedFOV_" .. tostring(math.random(1000, 9999))
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true
if not pcall(function() sg.Parent = game:GetService("CoreGui") end) then
    sg.Parent = lpGui
end

local CORNER_RADIUS = UDim.new(0, 8)
local function addCorner(guiObject, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or CORNER_RADIUS
    corner.Parent = guiObject
end

local edgeFlash = Instance.new("Frame")
edgeFlash.Name = "EdgeFlash"
edgeFlash.Size = UDim2.new(1, 0, 1, 0)
edgeFlash.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
edgeFlash.BackgroundTransparency = 1
edgeFlash.BorderSizePixel = 0
edgeFlash.ZIndex = 5
edgeFlash.Parent = sg
Instance.new("UIGradient", edgeFlash).Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(0.12, 0.92),
    NumberSequenceKeypoint.new(0.88, 0.92),
    NumberSequenceKeypoint.new(1, 0.2),
})

local fovHolder = Instance.new("Frame")
fovHolder.Name = "FovHolder"
fovHolder.BackgroundTransparency = 1
fovHolder.BorderSizePixel = 0
fovHolder.ZIndex = 2
fovHolder.Parent = sg
addCorner(fovHolder, UDim.new(1, 0))

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = Color3.fromRGB(cfg.fovColorR, cfg.fovColorG, cfg.fovColorB)
fovStroke.Thickness = cfg.fovThickness
fovStroke.Transparency = 1 - cfg.fovOpacity
fovStroke.Parent = fovHolder

local radarFrame = Instance.new("Frame")
radarFrame.Name = "Radar"
radarFrame.Size = UDim2.new(0, cfg.radarSize, 0, cfg.radarSize)
radarFrame.Position = UDim2.new(1, -(cfg.radarSize + 10), 0, 10)
radarFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
radarFrame.BackgroundTransparency = 0.35
radarFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
radarFrame.BorderSizePixel = 1
radarFrame.ZIndex = 10
radarFrame.Visible = cfg.radarEnabled
radarFrame.Parent = sg
addCorner(radarFrame, UDim.new(1, 0))

local radarCross1 = Instance.new("Frame")
radarCross1.Size = UDim2.new(1, 0, 0, 1)
radarCross1.Position = UDim2.new(0, 0, 0.5, 0)
radarCross1.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radarCross1.BorderSizePixel = 0
radarCross1.ZIndex = 11
radarCross1.Parent = radarFrame

local radarCross2 = Instance.new("Frame")
radarCross2.Size = UDim2.new(0, 1, 1, 0)
radarCross2.Position = UDim2.new(0.5, 0, 0, 0)
radarCross2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
radarCross2.BorderSizePixel = 0
radarCross2.ZIndex = 11
radarCross2.Parent = radarFrame

local radarSelf = Instance.new("Frame")
radarSelf.Size = UDim2.new(0, 5, 0, 5)
radarSelf.AnchorPoint = Vector2.new(0.5, 0.5)
radarSelf.Position = UDim2.new(0.5, 0, 0.5, 0)
radarSelf.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
radarSelf.BorderSizePixel = 0
radarSelf.ZIndex = 13
radarSelf.Parent = radarFrame
addCorner(radarSelf, UDim.new(1, 0))

local radarDotPool = {}
local function getOrCreateRadarDot(idx)
    if not radarDotPool[idx] then
        local d = Instance.new("Frame")
        d.Size = UDim2.new(0, 6, 0, 6)
        d.AnchorPoint = Vector2.new(0.5, 0.5)
        d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        d.BorderSizePixel = 0
        d.ZIndex = 12
        d.Parent = radarFrame
        addCorner(d, UDim.new(1, 0))
        radarDotPool[idx] = d
    end
    return radarDotPool[idx]
end

local tracerPool = {}
local namePool = {}
local distPool = {}
local healthBarPool = {}
local boxPool = {}
local arrowStemPool = {}
local arrowHeadPool = {}
local arrowLabelPool = {}

local function getOrCreateLine(pool, idx)
    if not pool[idx] then
        local l = Drawing.new("Line")
        l.Visible = false l.Thickness = 1
        l.Color = Color3.fromRGB(255, 255, 255) l.Transparency = 0 l.ZIndex = 1
        pool[idx] = l
    end
    return pool[idx]
end

local function getOrCreateText(pool, idx)
    if not pool[idx] then
        local t = Drawing.new("Text")
        t.Visible = false t.Size = 13 t.Font = Drawing.Fonts.UI
        t.Color = Color3.fromRGB(255, 255, 255)
        t.Outline = true t.OutlineColor = Color3.fromRGB(0, 0, 0) t.ZIndex = 2
        pool[idx] = t
    end
    return pool[idx]
end

local function getOrCreateHealthBar(idx)
    if not healthBarPool[idx] then
        local bg = Drawing.new("Line") bg.Visible = false bg.Thickness = 3
        bg.Color = Color3.fromRGB(20, 20, 20) bg.Transparency = 0.2 bg.ZIndex = 1
        local fill = Drawing.new("Line") fill.Visible = false fill.Thickness = 3
        fill.Color = Color3.fromRGB(80, 220, 80) fill.Transparency = 0 fill.ZIndex = 2
        healthBarPool[idx] = {bg = bg, fill = fill}
    end
    return healthBarPool[idx]
end

local function getOrCreateBox(idx)
    if not boxPool[idx] then
        local lines = {}
        for i = 1, 4 do
            local l = Drawing.new("Line") l.Visible = false l.Thickness = 1
            l.Color = Color3.fromRGB(255, 255, 255) l.Transparency = 0.3 l.ZIndex = 1
            lines[i] = l
        end
        boxPool[idx] = lines
    end
    return boxPool[idx]
end

local function getOrCreateArrow(idx)
    if not arrowStemPool[idx] then
        local stem = Drawing.new("Line") stem.Visible = false stem.Thickness = 2 stem.ZIndex = 3
        local head = Drawing.new("Triangle") head.Visible = false head.Filled = true head.ZIndex = 4
        local lbl = Drawing.new("Text") lbl.Visible = false lbl.Size = 11
        lbl.Font = Drawing.Fonts.UI lbl.Outline = true
        lbl.OutlineColor = Color3.fromRGB(0, 0, 0) lbl.ZIndex = 4
        arrowStemPool[idx] = stem
        arrowHeadPool[idx] = head
        arrowLabelPool[idx] = lbl
    end
    return arrowStemPool[idx], arrowHeadPool[idx], arrowLabelPool[idx]
end

local function hideAllDrawings()
    for _, l in pairs(tracerPool) do l.Visible = false end
    for _, t in pairs(namePool) do t.Visible = false end
    for _, t in pairs(distPool) do t.Visible = false end
    for _, hb in pairs(healthBarPool) do hb.bg.Visible = false hb.fill.Visible = false end
    for _, box in pairs(boxPool) do for _, l in pairs(box) do l.Visible = false end end
    for _, s in pairs(arrowStemPool) do s.Visible = false end
    for _, h in pairs(arrowHeadPool) do h.Visible = false end
    for _, l in pairs(arrowLabelPool) do l.Visible = false end
    for _, d in pairs(radarDotPool) do d.Visible = false end
end

local floatBar = Instance.new("Frame")
floatBar.Name = "FloatBar"
floatBar.Size = UDim2.new(0, 158, 0, 36)
floatBar.Position = UDim2.new(0.5, -79, 1, -55)
floatBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
floatBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
floatBar.BorderSizePixel = 2
floatBar.Active = true
floatBar.ZIndex = 20
floatBar.Parent = sg
addCorner(floatBar)

local floatLayout = Instance.new("UIListLayout")
floatLayout.FillDirection = Enum.FillDirection.Horizontal
floatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
floatLayout.VerticalAlignment = Enum.VerticalAlignment.Center
floatLayout.Padding = UDim.new(0, 3)
floatLayout.Parent = floatBar

local function makeFloatBtn(txt, bg, tc, w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w or 72, 0, 26)
    b.BackgroundColor3 = bg b.BorderColor3 = Color3.fromRGB(0, 0, 0)
    b.BorderSizePixel = 1 b.Text = txt b.TextColor3 = tc
    b.TextSize = 11 b.Font = Enum.Font.SourceSansBold
    b.TextStrokeTransparency = 0.8 b.ZIndex = 21 b.Parent = floatBar
    addCorner(b)
    b.Active = false
    return b
end

local toggleBtn = makeFloatBtn("AIM: OFF", Color3.fromRGB(140, 35, 35), Color3.fromRGB(255, 255, 255), 75)
local settingsBtn = makeFloatBtn("SETTINGS", Color3.fromRGB(50, 50, 50), Color3.fromRGB(220, 220, 220), 75)

-- Declare panel variable here (will be assigned later)
local panel

-- Drag & click logic (global input handling)
local dragStartMousePos = nil
local dragStartBarPos = nil
local isDragging = false
local pressTarget = nil
local clickThreshold = 8

local function isInsideGuiObject(guiObject, position)
    local absPos = guiObject.AbsolutePosition
    local absSize = guiObject.AbsoluteSize
    return position.X >= absPos.X and position.X <= absPos.X + absSize.X
        and position.Y >= absPos.Y and position.Y <= absPos.Y + absSize.Y
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local inputPos = Vector2.new(input.Position.X, input.Position.Y)
        if isInsideGuiObject(floatBar, inputPos) then
            isDragging = true
            dragStartMousePos = inputPos
            dragStartBarPos = floatBar.Position
            pressTarget = nil
            if isInsideGuiObject(toggleBtn, inputPos) then
                pressTarget = toggleBtn
            elseif isInsideGuiObject(settingsBtn, inputPos) then
                pressTarget = settingsBtn
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not isDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local currentMousePos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = currentMousePos - dragStartMousePos
        floatBar.Position = UDim2.new(
            dragStartBarPos.X.Scale, dragStartBarPos.X.Offset + delta.X,
            dragStartBarPos.Y.Scale, dragStartBarPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not isDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
        local endPos = Vector2.new(input.Position.X, input.Position.Y)
        local movedDistance = (endPos - dragStartMousePos).Magnitude

        if movedDistance <= clickThreshold and pressTarget then
            if pressTarget == toggleBtn then
                cfg.enabled = not cfg.enabled
                if cfg.enabled then
                    toggleBtn.Text = "AIM: ON"
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 0)
                else
                    toggleBtn.Text = "AIM: OFF"
                    toggleBtn.BackgroundColor3 = Color3.fromRGB(140, 35, 35)
                    currentTarget = nil
                    hideAllDrawings()
                    edgeFlash.BackgroundTransparency = 1
                end
            elseif pressTarget == settingsBtn then
                panel.Visible = not panel.Visible
                settingsBtn.BackgroundColor3 = panel.Visible and Color3.fromRGB(70, 70, 70) or Color3.fromRGB(50, 50, 50)
            end
        end

        dragStartMousePos = nil
        dragStartBarPos = nil
        pressTarget = nil
    end
end)

-- Now create the panel and assign it to the previously declared variable
panel = Instance.new("Frame")
panel.Name = "SettingsPanel"
panel.Size = UDim2.new(0, 240, 0, 500)
panel.Position = UDim2.new(0.5, -120, 0.5, -250)
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
panel.BorderColor3 = Color3.fromRGB(0, 0, 0) panel.BorderSizePixel = 2
panel.Active = true panel.Draggable = true panel.Visible = false
panel.ZIndex = 15 panel.Parent = sg
addCorner(panel)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 22)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BorderColor3 = Color3.fromRGB(0, 0, 0) titleBar.BorderSizePixel = 1
titleBar.ZIndex = 16 titleBar.Parent = panel
addCorner(titleBar)

local titleTxt = Instance.new("TextLabel")
titleTxt.Size = UDim2.new(1, -6, 1, 0) titleTxt.Position = UDim2.new(0, 6, 0, 0)
titleTxt.BackgroundTransparency = 1 titleTxt.Text = "SkiddedFagg FOV Locker"
titleTxt.TextColor3 = Color3.fromRGB(255, 255, 255) titleTxt.TextSize = 13
titleTxt.Font = Enum.Font.SourceSansBold titleTxt.TextXAlignment = Enum.TextXAlignment.Left
titleTxt.TextStrokeTransparency = 0.7 titleTxt.ZIndex = 17 titleTxt.Parent = titleBar

local sf = Instance.new("ScrollingFrame")
sf.Size = UDim2.new(1, 0, 1, -22) sf.Position = UDim2.new(0, 0, 0, 22)
sf.BackgroundTransparency = 1 sf.BorderSizePixel = 0
sf.ScrollBarThickness = 5 sf.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
sf.CanvasSize = UDim2.new(0, 0, 0, 0) sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.ZIndex = 16 sf.Parent = panel

Instance.new("UIListLayout", sf).SortOrder = Enum.SortOrder.LayoutOrder
local pad = Instance.new("UIPadding", sf)
pad.PaddingLeft = UDim.new(0, 5) pad.PaddingRight = UDim.new(0, 5)
pad.PaddingTop = UDim.new(0, 5) pad.PaddingBottom = UDim.new(0, 5)
sf:FindFirstChildOfClass("UIListLayout").Padding = UDim.new(0, 3)

local lo = 0
local function nextOrder() lo = lo + 1 return lo end

local function makeSectionHeader(txt)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 18) f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    f.BorderColor3 = Color3.fromRGB(0, 0, 0) f.BorderSizePixel = 1
    f.LayoutOrder = nextOrder() f.ZIndex = 17 f.Parent = sf
    addCorner(f)
    local accent = Instance.new("Frame") accent.Size = UDim2.new(0, 3, 1, 0)
    accent.BackgroundColor3 = Color3.fromRGB(200, 50, 50) accent.BorderSizePixel = 0 accent.ZIndex = 18 accent.Parent = f
    addCorner(accent)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, -8, 1, 0)
    lbl.Position = UDim2.new(0, 7, 0, 0) lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(txt) lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSansBold lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 18 lbl.Parent = f
end

local function makeToggleRow(labelTxt, defaultState, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 26) row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    row.BorderColor3 = Color3.fromRGB(20, 20, 20) row.BorderSizePixel = 1
    row.LayoutOrder = nextOrder() row.ZIndex = 17 row.Parent = sf
    addCorner(row)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, -55, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0) lbl.BackgroundTransparency = 1
    lbl.Text = labelTxt lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.TextSize = 13 lbl.Font = Enum.Font.SourceSans lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 18 lbl.Parent = row
    local state = defaultState
    local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 42, 0, 18)
    btn.Position = UDim2.new(1, -46, 0.5, -9)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
    btn.BorderColor3 = Color3.fromRGB(0, 0, 0) btn.BorderSizePixel = 1
    btn.Text = state and "ON" or "OFF" btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11 btn.Font = Enum.Font.SourceSansBold btn.ZIndex = 18 btn.Parent = row
    addCorner(btn)
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 140, 0) or Color3.fromRGB(140, 0, 0)
        btn.Text = state and "ON" or "OFF"
        onChange(state)
    end)
end

local function makeSliderRow(labelTxt, minVal, maxVal, defaultVal, isFloat, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38) row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    row.BorderColor3 = Color3.fromRGB(20, 20, 20) row.BorderSizePixel = 1
    row.LayoutOrder = nextOrder() row.ZIndex = 17 row.Parent = sf
    addCorner(row)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, -8, 0, 14)
    lbl.Position = UDim2.new(0, 6, 0, 2) lbl.BackgroundTransparency = 1
    lbl.Text = labelTxt .. ": " .. (isFloat and string.format("%.2f", defaultVal) or tostring(defaultVal))
    lbl.TextColor3 = Color3.fromRGB(230, 230, 230) lbl.TextSize = 12 lbl.Font = Enum.Font.SourceSans
    lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 18 lbl.Parent = row
    local trackBg = Instance.new("Frame") trackBg.Size = UDim2.new(1, -12, 0, 8)
    trackBg.Position = UDim2.new(0, 6, 0, 22) trackBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    trackBg.BorderColor3 = Color3.fromRGB(0, 0, 0) trackBg.BorderSizePixel = 1 trackBg.ZIndex = 18 trackBg.Parent = row
    addCorner(trackBg)
    local fillBar = Instance.new("Frame")
    fillBar.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fillBar.BackgroundColor3 = Color3.fromRGB(180, 50, 50) fillBar.BorderSizePixel = 0 fillBar.ZIndex = 19 fillBar.Parent = trackBg
    addCorner(fillBar)
    local knob = Instance.new("Frame") knob.Size = UDim2.new(0, 8, 0, 14) knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(180, 180, 180) knob.BorderColor3 = Color3.fromRGB(0, 0, 0)
    knob.BorderSizePixel = 1 knob.ZIndex = 20 knob.Parent = trackBg
    addCorner(knob)
    local dragging = false
    local function applyPos(inputPos)
        local abs = trackBg.AbsolutePosition local sz = trackBg.AbsoluteSize
        local rel = math.clamp((inputPos.X - abs.X) / sz.X, 0, 1)
        local raw = minVal + rel * (maxVal - minVal)
        local v = isFloat and (math.floor(raw * 100 + 0.5) / 100) or math.floor(raw + 0.5)
        fillBar.Size = UDim2.new(rel, 0, 1, 0) knob.Position = UDim2.new(rel, 0, 0.5, 0)
        lbl.Text = labelTxt .. ": " .. (isFloat and string.format("%.2f", v) or tostring(v))
        onChange(v)
    end
    trackBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true applyPos(i.Position)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            applyPos(i.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function makeDropdownRow(labelTxt, options, defaultIdx, onChange)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 26) row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    row.BorderColor3 = Color3.fromRGB(20, 20, 20) row.BorderSizePixel = 1
    row.LayoutOrder = nextOrder() row.ZIndex = 17 row.Parent = sf
    addCorner(row)
    local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0.45, 0, 1, 0)
    lbl.Position = UDim2.new(0, 6, 0, 0) lbl.BackgroundTransparency = 1
    lbl.Text = labelTxt lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
    lbl.TextSize = 13 lbl.Font = Enum.Font.SourceSans lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 18 lbl.Parent = row
    local idx = defaultIdx
    local leftBtn = Instance.new("TextButton") leftBtn.Size = UDim2.new(0, 16, 0, 18)
    leftBtn.Position = UDim2.new(0.5, 2, 0.5, -9) leftBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    leftBtn.BorderColor3 = Color3.fromRGB(0, 0, 0) leftBtn.BorderSizePixel = 1
    leftBtn.Text = "<" leftBtn.TextColor3 = Color3.fromRGB(255, 255, 255) leftBtn.TextSize = 11
    leftBtn.Font = Enum.Font.SourceSansBold leftBtn.ZIndex = 18 leftBtn.Parent = row
    addCorner(leftBtn)
    local valLbl = Instance.new("TextLabel") valLbl.Size = UDim2.new(0, 70, 0, 18)
    valLbl.Position = UDim2.new(0.5, 20, 0.5, -9) valLbl.BackgroundTransparency = 1
    valLbl.Text = options[idx] valLbl.TextColor3 = Color3.fromRGB(255, 255, 255) valLbl.TextSize = 11
    valLbl.Font = Enum.Font.SourceSansBold valLbl.TextXAlignment = Enum.TextXAlignment.Center valLbl.ZIndex = 18 valLbl.Parent = row
    local rightBtn = Instance.new("TextButton") rightBtn.Size = UDim2.new(0, 16, 0, 18)
    rightBtn.Position = UDim2.new(0.5, 92, 0.5, -9) rightBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    rightBtn.BorderColor3 = Color3.fromRGB(0, 0, 0) rightBtn.BorderSizePixel = 1
    rightBtn.Text = ">" rightBtn.TextColor3 = Color3.fromRGB(255, 255, 255) rightBtn.TextSize = 11
    rightBtn.Font = Enum.Font.SourceSansBold rightBtn.ZIndex = 18 rightBtn.Parent = row
    addCorner(rightBtn)
    leftBtn.MouseButton1Click:Connect(function() idx = idx > 1 and idx - 1 or #options valLbl.Text = options[idx] onChange(options[idx], idx) end)
    rightBtn.MouseButton1Click:Connect(function() idx = idx < #options and idx + 1 or 1 valLbl.Text = options[idx] onChange(options[idx], idx) end)
end

makeSectionHeader("AIMBOT")
makeToggleRow("Target Players", cfg.targetPlayers, function(v) cfg.targetPlayers = v end)
makeToggleRow("Target Dummies", cfg.targetDummies, function(v)
    cfg.targetDummies = v
    if v then
        updateDummyCache() -- Refresh immediately when enabled
    else
        dummyHumanoidsCache = {}
    end
end)
makeToggleRow("Team Check", cfg.teamCheck, function(v) cfg.teamCheck = v end)
makeDropdownRow("Aim Part", {"Head", "HumanoidRootPart", "Torso", "UpperTorso"}, 1, function(v) cfg.aimPart = v end)
makeDropdownRow("Priority", {"Distance", "FOV Center", "Health", "Random"}, 1, function(v) cfg.priorityMode = v end)
makeToggleRow("Silent Aim", cfg.silentAim, function(v) cfg.silentAim = v end)
makeSliderRow("Smoothness", 0.05, 1.0, cfg.smoothness, true, function(v) cfg.smoothness = v end)
makeSliderRow("Max Distance", 50, 2000, cfg.maxDistance, false, function(v) cfg.maxDistance = v end)

makeSectionHeader("PREDICTION")
makeToggleRow("Prediction", cfg.prediction, function(v) cfg.prediction = v end)
makeSliderRow("Pred Intensity", 0.1, 3.0, cfg.predictionIntensity, true, function(v) cfg.predictionIntensity = v end)
makeToggleRow("Gravity Comp", cfg.gravityCompensation, function(v) cfg.gravityCompensation = v end)
makeSliderRow("Proj Speed", 50, 800, cfg.projectileSpeed, false, function(v) cfg.projectileSpeed = v end)

makeSectionHeader("LEGITIMACY")
makeToggleRow("Legit Mode", cfg.legitMode, function(v) cfg.legitMode = v end)
makeSliderRow("Reaction Delay", 0.0, 0.4, cfg.reactionDelay, true, function(v) cfg.reactionDelay = v end)
makeSliderRow("Micro Jitter", 0.0, 4.0, cfg.microJitter, true, function(v) cfg.microJitter = v end)
makeSliderRow("Human Noise", 0.0, 0.05, cfg.humanizeNoise, true, function(v) cfg.humanizeNoise = v end)

makeSectionHeader("RADAR")
makeToggleRow("Show Radar", cfg.radarEnabled, function(v) cfg.radarEnabled = v radarFrame.Visible = v end)
makeSliderRow("Radar Size", 60, 180, cfg.radarSize, false, function(v)
    cfg.radarSize = v
    radarFrame.Size = UDim2.new(0, v, 0, v)
    radarFrame.Position = UDim2.new(1, -(v + 10), 0, 10)
end)

makeSectionHeader("BEHIND ALERT")
makeToggleRow("Behind Alert", cfg.behindAlert, function(v) cfg.behindAlert = v end)
makeSliderRow("Alert Dist", 20, 400, cfg.behindMaxDist, false, function(v) cfg.behindMaxDist = v end)
makeSliderRow("Close Thresh", 5, 80, cfg.behindCloseThresh, false, function(v) cfg.behindCloseThresh = v end)

makeSectionHeader("FOV CIRCLE")
makeToggleRow("Show FOV", cfg.showFov, function(v) cfg.showFov = v fovHolder.Visible = v end)
makeToggleRow("Rainbow FOV", cfg.fovRainbow, function(v) cfg.fovRainbow = v end)
makeToggleRow("Pulse FOV", cfg.fovPulse, function(v) cfg.fovPulse = v end)
makeSliderRow("FOV Size", 20, 600, cfg.fovSize, false, function(v) cfg.fovSize = v end)
makeSliderRow("Opacity", 0.05, 1.0, cfg.fovOpacity, true, function(v) cfg.fovOpacity = v fovStroke.Transparency = 1 - v end)
makeSliderRow("Thickness", 0.5, 5.0, cfg.fovThickness, true, function(v) cfg.fovThickness = v fovStroke.Thickness = v end)

makeSectionHeader("FOV COLOR")
makeSliderRow("Red", 0, 255, cfg.fovColorR, false, function(v) cfg.fovColorR = v fovStroke.Color = Color3.fromRGB(cfg.fovColorR, cfg.fovColorG, cfg.fovColorB) end)
makeSliderRow("Green", 0, 255, cfg.fovColorG, false, function(v) cfg.fovColorG = v fovStroke.Color = Color3.fromRGB(cfg.fovColorR, cfg.fovColorG, cfg.fovColorB) end)
makeSliderRow("Blue", 0, 255, cfg.fovColorB, false, function(v) cfg.fovColorB = v fovStroke.Color = Color3.fromRGB(cfg.fovColorR, cfg.fovColorG, cfg.fovColorB) end)

makeSectionHeader("ESP")
makeToggleRow("Show Tracers", cfg.espTracers, function(v) cfg.espTracers = v if not v then hideAllDrawings() end end)
makeDropdownRow("Tracer From", {"Bottom", "Center", "Top"}, 1, function(v) cfg.tracerFrom = v end)
makeToggleRow("Show Names", cfg.espNames, function(v) cfg.espNames = v end)
makeToggleRow("Show Distance", cfg.espDistance, function(v) cfg.espDistance = v end)
makeToggleRow("Health Bars", cfg.espHealthBar, function(v) cfg.espHealthBar = v end)
makeToggleRow("Box ESP", cfg.espBoxes, function(v) cfg.espBoxes = v end)
makeSliderRow("Tracer Opacity", 0.1, 1.0, cfg.tracerOpacity, true, function(v) cfg.tracerOpacity = v end)
makeSliderRow("Tracer Thickness", 1, 4, cfg.tracerThickness, false, function(v) cfg.tracerThickness = v end)
makeSliderRow("Tracer Red", 0, 255, cfg.tracerColorR, false, function(v) cfg.tracerColorR = v end)
makeSliderRow("Tracer Green", 0, 255, cfg.tracerColorG, false, function(v) cfg.tracerColorG = v end)
makeSliderRow("Tracer Blue", 0, 255, cfg.tracerColorB, false, function(v) cfg.tracerColorB = v end)

makeSectionHeader("FAIRNESS")
makeToggleRow("Fairness Mode", cfg.fairMode, function(v)
    cfg.fairMode = v
    if not v then warn("[FOV] Fairness off - higher ban risk") end
end)
makeSliderRow("Fair Speed Cap", 0.05, 0.60, cfg.fairSpeedCap, true, function(v) cfg.fairSpeedCap = v end)

local wmLabel = Instance.new("TextLabel")
wmLabel.Size = UDim2.new(1, 0, 0, 14) wmLabel.BackgroundTransparency = 1
wmLabel.Text = "SkiddedFagg Is Here" wmLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
wmLabel.TextSize = 11 wmLabel.Font = Enum.Font.SourceSansItalic
wmLabel.TextXAlignment = Enum.TextXAlignment.Right wmLabel.ZIndex = 17
wmLabel.LayoutOrder = nextOrder() wmLabel.Parent = sf

-- Dummy target caching
local dummyHumanoidsCache = {}
local DUMMY_UPDATE_INTERVAL = 1.0

local function updateDummyCache()
    dummyHumanoidsCache = {}
    if not cfg.targetDummies then return end
    local seen = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local char = obj.Parent
            if char and char ~= lp.Character then
                -- Exclude player characters if targetPlayers is true (they are already handled)
                local isPlayerChar = false
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr.Character == char then
                        isPlayerChar = true
                        break
                    end
                end
                if not isPlayerChar or not cfg.targetPlayers then
                    dummyHumanoidsCache[#dummyHumanoidsCache + 1] = obj
                end
            end
        end
    end
end

-- Start dummy cache update loop
task.spawn(function()
    while true do
        updateDummyCache()
        task.wait(DUMMY_UPDATE_INTERVAL)
    end
end)

local function isAimKeyDown()
    return cfg.enabled
end

local function getAllTargets()
    local vpSize = Camera.ViewportSize
    local center = Vector2.new(vpSize.X / 2, vpSize.Y / 2)
    local camCF = Camera.CFrame
    local results = {}

    local function evalChar(char, owner, displayName)
        if not char then return end
        local hum = findHumanoid(char)
        if not hum or hum.Health <= 0 then return end
        -- Fixed team check: only skip if both have teams and they are the same
        if cfg.teamCheck and owner and owner.Team and lp.Team and owner.Team == lp.Team then
            return
        end
        local root = findRootPart(char)
        if not root then return end
        local worldDist = (root.Position - camCF.Position).Magnitude
        if worldDist > cfg.maxDistance then return end
        local behind = isBehindCamera(root.Position)
        local aimTarget = findAimPart(char)
        local screenPos, onScreen = Camera:WorldToViewportPoint(aimTarget.Position)
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        local rootScreen, rootOnScreen = Camera:WorldToViewportPoint(root.Position)

        local toTarget = root.Position - camCF.Position
        local camRight = camCF.RightVector
        local camForward = camCF.LookVector
        local localX = toTarget:Dot(camRight)
        local localZ = toTarget:Dot(camForward)

        results[#results + 1] = {
            part = aimTarget,
            root = root,
            char = char,
            hum = hum,
            worldDist = worldDist,
            screenDist = screenDist,
            screenPos = Vector2.new(screenPos.X, screenPos.Y),
            rootScreenPos = rootOnScreen and Vector2.new(rootScreen.X, rootScreen.Y) or nil,
            onScreen = onScreen,
            name = displayName,
            health = hum.Health,
            maxHealth = math.max(hum.MaxHealth, 1),
            inFov = onScreen and screenDist <= cfg.fovSize / 2,
            behind = behind,
            localX = localX,
            localZ = localZ,
        }
    end

    if cfg.targetPlayers then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                evalChar(plr.Character, plr, plr.Name)
            end
        end
    end

    if cfg.targetDummies then
        for _, hum in ipairs(dummyHumanoidsCache) do
            local char = hum.Parent
            if char and hum.Health > 0 and char ~= lp.Character then
                evalChar(char, nil, char.Name)
            end
        end
    end

    return results, center
end

local function pickBestTarget(targets)
    local best, bestScore = nil, math.huge
    for _, t in ipairs(targets) do
        if not t.inFov then continue end
        local score
        if cfg.priorityMode == "Distance" then score = t.worldDist
        elseif cfg.priorityMode == "FOV Center" then score = t.screenDist
        elseif cfg.priorityMode == "Health" then score = t.health
        elseif cfg.priorityMode == "Random" then score = math.random()
        else score = t.worldDist end
        if score < bestScore then bestScore = score best = t end
    end
    return best
end

local function getPredictedPos(t)
    local part = t.part
    if not part or not part.Parent then return nil end
    local basePos = part.Position
    if not cfg.prediction then return basePos end
    local vel = getVelocity(t.char)
    local ping = getPing()
    local travelTime = t.worldDist / math.max(cfg.projectileSpeed, 1)
    local totalLead = (ping + travelTime) * cfg.predictionIntensity
    local predicted = basePos + vel * totalLead
    if cfg.gravityCompensation then
        predicted = predicted + Vector3.new(0, 0.5 * Workspace.Gravity * travelTime * travelTime, 0)
    end
    return predicted
end

local function humanizeOffset()
    local jx = (math.random() - 0.5) * 2 * cfg.microJitter
    local jy = (math.random() - 0.5) * 2 * cfg.microJitter
    local nx = (math.random() - 0.5) * 2 * cfg.humanizeNoise * 100
    local ny = (math.random() - 0.5) * 2 * cfg.humanizeNoise * 100
    return Vector2.new(jx + nx, jy + ny)
end

local function drawBehindArrow(idx, center, t, ft)
    local stem, head, lbl = getOrCreateArrow(idx)
    local dist = t.worldDist
    local color
    if dist <= cfg.behindCloseThresh then
        color = math.floor(ft * 6) % 2 == 0 and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(255, 170, 170)
    elseif dist <= cfg.behindCloseThresh * 2.5 then
        color = Color3.fromRGB(255, 140, 20)
    else
        color = Color3.fromRGB(240, 220, 30)
    end

    local sp3, _ = Camera:WorldToViewportPoint(t.root.Position)
    local sp = Vector2.new(sp3.X, sp3.Y)
    local dir = t.behind and (center - sp) or (sp - center)
    if dir.Magnitude < 0.001 then dir = Vector2.new(0, -1) end
    dir = dir.Unit

    local edgeR = math.min(center.X, center.Y) - 26
    local arrowBase = center + dir * edgeR
    local arrowLen = 13
    local headSize = 7
    local perp = Vector2.new(-dir.Y, dir.X)

    stem.From = arrowBase - dir * arrowLen
    stem.To = arrowBase - dir * headSize
    stem.Color = color stem.Thickness = 2 stem.Visible = true

    head.PointA = arrowBase
    head.PointB = arrowBase - dir * headSize + perp * headSize * 0.5
    head.PointC = arrowBase - dir * headSize - perp * headSize * 0.5
    head.Color = color head.Filled = true head.Visible = true

    lbl.Position = arrowBase + dir * 10 + Vector2.new(-20, -6)
    lbl.Text = t.name .. " " .. math.floor(dist) .. "m"
    lbl.Color = color lbl.Size = 11 lbl.Visible = true
end

RunService.RenderStepped:Connect(function(dt)
    rainbowHue = (rainbowHue + dt * 0.4) % 1
    pulseT = pulseT + dt * 3
    flashT = flashT + dt

    local vpSize = Camera.ViewportSize
    local center = Vector2.new(vpSize.X / 2, vpSize.Y / 2)

    if cfg.showFov then
        local fovSz = cfg.fovSize * (cfg.fovPulse and (1 + 0.04 * math.sin(pulseT)) or 1)
        fovHolder.Size = UDim2.new(0, fovSz * 2, 0, fovSz * 2)
        fovHolder.Position = UDim2.new(0, center.X - fovSz, 0, center.Y - fovSz)
        fovHolder.Visible = true
        if cfg.fovRainbow then fovStroke.Color = Color3.fromHSV(rainbowHue, 1, 1) end
    else
        fovHolder.Visible = false
    end

    if not cfg.enabled then
        hideAllDrawings()
        edgeFlash.BackgroundTransparency = 1
        return
    end

    local targets, _ = getAllTargets()
    local tracerFrom = getTracerFrom(vpSize, center)
    local espIdx, behindIdx = 0, 0
    local anyClose = false
    local radarRange = cfg.maxDistance

    for i, t in ipairs(targets) do
        local hidden = t.behind or not t.onScreen

        if cfg.radarEnabled then
            local dotIdx = i
            local dot = getOrCreateRadarDot(dotIdx)
            local halfR = cfg.radarSize / 2
            local scale = halfR / radarRange
            local rx = math.clamp(t.localX * scale + halfR, 4, cfg.radarSize - 4)
            local rz = math.clamp(-t.localZ * scale + halfR, 4, cfg.radarSize - 4)

            if t.behind then
                dot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
            elseif math.abs(t.localX / math.max(math.abs(t.localZ), 0.01)) > 0.7 then
                dot.BackgroundColor3 = Color3.fromRGB(255, 180, 30)
            else
                dot.BackgroundColor3 = Color3.fromRGB(80, 255, 80)
            end

            dot.Position = UDim2.new(0, rx - 3, 0, rz - 3)
            dot.Visible = true
        end

        if hidden and cfg.behindAlert and t.worldDist <= cfg.behindMaxDist then
            behindIdx = behindIdx + 1
            drawBehindArrow(behindIdx, center, t, flashT)
            if t.worldDist <= cfg.behindCloseThresh then anyClose = true end
            if not t.onScreen then continue end
        end

        if not t.onScreen then continue end
        espIdx = espIdx + 1

        if cfg.espTracers and t.rootScreenPos then
            local line = getOrCreateLine(tracerPool, espIdx)
            line.From = tracerFrom line.To = t.rootScreenPos
            line.Color = Color3.fromRGB(cfg.tracerColorR, cfg.tracerColorG, cfg.tracerColorB)
            line.Thickness = cfg.tracerThickness line.Transparency = 1 - cfg.tracerOpacity
            line.Visible = true
        end

        if cfg.espNames and t.rootScreenPos then
            local nt = getOrCreateText(namePool, espIdx)
            nt.Position = t.rootScreenPos + Vector2.new(0, -18) nt.Text = t.name nt.Visible = true
        end

        if cfg.espDistance and t.rootScreenPos then
            local dt2 = getOrCreateText(distPool, espIdx)
            dt2.Position = t.rootScreenPos + Vector2.new(0, -4)
            dt2.Text = math.floor(t.worldDist) .. "m" dt2.Visible = true
        end

        if cfg.espHealthBar and t.rootScreenPos then
            local hb = getOrCreateHealthBar(espIdx)
            local ratio = t.health / t.maxHealth
            local barH = 28 local barX = t.rootScreenPos.X - 20
            local botY = t.rootScreenPos.Y + barH / 2 local topY = t.rootScreenPos.Y - barH / 2
            hb.bg.From = Vector2.new(barX, topY) hb.bg.To = Vector2.new(barX, botY) hb.bg.Visible = true
            hb.fill.From = Vector2.new(barX, botY)
            hb.fill.To = Vector2.new(barX, botY - barH * ratio)
            hb.fill.Color = Color3.fromRGB(math.floor((1-ratio)*255), math.floor(ratio*200), 50)
            hb.fill.Visible = true
        end

        if cfg.espBoxes and t.char then
            local headPart = t.char:FindFirstChild("Head") or findRootPart(t.char)
            local rootPart = t.root
            if headPart and rootPart and t.rootScreenPos then
                local topSP, topOn = Camera:WorldToViewportPoint(headPart.Position + Vector3.new(0, 1.2, 0))
                local botSP, botOn = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 2.8, 0))
                if topOn and botOn then
                    local bh = math.abs(topSP.Y - botSP.Y)
                    local bw = bh * 0.55
                    local cx2 = t.rootScreenPos.X
                    local lx = cx2 - bw/2 local rx2 = cx2 + bw/2
                    local ty = topSP.Y local by = botSP.Y
                    local box = getOrCreateBox(espIdx)
                    box[1].From = Vector2.new(lx,ty) box[1].To = Vector2.new(rx2,ty) box[1].Visible = true
                    box[2].From = Vector2.new(rx2,ty) box[2].To = Vector2.new(rx2,by) box[2].Visible = true
                    box[3].From = Vector2.new(rx2,by) box[3].To = Vector2.new(lx,by) box[3].Visible = true
                    box[4].From = Vector2.new(lx,by) box[4].To = Vector2.new(lx,ty) box[4].Visible = true
                    for _, bl in pairs(box) do
                        bl.Color = Color3.fromRGB(cfg.tracerColorR, cfg.tracerColorG, cfg.tracerColorB)
                        bl.Transparency = 0.3 bl.Thickness = 1
                    end
                end
            end
        end
    end

    -- Hide unused drawings
    for i = espIdx + 1, math.max(#tracerPool, 30) do
        if tracerPool[i] then tracerPool[i].Visible = false end
        if namePool[i] then namePool[i].Visible = false end
        if distPool[i] then distPool[i].Visible = false end
        if healthBarPool[i] then healthBarPool[i].bg.Visible = false healthBarPool[i].fill.Visible = false end
        if boxPool[i] then for _, l in pairs(boxPool[i]) do l.Visible = false end end
    end
    for i = behindIdx + 1, math.max(#arrowStemPool, 10) do
        if arrowStemPool[i] then arrowStemPool[i].Visible = false end
        if arrowHeadPool[i] then arrowHeadPool[i].Visible = false end
        if arrowLabelPool[i] then arrowLabelPool[i].Visible = false end
    end
    for i = #targets + 1, #radarDotPool do
        if radarDotPool[i] then radarDotPool[i].Visible = false end
    end

    if anyClose then
        edgeFlash.BackgroundTransparency = 0.5 + (math.sin(flashT * 8) + 1) / 2 * 0.35
    else
        edgeFlash.BackgroundTransparency = 1
    end

    if not isAimKeyDown() then
        currentTarget = nil reactionAccum = 0 return
    end

    local best = pickBestTarget(targets)
    if not best then currentTarget = nil reactionAccum = 0 return end
    if lastTarget ~= best.part then lastTarget = best.part reactionAccum = 0 end
    if cfg.legitMode and reactionAccum < cfg.reactionDelay then reactionAccum = reactionAccum + dt return end

    currentTarget = best
    local predictedPos = getPredictedPos(best)
    if not predictedPos then return end

    local hOff = humanizeOffset()
    local _, onScreen = Camera:WorldToViewportPoint(predictedPos)
    if not onScreen then return end

    local camCF = Camera.CFrame
    local lookTarget = predictedPos + Vector3.new(hOff.X * 0.01, hOff.Y * 0.01, 0)
    local targetCF = CFrame.new(camCF.Position, lookTarget)
    local smooth = cfg.fairMode and math.min(cfg.smoothness, cfg.fairSpeedCap) or cfg.smoothness
    smooth = math.clamp(smooth, 0.01, 1.0)
    Camera.CFrame = camCF:Lerp(targetCF, smooth)
end)
