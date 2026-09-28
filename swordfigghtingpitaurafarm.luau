
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")

local LocalPlayer  = Players.LocalPlayer
local AttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attack")

-- zone
local ZONE_CENTER = Vector3.new(-4, 2, -5)
local ZONE_RADIUS = 40

-- orbit
local ORBIT_RADIUS = 6
local ORBIT_SPEED  = 80

-- attack cadence
local ATTACK_INTERVAL = 0.03
local ATTACK_MIN      = 0.02

-- return tween
local RETURN_TIME      = 0.8
local RETURN_EASING    = Enum.EasingStyle.Quad
local RETURN_DIRECTION = Enum.EasingDirection.Out

-- exclusion
local AVOID_PART_PATH = {"Map"}
local AVOID_PART_NAME = "MiddleMesh3"
local AVOID_RADIUS    = 12
local BODY_PADDING    = 3
local MAX_PROBES      = 16
local PROBE_STEP      = math.rad(22.5)

local isAutofarming  = false
local farmConnection = nil
local attackThread   = nil
local angle          = 0
local lastPosition   = nil
local currentTarget  = nil
local returnTween    = nil

local avoidPart = nil
local function resolveAvoidPart()
    local node = workspace
    for _, seg in ipairs(AVOID_PART_PATH) do
        node = node and node:FindFirstChild(seg)
        if not node then break end
    end
    avoidPart = node and node:FindFirstChild(AVOID_PART_NAME) or nil
    if avoidPart and not avoidPart:IsA("BasePart") then avoidPart = nil end
end
resolveAvoidPart()

local EXCLUDE_R2 = (AVOID_RADIUS + BODY_PADDING) ^ 2
local ZONE_R2    = ZONE_RADIUS * ZONE_RADIUS

local function pointBlocked(pos)
    if not avoidPart then return false end
    local d = pos - avoidPart.Position
    return d:Dot(d) < EXCLUDE_R2
end

local function segPointDistSq(a, b, p)
    local ab = b - a
    local ap = p - a
    local abLenSq = ab:Dot(ab)
    if abLenSq < 1e-6 then
        local d = p - a
        return d:Dot(d)
    end
    local t = math.clamp(ap:Dot(ab) / abLenSq, 0, 1)
    local closest = a + ab * t
    local d = p - closest
    return d:Dot(d)
end

local function sweepBlocked(fromPos, toPos)
    if not avoidPart then return false end
    if not fromPos then return pointBlocked(toPos) end
    return segPointDistSq(fromPos, toPos, avoidPart.Position) < EXCLUDE_R2
end

local function inZone(hitbox)
    local d = hitbox.Position - ZONE_CENTER
    return d:Dot(d) <= ZONE_R2
end

local function getZoneTargets()
    local container = workspace:FindFirstChild("PlayersContainer")
    if not container then return {} end

    local out = {}
    for _, folder in ipairs(container:GetChildren()) do
        if folder.Name ~= LocalPlayer.Name then
            local hb = folder:FindFirstChild("Hitbox")
            if hb and hb:IsA("BasePart") and inZone(hb) then
                local d = hb.Position - ZONE_CENTER
                table.insert(out, { hitbox = hb, folder = folder, distSq = d:Dot(d) })
            end
        end
    end
    table.sort(out, function(a, b) return a.distSq < b.distSq end)
    return out
end

local function findSafeSlot(targetHitbox, baseAngle, fromPos)
    for probe = 0, MAX_PROBES do
        local a = baseAngle + probe * PROBE_STEP
        local ox = math.cos(a) * ORBIT_RADIUS
        local oz = math.sin(a) * ORBIT_RADIUS
        local candidate = Vector3.new(
            targetHitbox.Position.X + ox,
            targetHitbox.Position.Y,
            targetHitbox.Position.Z + oz
        )
        if not pointBlocked(candidate) and not sweepBlocked(fromPos, candidate) then
            return candidate, a
        end
    end
    return nil, nil
end

local function pickTarget(baseAngle)
    local targets = getZoneTargets()
    for _, t in ipairs(targets) do
        local pos, a = findSafeSlot(t.hitbox, baseAngle, lastPosition)
        if pos then return t, pos, a end
    end
    return nil
end

local function cancelReturn()
    if returnTween then
        returnTween:Cancel()
        returnTween = nil
    end
end

local function startReturn(myRoot)
    if returnTween then return end

    local from = myRoot.Position
    if pointBlocked(ZONE_CENTER) then return end
    if sweepBlocked(from, ZONE_CENTER) then return end

    local goal = CFrame.new(ZONE_CENTER)
    local tweenInfo = TweenInfo.new(
        RETURN_TIME,
        RETURN_EASING,
        RETURN_DIRECTION
    )

    returnTween = TweenService:Create(myRoot, tweenInfo, { CFrame = goal })
    returnTween.Completed:Connect(function()
        returnTween = nil
        lastPosition = ZONE_CENTER
        angle        = 0
    end)
    returnTween:Play()
end

local function startOrbitFarm()
    farmConnection = RunService.Heartbeat:Connect(function(dt)
        local character = LocalPlayer.Character
        local myRoot    = character and character:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            cancelReturn()
            return
        end

        if not avoidPart then resolveAvoidPart() end

        angle = angle + (ORBIT_SPEED * dt)

        if currentTarget then
            local hb = currentTarget.hitbox
            if not hb or not hb.Parent or not inZone(hb) then
                currentTarget = nil
            end
        end

        if not currentTarget then
            local chosen, chosenPos, chosenAngle = pickTarget(angle)
            if chosen then
                cancelReturn()
                currentTarget = chosen
                angle         = chosenAngle
                myRoot.CFrame = CFrame.new(chosenPos, chosen.hitbox.Position)
                lastPosition  = chosenPos
            else
                startReturn(myRoot)
            end
            return
        end

        local pos, a = findSafeSlot(currentTarget.hitbox, angle, lastPosition)
        if not pos then
            currentTarget = nil
            return
        end

        angle = a
        myRoot.CFrame = CFrame.new(pos, currentTarget.hitbox.Position)
        lastPosition  = pos
    end)
end

local function startAttackLoop()
    local interval = math.max(ATTACK_INTERVAL, ATTACK_MIN)

    attackThread = task.spawn(function()
        while isAutofarming do
            if currentTarget and AttackRemote then
                local character = LocalPlayer.Character
                local myRoot    = character and character:FindFirstChild("HumanoidRootPart")
                local hb        = currentTarget.hitbox
                if myRoot and hb and hb.Parent then
                    pcall(function()
                        local dir = (hb.Position - myRoot.Position).Unit
                        AttackRemote:FireServer(dir, hb)
                    end)
                end
            end
            task.wait(interval)
        end
    end)
end

local function stopOrbitFarm()
    cancelReturn()
    if farmConnection then
        farmConnection:Disconnect()
        farmConnection = nil
    end
    attackThread  = nil
    currentTarget = nil
    lastPosition  = nil
    angle         = 0
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        isAutofarming = not isAutofarming
        if isAutofarming then
            print(("Orbit Autofarm: ACTIVE — zone (-4, 2, -5) r=%d, atk %.2fs"):format(ZONE_RADIUS, math.max(ATTACK_INTERVAL, ATTACK_MIN)))
            startOrbitFarm()
            startAttackLoop()
        else
            print("Orbit Autofarm: INACTIVE")
            stopOrbitFarm()
        end
    end
end)
