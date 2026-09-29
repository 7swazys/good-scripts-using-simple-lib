local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local SimpleLib = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/IcantAffordSynapse/SimpleLib/refs/heads/main/SimpleLib.lua"
))()

local Window     = SimpleLib:Window("Auto Farm")
local FarmTab    = Window:AddSection("Farm")
local VisualsTab = Window:AddSection("Visuals")

local InventoryActionRemote, MouseClickRemote, GatherHitRemote
do
    local cgr = ReplicatedStorage:FindFirstChild("ChunkGameRemotes")
        or ReplicatedStorage:WaitForChild("ChunkGameRemotes", 10)
    if cgr then
        InventoryActionRemote = cgr:FindFirstChild("InventoryAction")
        MouseClickRemote      = cgr:FindFirstChild("MouseClick")
        GatherHitRemote       = cgr:FindFirstChild("GatherHit")
    end
end

local ENEMY_CONTAINER_NAME  = "Enemies"
local ANIMAL_CONTAINER_NAME = "Animals"

local CHUNKS_ROOT_NAME      = "GeneratedChunks"
local RESOURCES_FOLDER_NAME = "Resources"
local TREE_NAME_FILTER      = { OakTree = true, PineTree = true, AppleTree = true }
local BUSH_NAME_FILTER      = { Bush = true, BerryBush = true }

local ENEMY_FROM_ANIMALS = { Spider = true, Scorpion = true }

local EQUIP_SLOT_ENEMY = 1
local EQUIP_SLOT_BUSH  = 3
local EQUIP_SLOT_TREE  = 3

local ORBIT_RADIUS  = 6
local ORBIT_SPEED   = 180
local TWEEN_TIME    = 0.10
local FARM_INTERVAL = 0.04

local COLOR_ENEMY   = Color3.fromRGB(255, 70, 70)
local COLOR_ANIMAL  = Color3.fromRGB(255, 220, 70)
local COLOR_TREE    = Color3.fromRGB(120, 255, 140)
local COLOR_BUSH    = Color3.fromRGB(200, 120, 255)
local COLOR_OUTLINE = Color3.fromRGB(255, 255, 255)
local COLOR_TEXT_ENEMY  = Color3.fromRGB(255, 90, 90)
local COLOR_TEXT_ANIMAL = Color3.fromRGB(255, 230, 100)
local COLOR_TEXT_TREE   = Color3.fromRGB(140, 255, 160)
local COLOR_TEXT_BUSH   = Color3.fromRGB(220, 150, 255)

local function makeNametag(adornee, text, textColor)
    local part
    if adornee:IsA("BasePart") then
        part = adornee
    elseif adornee:IsA("Model") then
        part = adornee:FindFirstChild("Head")
            or adornee:FindFirstChildWhichIsA("BasePart", true)
    else
        part = adornee:FindFirstChildWhichIsA("BasePart", true)
    end
    if not part then return nil end

    local bb = Instance.new("BillboardGui")
    bb.Name = "Nametag"
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Size = UDim2.new(0, 200, 0, 24)
    bb.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
    bb.Parent = part

    local label = Instance.new("TextLabel")
    label.Name = "Tag"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = textColor
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.2
    label.Text = text
    label.Parent = bb
    return bb
end

local function makeContainerBinder(containerName, classifyFn)
    local state = { container = nil, set = {}, addedConn = nil, removedConn = nil }

    local function register(child)
        classifyFn(child, state.set)
    end

    local function bind()
        if state.addedConn then state.addedConn:Disconnect(); state.addedConn = nil end
        if state.removedConn then state.removedConn:Disconnect(); state.removedConn = nil end
        table.clear(state.set)

        state.container = workspace:FindFirstChild(containerName)
        if not state.container then return end

        for _, child in ipairs(state.container:GetChildren()) do
            register(child)
        end
        state.addedConn = state.container.ChildAdded:Connect(register)
        state.removedConn = state.container.ChildRemoved:Connect(function(child)
            state.set[child] = nil
        end)
    end

    workspace.ChildAdded:Connect(function(child)
        if child.Name == containerName then bind() end
    end)
    bind()
    return state
