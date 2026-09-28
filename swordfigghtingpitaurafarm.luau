-- Luau — Roblox client script
-- orbit autofarm. return-to-anchor uses direct per-frame CFrame writes
-- on Heartbeat instead of TweenService, because the server overrides a
-- client tween on a replicated character. per-frame writes look like
-- teleport-stepping to the server, which it tolerates; a tween looks
-- like one long invalid interpolation and gets dropped.
--
-- added a DEBUG flag. when true, prints every frame why the return did
-- or did not advance. flip to false once the return is confirmed working.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")

local LocalPlayer  = Players.LocalPlayer
local AttackRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Attack")
local RebirthRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Rebirth")

local DEBUG = true

-- zone
local ZONE_CENTER = Vector3.new(-4, 2, -5)
local ZONE_RADIUS = 40

-- orbit
local ORBIT_RADIUS = 6
local ORBIT_SPEED  = 80

-- attack
local ATTACK_INTERVAL = 0.03
local ATTACK_MIN      = 0.02

-- return (now step-based, not tween)
local RETURN_SPEED     = 60    -- studs/second while walking home
local RETURN_SNAP_DIST = 0.5   -- studs; closer than this = arrived

-- hop
local HOP_EMPTY_SECONDS  = 15
local HOP_CHECK_INTERVAL = 1
local HOP_MAX_ATTEMPTS   = 5
local HOP_RETRY_DELAY    = 3

-- rebirth
local REBIRTH_INTERVAL = 5

-- exclusion
local AVOID_PART_PATH = {"Map"}
local AVOID_PART_NAME = "MiddleMesh3"
local AVOID_RADIUS    = 12
local BODY_PADDING    = 3
local MAX_PROBES      = 16
local PROBE_STEP      = math.rad(22.5)

local angle          = 0
local lastPosition   = nil
local currentTarget  = nil
local returning      = false
local farmConnection = nil
local attackThread   = nil
local rebirthThread  = nil
local hopThread      = nil
local running        = true

local avoidPart = nil
local function resolveAvoidPart()
    local node = workspace
    for _, seg in ipairs(AVOID_PART_PATH) do
        node = node and node:FindFirstChild(seg)
        if not node then break end
    end
    avoidPart = node and node:FindFirstChild(AVOID_PART_NAME) or nil
    if avoidPart and not avoidPart:IsA("BasePart") then avoidPart = nil end
    if DEBUG then
        print("[Luis] avoidPart:", avoidPart and avoidPart:GetFullName() or "nil")
    end
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

local function isDead(target)
    if not target then return true end
    local hb = target.hitbox
    if not hb or not hb.Parent then return true end
    local folder = target.folder
    if not folder or not folder.Parent then return true end
    local humanoid = folder:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health <= 0 then return true end
    return false
end

local function getZoneTargets()
    local container = workspace:FindFirstChild("PlayersContainer")
    if not container then return {} end

    local out = {}
    for _, folder in ipairs(container:GetChildren()) do
        if folder.Name ~= LocalPlayer.Name then
            local hb = folder:FindFirstChild("Hitbox")
            if hb and hb:IsA("BasePart") and inZone(hb) then
                local humanoid = folder:FindFirstChildOfClass("Humanoid")
                if not (humanoid and humanoid.Health <= 0) then
                    local d = hb.Position - ZONE_CENTER
                    table.insert(out, {
                        hitbox = hb, folder = folder, name = folder.Name,
                        distSq = d:Dot(d),
                    })
                end
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

-- ---------- RETURN: direct per-frame step, no tween ----------
--
-- each Heartbeat moves the root a bounded distance toward ZONE_CENTER.
-- position writes look like normal movement to the server, not a tween
-- interpolation, so the server does not fight them.
--
-- the sweep gate only blocks a step that would cross MiddleMesh3. if the
-- step is blocked, the character is nudged along the ring tangent instead
-- of being frozen — that lets it walk around the mesh rather than stall.

local function stepReturn(myRoot, dt)
    local pos = myRoot.Position
    local toCenter = ZONE_CENTER - pos
    local dist = toCenter.Magnitude

    if dist <= RETURN_SNAP_DIST then
        myRoot.CFrame = CFrame.new(ZONE_CENTER)
        lastPosition = ZONE_CENTER
        angle = 0
        returning = false
        if DEBUG then print("[Luis] return: arrived") end
        return
    end

    local dir = toCenter / dist
    local maxStep = RETURN_SPEED * dt
    local stepDist = math.min(maxStep, dist)
    local target = pos + dir * stepDist

    -- gate: if this step crosses the exclusion volume, deflect along
    -- the tangent so the character walks around rather than stalling.
    if pointBlocked(target) or sweepBlocked(pos, target) then
        local tangent = Vector3.new(-dir.Z, 0, dir.X)
        local side = (math.floor(angle / math.pi) % 2 == 0) and 1 or -1
        local altTarget = pos + tangent * stepDist * side
        if not pointBlocked(altTarget) and not sweepBlocked(pos, altTarget) then
            target = altTarget
            if DEBUG then print("[Luis] return: deflecting around mesh") end
        else
            if DEBUG then print("[Luis] return: blocked, holding") end
            return
        end
    end

    myRoot.CFrame = CFrame.new(target, target + dir)
    lastPosition = target
