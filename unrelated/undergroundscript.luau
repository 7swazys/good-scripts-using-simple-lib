--[=[
 d888b  db    db d888888b      .d888b.      db      db    db  .d8b.  
88' Y8b 88    88   `88'        VP  `8D      88      88    88 d8' `8b 
88      88    88    88            odD'      88      88    88 88ooo88 
88  ooo 88    88    88          .88'        88      88    88 88~~~88 
88. ~8~ 88b  d88   .88.        j88.         88booo. 88b  d88 88   88    @uniquadev
 Y888P  ~Y8888P' Y888888P      888888D      Y88888P ~Y8888P' YP   YP  CONVERTER 
]=]

local G2L = {};

local uiParent = gethui and gethui() or game:GetService("CoreGui")

G2L["1"] = Instance.new("ScreenGui", uiParent);
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["DisplayOrder"] = 999999999;
G2L["1"]["ResetOnSpawn"] = false;

G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["ZIndex"] = 999999999;
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2"]["Size"] = UDim2.new(0, 118, 0, 80);
G2L["2"]["Position"] = UDim2.new(0.45423, 0, 0.45377, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2"]["Name"] = [[undergroundscript]];
G2L["2"]["BackgroundTransparency"] = 1;

G2L["3"] = Instance.new("UICorner", G2L["2"]);

G2L["4"] = Instance.new("TextButton", G2L["2"]);
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["TextSize"] = 14;
G2L["4"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(171, 255, 165);
G2L["4"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["4"]["Size"] = UDim2.new(0, 118, 0, 50);
G2L["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["Text"] = [[underground button]];
G2L["4"]["Name"] = [[toggle on/off]];
G2L["4"]["Position"] = UDim2.new(-0.00409, 0, 0.18606, 0);
G2L["4"]["ZIndex"] = 999999999;

G2L["5"] = Instance.new("UICorner", G2L["4"]);

G2L["6"] = Instance.new("UIGradient", G2L["4"]);
G2L["6"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(171, 255, 165)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(171, 255, 165))};

G2L["7"] = Instance.new("UIDragDetector", G2L["2"]);

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local underground = false
local targetY = 0
local originalCamPos = nil
local camConnection = nil
local noclipConnection = nil
local underConnection = nil
local tweenOffset = 30

local function startNoclip()
    if noclipConnection then noclipConnection:Disconnect() end
    noclipConnection = RunService.Stepped:Connect(function()
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
    
    originalCamPos = workspace.CurrentCamera.CFrame
    targetY = root.Position.Y - tweenOffset
    
    root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z)
    
    startNoclip()
    
    if camConnection then camConnection:Disconnect() end
    camConnection = RunService.RenderStepped:Connect(function()
        if not underground then return end
        if not player.Character then return end
        
        local cam = workspace.CurrentCamera
        local camPos = cam.CFrame.Position
        local targetCamPos = Vector3.new(camPos.X, originalCamPos.Position.Y, camPos.Z)
        cam.CFrame = CFrame.new(targetCamPos, targetCamPos + cam.CFrame.LookVector)
    end)
    
    if underConnection then underConnection:Disconnect() end
    underConnection = RunService.Heartbeat:Connect(function()
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

local screenGui = G2L["1"]
local button = G2L["4"]

button.MouseButton1Click:Connect(function()
    underground = not underground
    button.Text = underground and "underground on" or "underground off"
    if underground then
        button.BackgroundColor3 = Color3.fromRGB(171, 255, 165)
        button.UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(171, 255, 165)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(171, 255, 165))}
    else
        button.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
        button.UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 150, 150)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 150, 150))}
    end
    if underground then
        startUnderground()
    else
        stopUnderground()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        underground = not underground
        button.Text = underground and "underground on" or "underground off"
        if underground then
            button.BackgroundColor3 = Color3.fromRGB(171, 255, 165)
            button.UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(171, 255, 165)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(171, 255, 165))}
        else
            button.BackgroundColor3 = Color3.fromRGB(255, 150, 150)
            button.UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 150, 150)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 150, 150))}
        end
        if underground then
            startUnderground()
        else
            stopUnderground()
        end
    end
end)

return G2L["1"], require;