end

local function makeChunkBinder(resourceMatcher)
    local state = {
        set = {},
        chunksRoot = nil,
        chunksRootConn = nil,
        perChunkConns = {},
    }

    local function disconnectChunk(chunk)
        local conns = state.perChunkConns[chunk]
        if not conns then return end
        if conns.added then conns.added:Disconnect() end
        if conns.removed then conns.removed:Disconnect() end
        if conns.wait then conns.wait:Disconnect() end
        state.perChunkConns[chunk] = nil
    end

    local function bindChunk(chunk)
        if state.perChunkConns[chunk] then return end

        local resources = chunk:FindFirstChild(RESOURCES_FOLDER_NAME)
        if not resources then
            local conn
            conn = chunk.ChildAdded:Connect(function(child)
                if child.Name == RESOURCES_FOLDER_NAME then
                    conn:Disconnect()
                    bindChunk(chunk)
                end
            end)
            state.perChunkConns[chunk] = { wait = conn }
            return
        end

        for _, child in ipairs(resources:GetChildren()) do
            resourceMatcher(child, state.set)
        end

        local conns = {}
        conns.added = resources.ChildAdded:Connect(function(child)
            resourceMatcher(child, state.set)
        end)
        conns.removed = resources.ChildRemoved:Connect(function(child)
            state.set[child] = nil
        end)
        state.perChunkConns[chunk] = conns
    end

    local function bindRoot()
        if state.chunksRootConn then state.chunksRootConn:Disconnect(); state.chunksRootConn = nil end
        for chunk in pairs(state.perChunkConns) do
            disconnectChunk(chunk)
        end
        table.clear(state.set)

        state.chunksRoot = workspace:FindFirstChild(CHUNKS_ROOT_NAME)
        if not state.chunksRoot then return end

        for _, chunk in ipairs(state.chunksRoot:GetChildren()) do
            bindChunk(chunk)
        end

        state.chunksRootConn = state.chunksRoot.ChildAdded:Connect(bindChunk)
        state.chunksRoot.ChildRemoved:Connect(disconnectChunk)
    end

    workspace.ChildAdded:Connect(function(child)
        if child.Name == CHUNKS_ROOT_NAME then bindRoot() end
    end)

    bindRoot()
    return state
end

local enemyState = makeContainerBinder(ENEMY_CONTAINER_NAME, function(child, set)
    if child:IsA("Model") or child:IsA("Folder") then
        set[child] = true
    end
end)

local animalState = makeContainerBinder(ANIMAL_CONTAINER_NAME, function(child, set)
    if not (child:IsA("Model") or child:IsA("Folder")) then return end
    if ENEMY_FROM_ANIMALS[child.Name] then
        enemyState.set[child] = true
        return
    end
    set[child] = true
end)

local function resolveHitbox(child)
    local hitbox = child:FindFirstChild("Hitbox")
    if hitbox and hitbox:IsA("BasePart") then
        return hitbox
    end
    return nil
end

local treeState = makeChunkBinder(function(child, set)
    if not (child:IsA("Model") or child:IsA("Folder")) then return end
    if not TREE_NAME_FILTER[child.Name] then return end
    set[child] = true
end)

local bushState = makeChunkBinder(function(child, set)
    if not (child:IsA("Model") or child:IsA("Folder")) then return end
    if not BUSH_NAME_FILTER[child.Name] then return end
    local hitbox = resolveHitbox(child)
    if hitbox then
        set[hitbox] = true
    else
        set[child] = true
    end
end)

local function isLive(entity)
    if not entity or not entity.Parent then return false end
    local hum = entity:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return false end
    return true
end

local function getLiveFrom(state)
    local out = {}
    for entity in pairs(state.set) do
        if isLive(entity) then
            table.insert(out, entity)
        elseif not entity.Parent then
            state.set[entity] = nil
        end
    end
    return out