end

-- ---------- orbit loop ----------

local function startOrbitFarm()
    farmConnection = RunService.Heartbeat:Connect(function(dt)
        if not running then return end

        local character = LocalPlayer.Character
        local myRoot    = character and character:FindFirstChild("HumanoidRootPart")
        if not myRoot then
            if DEBUG then print("[Luis] no HumanoidRootPart this frame") end
            return
        end

        if not avoidPart then resolveAvoidPart() end

        -- returning takes priority over orbit. do not fall through.
        if returning then
            stepReturn(myRoot, dt)
            return
        end

        angle = angle + (ORBIT_SPEED * dt)

        if currentTarget and isDead(currentTarget) then
            if DEBUG then print("[Luis] target died, returning") end
            currentTarget = nil
            returning = true
            return
        end

        if currentTarget and not inZone(currentTarget.hitbox) then
            if DEBUG then print("[Luis] target left zone, returning") end
            currentTarget = nil
            returning = true
            return
        end

        if not currentTarget then
            local chosen, chosenPos, chosenAngle = pickTarget(angle)
            if chosen then
                if DEBUG then print("[Luis] acquired target:", chosen.name) end
                currentTarget = chosen
                angle         = chosenAngle
                myRoot.CFrame = CFrame.new(chosenPos, chosen.hitbox.Position)
                lastPosition  = chosenPos
            end
            return
        end

        local pos, a = findSafeSlot(currentTarget.hitbox, angle, lastPosition)
        if not pos then
            if DEBUG then print("[Luis] no safe orbit slot, returning") end
            currentTarget = nil
            returning = true
            return
        end

        angle = a
        myRoot.CFrame = CFrame.new(pos, currentTarget.hitbox.Position)
        lastPosition  = pos
    end)
end

-- ---------- attack loop ----------

local function startAttackLoop()
    local interval = math.max(ATTACK_INTERVAL, ATTACK_MIN)
    attackThread = task.spawn(function()
        while running do
            if currentTarget and AttackRemote and not returning then
                local character = LocalPlayer.Character
                local myRoot    = character and character:FindFirstChild("HumanoidRootPart")
                local hb        = currentTarget.hitbox
                if myRoot and hb and hb.Parent and not isDead(currentTarget) then
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

-- ---------- rebirth loop ----------

local function startRebirthLoop()
    rebirthThread = task.spawn(function()
        while running do
            pcall(function() RebirthRemote:FireServer() end)
            task.wait(REBIRTH_INTERVAL)
        end
    end)
end

-- ---------- server hop ----------

local function isServerEmpty()
    local container = workspace:FindFirstChild("PlayersContainer")
    if not container then return true end
    for _, folder in ipairs(container:GetChildren()) do
        if folder.Name ~= LocalPlayer.Name then return false end
    end
    return true
end

local function findOtherServer()
    for _ = 1, HOP_MAX_ATTEMPTS do
        local ok, pages = pcall(function()
            return TeleportService:GetSortedAsync(false, 100)
        end)
        if ok and pages then
            local pageOk, page = pcall(function() return pages:GetCurrentPage() end)
            if pageOk and page then
                for _, entry in ipairs(page) do
                    if entry.jobId and entry.jobId ~= game.JobId then
                        return entry.jobId, entry.placeId or game.PlaceId
                    end
                end
                pcall(function() pages:AdvanceToNextPageAsync() end)
            end
        end
        task.wait(HOP_RETRY_DELAY)
    end
    return nil, nil
end

local function hopServer()
    local jobId, placeId = findOtherServer()
    if not jobId then task.wait(HOP_RETRY_DELAY); return end
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId or game.PlaceId, jobId, LocalPlayer)
    end)
end

local function startHopWatchdog()
    hopThread = task.spawn(function()
        local emptySince = nil
        while running do
            task.wait(HOP_CHECK_INTERVAL)
            if isServerEmpty() then
                emptySince = emptySince or os.clock()
                if os.clock() - emptySince >= HOP_EMPTY_SECONDS then
                    if DEBUG then print("[Luis] server empty, hopping") end
                    hopServer()
                    emptySince = nil
                end
            else
                emptySince = nil
            end
        end
    end)
end

-- ---------- boot ----------

running = true
startOrbitFarm()
startAttackLoop()
startRebirthLoop()
startHopWatchdog()

print(("[Luis] AUTO — zone (-4,2,-5) r=%d, orbit spd %.0f, return spd %.0f, rebirth %ds, hop %ds")
    :format(ZONE_RADIUS, ORBIT_SPEED, RETURN_SPEED, REBIRTH_INTERVAL, HOP_EMPTY_SECONDS))

Players.PlayerRemoving:Connect(function(p)
    if p == LocalPlayer then
        running = false
        if farmConnection then farmConnection:Disconnect() end
    end
end)