end

local function makeEsp(set, color, textColor, enabledRef)
    local highlights = {}

    local function attach(entity)
        if highlights[entity] then return end
        if not entity.Parent then return end
        local hl = Instance.new("Highlight")
        hl.Name = "EspHighlight"
        hl.Adornee = entity
        hl.FillColor = color
        hl.OutlineColor = COLOR_OUTLINE
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = entity
        local tag = makeNametag(entity, entity.Name, textColor)
        highlights[entity] = { hl = hl, tag = tag }
    end

    local function detach(entity)
        local entry = highlights[entity]
        if not entry then return end
        if entry.hl then entry.hl:Destroy() end
        if entry.tag then entry.tag:Destroy() end
        highlights[entity] = nil
    end

    local function refresh()
        for entity in pairs(highlights) do
            if not entity.Parent then detach(entity) end
        end
        if not enabledRef() then return end
        for entity in pairs(set) do
            if entity.Parent and not highlights[entity] then
                attach(entity)
            end
        end
    end

    local function clear()
        for entity in pairs(highlights) do detach(entity) end
    end

    return { refresh = refresh, clear = clear, highlights = highlights }
end

local enemyEspEnabled  = false
local animalEspEnabled = false
local treeEspEnabled   = false
local bushEspEnabled   = false

local enemyEsp  = makeEsp(enemyState.set,  COLOR_ENEMY,  COLOR_TEXT_ENEMY,  function() return enemyEspEnabled end)
local animalEsp = makeEsp(animalState.set, COLOR_ANIMAL, COLOR_TEXT_ANIMAL, function() return animalEspEnabled end)
local treeEsp   = makeEsp(treeState.set,   COLOR_TREE,   COLOR_TEXT_TREE,   function() return treeEspEnabled end)
local bushEsp   = makeEsp(bushState.set,   COLOR_BUSH,   COLOR_TEXT_BUSH,   function() return bushEspEnabled end)

local function equipSlot(slot)
    if InventoryActionRemote then
        pcall(function()
            InventoryActionRemote:FireServer("EquipSlot", { slot = slot })
        end)
    end
end

local function fireMouseClick()
    if MouseClickRemote then
        pcall(function() MouseClickRemote:FireServer() end)
    end
end

local function fireGatherHit()
    if GatherHitRemote then
        pcall(function() GatherHitRemote:FireServer() end)
    end
end

local function entityPosition(entity)
    if entity:IsA("BasePart") then
        return entity.Position
    end
    local primary = entity:FindFirstChildWhichIsA("BasePart", true)
    if not primary then return nil end
    return primary.Position
end

local function tweenRootTo(root, targetCFrame)
    local humanoid = root.Parent and root.Parent:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.PlatformStand = true end

    local info = TweenInfo.new(TWEEN_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(root, info, { CFrame = targetCFrame })
    tween:Play()
    tween.Completed:Wait()

    if humanoid then humanoid.PlatformStand = false end
end

local function makeFarm(state, equipSlotNumber, fireFn)
    local farm = { active = false, loop = nil, equipped = false, angle = 0, target = nil }

    local function sweep()
        local targets = getLiveFrom(state)
        if #targets == 0 then
            farm.equipped = false
            farm.target = nil
            return
        end

        if not farm.equipped then
            equipSlot(equipSlotNumber)
            farm.equipped = true
        end

        if not isLive(farm.target) then
            farm.target = targets[1]
            farm.angle = 0
        end

        local entity = farm.target
        if not entity then return end

        local center = entityPosition(entity)
        if not center then
            farm.target = nil
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        farm.angle = farm.angle + math.rad(ORBIT_SPEED) * TWEEN_TIME
        local offset = Vector3.new(
            math.cos(farm.angle) * ORBIT_RADIUS,
            0,
            math.sin(farm.angle) * ORBIT_RADIUS
        )
        local target = CFrame.new(center + offset, center)
        tweenRootTo(root, target)
        fireFn()
    end

    function farm.start()
        if farm.active then return end
        farm.active = true
        if not farm.loop then
            farm.loop = task.spawn(function()
                while farm.active do
                    local ok, err = pcall(sweep)
                    if not ok then warn("farm sweep error:", err) end
                    task.wait(FARM_INTERVAL)
                end
            end)
        end
    end

    function farm.stop()
        farm.active = false
        farm.loop = nil
        farm.equipped = false
        farm.target = nil
    end

    return farm
end

local enemyFarm  = makeFarm(enemyState,  EQUIP_SLOT_ENEMY, fireMouseClick)
local animalFarm = makeFarm(animalState, EQUIP_SLOT_ENEMY, fireMouseClick)
local bushFarm   = makeFarm(bushState,   EQUIP_SLOT_BUSH,  fireGatherHit)
local treeFarm   = makeFarm(treeState,   EQUIP_SLOT_TREE,  fireGatherHit)

task.spawn(function()
    while task.wait(1) do
        enemyEsp.refresh()
        animalEsp.refresh()
        treeEsp.refresh()
        bushEsp.refresh()
    end
end)

FarmTab:Toggle("Enemy Farm", false, function(on)
    if on then enemyFarm.start() else enemyFarm.stop() end
end)

FarmTab:Toggle("Animal Farm", false, function(on)
    if on then animalFarm.start() else animalFarm.stop() end
end)

FarmTab:Toggle("Tree Farm", false, function(on)
    if on then treeFarm.start() else treeFarm.stop() end
end)



VisualsTab:Toggle("Enemy ESP", false, function(on)
    enemyEspEnabled = on
    if on then enemyEsp.refresh() else enemyEsp.clear() end
end)

VisualsTab:Toggle("Animal ESP", false, function(on)
    animalEspEnabled = on
    if on then animalEsp.refresh() else animalEsp.clear() end
end)

VisualsTab:Toggle("Bush ESP", false, function(on)
    bushEspEnabled = on
    if on then bushEsp.refresh() else bushEsp.clear() end
end)

VisualsTab:Toggle("Tree ESP", false, function(on)
    treeEspEnabled = on
    if on then treeEsp.refresh() else treeEsp.clear() end
end)

VisualsTab:Label("Red=enemies | Yellow=animals | Purple=bush | Green=trees")

task.spawn(function()
    while task.wait(0.5) do
        local e, a, b, t = 0, 0, 0, 0
        for _ in pairs(enemyEsp.highlights) do e = e + 1 end
        for _ in pairs(animalEsp.highlights) do a = a + 1 end
        for _ in pairs(bushEsp.highlights) do b = b + 1 end
        for _ in pairs(treeEsp.highlights) do t = t + 1 end
        local state
        if enemyFarm.active and animalFarm.active and bushFarm.active and treeFarm.active then state = "all"
        elseif enemyFarm.active then state = "enemy"
        elseif animalFarm.active then state = "animal"
        elseif bushFarm.active then state = "bush"
        elseif treeFarm.active then state = "tree"
        else state = "idle" end
        local targetName = "—"
        if enemyFarm.target and enemyFarm.target.Parent then
            targetName = "E:" .. enemyFarm.target.Name
        elseif animalFarm.target and animalFarm.target.Parent then
            targetName = "A:" .. animalFarm.target.Name
        elseif bushFarm.target and bushFarm.target.Parent then
            targetName = "B:" .. bushFarm.target.Name
        elseif treeFarm.target and treeFarm.target.Parent then
            targetName = "T:" .. treeFarm.target.Name
        end
        statusLabel:Update(string.format(
            "Status: %s | Target: %s | E:%d A:%d B:%d T:%d",
            state, targetName, e, a, b, t
        ))
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightBracket then
        if enemyFarm.active or animalFarm.active or bushFarm.active or treeFarm.active then
            enemyFarm.stop()
            animalFarm.stop()
            treeFarm.stop()
        else
            enemyFarm.start()
            animalFarm.start()
            treeFarm.start()
        end
    end
end)
