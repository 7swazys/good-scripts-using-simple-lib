local v0 = game:GetService("Players")
local v1 = game:GetService("TweenService")
local v2 = game:GetService("UserInputService")
local v3 = game:GetService("RunService")
local v4 = game:GetService("CoreGui")
local v5 = game:GetService("HttpService")
local v6 = game:GetService("StarterGui")

local v7 = v0.LocalPlayer
local v8 = v7:FindFirstChild("PlayerGui")
local v9 = v7.Character or v7.CharacterAdded:Wait()
local v10 = v9:WaitForChild("Humanoid")

if not isfolder("doesntworkwarefuckyoumonkey_AvatarChanger") then
    makefolder("doesntworkwarefuckyoumonkey_AvatarChanger")
end
if not isfolder("doesntworkwarefuckyoumonkey_AvatarChanger/Avatars") then
    makefolder("doesntworkwarefuckyoumonkey_AvatarChanger/Avatars")
end
if not isfolder("doesntworkwarefuckyoumonkey_AvatarChanger/Clans") then
    makefolder("doesntworkwarefuckyoumonkey_AvatarChanger/Clans")
end

local v11 = nil
pcall(function()
    v11 = v0:GetHumanoidDescriptionFromUserId(v7.UserId)
end)

local v12 = {}

local v13 = {
    Background = Color3.fromRGB(18, 18, 22),
    Card = Color3.fromRGB(28, 28, 34),
    Stroke = Color3.fromRGB(50, 50, 60),
    Accent = Color3.fromRGB(80, 140, 255),
    Success = Color3.fromRGB(45, 140, 80),
    Danger = Color3.fromRGB(180, 60, 60),
    Text = Color3.fromRGB(230, 230, 230),
    TextDark = Color3.fromRGB(150, 150, 150),
    Divider = Color3.fromRGB(43, 105, 122)
}

local v14 = nil
if typeof(gethui) == "function" then
    pcall(function()
        v14 = gethui():FindFirstChild("KixPhantomMorphUI")
    end)
end
if not v14 then
    pcall(function()
        v14 = v4:FindFirstChild("KixPhantomMorphUI")
    end)
end
if not v14 and v8 then
    v14 = v8:FindFirstChild("KixPhantomMorphUI")
end
if v14 then
    v14:Destroy()
end

local v15 = Instance.new("ScreenGui")
v15.Name = "KixPhantomMorphUI"
v15.ResetOnSpawn = false

local v16 = nil
if typeof(gethui) == "function" then
    pcall(function()
        v16 = gethui()
    end)
end
if not v16 then
    pcall(function()
        v16 = v4
    end)
end
if not v16 then
    v16 = v8
end
v15.Parent = v16

local v17 = Instance.new("Frame")
v17.Name = "MainFrame"
v17.Size = UDim2.new(0, 280, 0, 600)
v17.Position = UDim2.new(0, 20, 0.5, -300)
v17.BackgroundColor3 = v13.Background
v17.BorderSizePixel = 0
v17.ClipsDescendants = true
v17.Parent = v15

local v18 = Instance.new("UICorner")
v18.CornerRadius = UDim.new(0, 8)
v18.Parent = v17

local v19 = Instance.new("UIStroke")
v19.Color = v13.Stroke
v19.Thickness = 1
v19.Parent = v17

local v20 = Instance.new("Frame")
v20.Name = "Header"
v20.Size = UDim2.new(1, 0, 0, 36)
v20.BackgroundColor3 = v13.Card
v20.BorderSizePixel = 0
v20.Parent = v17

local v21 = Instance.new("TextLabel")
v21.Name = "Title"
v21.Size = UDim2.new(1, -80, 1, 0)
v21.Position = UDim2.new(0, 12, 0, 0)
v21.BackgroundTransparency = 1
v21.Text = "AVATAR CHANGER by doesntworkwarefuckyoumonkey"
v21.TextColor3 = v13.Text
v21.Font = Enum.Font.GothamBold
v21.TextSize = 13
v21.TextXAlignment = Enum.TextXAlignment.Left
v21.Parent = v20

local v22 = Instance.new("TextButton")
v22.Name = "MinBtn"
v22.Size = UDim2.new(0, 36, 0, 36)
v22.Position = UDim2.new(1, -72, 0, 0)
v22.BackgroundTransparency = 1
v22.Text = "-"
v22.TextColor3 = v13.Text
v22.Font = Enum.Font.GothamBold
v22.TextSize = 18
v22.Parent = v20

local v23 = Instance.new("TextButton")
v23.Name = "CloseBtn"
v23.Size = UDim2.new(0, 36, 0, 36)
v23.Position = UDim2.new(1, -36, 0, 0)
v23.BackgroundTransparency = 1
v23.Text = "X"
v23.TextColor3 = v13.Text
v23.Font = Enum.Font.GothamBold
v23.TextSize = 14
v23.Parent = v20

local v24, v25, v26, v27
v20.InputBegan:Connect(function(v28)
    if v28.UserInputType == Enum.UserInputType.MouseButton1 or v28.UserInputType == Enum.UserInputType.Touch then
        v24 = true
        v26 = v28.Position
        v27 = v17.Position
        v28.Changed:Connect(function()
            if v28.UserInputState == Enum.UserInputState.End then
                v24 = false
            end
        end)
    end
end)

v20.InputChanged:Connect(function(v29)
    if v29.UserInputType == Enum.UserInputType.MouseMovement or v29.UserInputType == Enum.UserInputType.Touch then
        v25 = v29
    end
end)

v2.InputChanged:Connect(function(v30)
    if v30 == v25 and v24 then
        local v31 = v30.Position - v26
        v17.Position = UDim2.new(v27.X.Scale, v27.X.Offset + v31.X, v27.Y.Scale, v27.Y.Offset + v31.Y)
    end
end)

local v32 = Instance.new("Frame")
v32.Name = "Content"
v32.Size = UDim2.new(1, 0, 1, -36)
v32.Position = UDim2.new(0, 0, 0, 36)
v32.BackgroundTransparency = 1
v32.Parent = v17

local v33 = false
v22.MouseButton1Click:Connect(function()
    v33 = not v33
    if v33 then
        v17.Size = UDim2.new(0, 280, 0, 36)
        v32.Visible = false
    else
        v17.Size = UDim2.new(0, 280, 0, 600)
        v32.Visible = true
    end
end)

v23.MouseButton1Click:Connect(function()
    v15:Destroy()
end)

local v34 = Instance.new("TextLabel")
v34.Name = "StatusLabel"
v34.Size = UDim2.new(1, -24, 0, 15)
v34.Position = UDim2.new(0, 12, 0, 5)
v34.BackgroundTransparency = 1
v34.Text = "Status: Idle"
v34.TextColor3 = v13.TextDark
v34.Font = Enum.Font.Gotham
v34.TextSize = 11
v34.TextXAlignment = Enum.TextXAlignment.Left
v34.Parent = v32

local function v35(v36, v37)
    v34.Text = "Status: " .. v36
    v34.TextColor3 = v37 or v13.TextDark
end

local v38 = Instance.new("TextBox")
v38.Name = "SearchBox"
v38.Size = UDim2.new(1, -24, 0, 30)
v38.Position = UDim2.new(0, 12, 0, 25)
v38.BackgroundColor3 = v13.Card
v38.BorderSizePixel = 0
v38.PlaceholderText = "Search by username or ID..."
v38.PlaceholderColor3 = v13.TextDark
v38.Text = ""
v38.TextColor3 = v13.Text
v38.Font = Enum.Font.Gotham
v38.TextSize = 12
v38.ClearTextOnFocus = false
v38.Parent = v32

local v39 = Instance.new("UICorner")
v39.CornerRadius = UDim.new(0, 4)
v39.Parent = v38

local v40 = Instance.new("TextButton")
v40.Name = "MorphBtn"
v40.Size = UDim2.new(1, -24, 0, 28)
v40.Position = UDim2.new(0, 12, 0, 60)
v40.BackgroundColor3 = v13.Accent
v40.BorderSizePixel = 0
v40.Text = "> Morph by Target"
v40.TextColor3 = v13.Text
v40.Font = Enum.Font.GothamBold
v40.TextSize = 12
v40.Parent = v32

local v41 = Instance.new("UICorner")
v41.CornerRadius = UDim.new(0, 4)
v41.Parent = v40

local v42 = Instance.new("TextButton")
v42.Name = "UnmorphBtn"
v42.Size = UDim2.new(1, -24, 0, 28)
v42.Position = UDim2.new(0, 12, 0, 93)
v42.BackgroundColor3 = v13.Danger
v42.BorderSizePixel = 0
v42.Text = "[X] Unmorph (Restore Self)"
v42.TextColor3 = v13.Text
v42.Font = Enum.Font.GothamBold
v42.TextSize = 12
v42.Parent = v32

local v43 = Instance.new("UICorner")
v43.CornerRadius = UDim.new(0, 4)
v43.Parent = v42

local function v44(v45)
    if not v45 or v45 == "" then
        v35("Enter username or ID", v13.Danger)
        return
    end

    v35("Fetching target...", v13.Accent)
    local v46 = tonumber(v45)
    if not v46 then
        local v47, v48 = pcall(function()
            return v0:GetUserIdFromNameAsync(v45)
        end)
        if v47 and v48 then
            v46 = v48
        else
            v35("User not found", v13.Danger)
            return
        end
    end

    local v49 = v7.Character
    if not v49 then return end
    local v50 = v49:FindFirstChildOfClass("Humanoid")
    if not v50 then return end

    local v51, v52 = pcall(function()
        return v0:GetHumanoidDescriptionFromUserId(v46)
    end)

    if v51 and v52 then
        v35("Applying avatar...", v13.Accent)
        pcall(function()
            v50:ApplyDescription(v52)
        end)
        pcall(function()
            local v53 = "doesntworkwarefuckyoumonkey_AvatarChanger/Avatars/" .. tostring(v46) .. ".json"
            local v54 = {
                UserId = v46,
                SavedAt = os.time()
            }
            writefile(v53, v5:JSONEncode(v54))
        end)
        v35("Morphed to " .. tostring(v46), v13.Success)
    else
        v35("Failed to load description", v13.Danger)
    end
end

v40.MouseButton1Click:Connect(function()
    v44(v38.Text)
end)

v42.MouseButton1Click:Connect(function()
    local v55 = v7.Character
    if not v55 then return end
    local v56 = v55:FindFirstChildOfClass("Humanoid")
    if not v56 then return end

    if v11 then
        v35("Restoring avatar...", v13.Accent)
        pcall(function()
            v56:ApplyDescription(v11)
        end)
        v35("Restored original avatar", v13.Success)
    else
        v35("Original description unavailable", v13.Danger)
    end
end)

local v57 = Instance.new("Frame")
v57.Name = "Divider"
v57.Size = UDim2.new(1, -24, 0, 1)
v57.Position = UDim2.new(0, 12, 0, 130)
v57.BackgroundColor3 = v13.Divider
v57.BorderSizePixel = 0
v57.Parent = v32

local v58 = Instance.new("TextButton")
v58.Name = "SaveAvatarBtn"
v58.Size = UDim2.new(1, -24, 0, 26)
v58.Position = UDim2.new(0, 12, 0, 138)
v58.BackgroundColor3 = v13.Card
v58.BorderSizePixel = 0
v58.Text = "💾 Save Current Avatar"
v58.TextColor3 = v13.Text
v58.Font = Enum.Font.Gotham
v58.TextSize = 12
v58.Parent = v32

local v59 = Instance.new("UICorner")
v59.CornerRadius = UDim.new(0, 4)
v59.Parent = v58

v58.MouseButton1Click:Connect(function()
    local v60 = v7.Character
    if not v60 then return end
    local v61 = v60:FindFirstChildOfClass("Humanoid")
    if not v61 then return end

    local v62, v63 = pcall(function()
        return v61:GetAppliedDescription()
    end)

    if v62 and v63 then
        local v64 = "doesntworkwarefuckyoumonkey_AvatarChanger/Avatars/Saved_" .. tostring(os.time()) .. ".json"
        pcall(function()
            writefile(v64, v5:JSONEncode({
                SavedAt = os.time(),
                Player = v7.Name
            }))
        end)
        v35("Avatar saved", v13.Success)
    else
        v35("Failed to save avatar", v13.Danger)
    end
end)

local v65 = Instance.new("TextBox")
v65.Name = "PackSearchBox"
v65.Size = UDim2.new(1, -24, 0, 26)
v65.Position = UDim2.new(0, 12, 0, 172)
v65.BackgroundColor3 = v13.Card
v65.BorderSizePixel = 0
v65.PlaceholderText = "Search pack..."
v65.PlaceholderColor3 = v13.TextDark
v65.Text = ""
v65.TextColor3 = v13.Text
v65.Font = Enum.Font.Gotham
v65.TextSize = 12
v65.ClearTextOnFocus = false
v65.Parent = v32

local v66 = Instance.new("UICorner")
v66.CornerRadius = UDim.new(0, 4)
v66.Parent = v65

local v67 = Instance.new("ScrollingFrame")
v67.Name = "PackScroll"
v67.Size = UDim2.new(1, -24, 0, 230)
v67.Position = UDim2.new(0, 12, 0, 204)
v67.BackgroundColor3 = v13.Background
v67.BorderSizePixel = 0
v67.ScrollBarThickness = 4
v67.ScrollBarImageColor3 = v13.Stroke
v67.CanvasSize = UDim2.new(0, 0, 0, 0)
v67.Parent = v32

local v68 = Instance.new("UIListLayout")
v68.SortOrder = Enum.SortOrder.LayoutOrder
v68.Padding = UDim.new(0, 4)
v68.Parent = v67

v68:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    v67.CanvasSize = UDim2.new(0, 0, 0, v68.AbsoluteContentSize.Y + 10)
end)

local v69 = {
    ["🌟 Restore Default Animations"] = "default",
    ["Anim Pack: Default"] = "default",
    ["Ninja"] = "ninja",
    ["Zombie"] = "zombie",
    ["Superhero"] = "superhero",
    ["Mage"] = "mage",
    ["Levitation"] = "levitation",
    ["Astronaut"] = "astronaut",
    ["Elder"] = "elder",
    ["Toy"] = "toy",
    ["Knight"] = "knight",
    ["Bubbly"] = "bubbly",
    ["Werewolf"] = "werewolf",
    ["Vampire"] = "vampire",
    ["Adidas Community"] = "adidas_community",
    ["Amazon Unboxed"] = "amazon_unboxed",
    ["Wicked Popular"] = "wicked_popular",
    ["Adidas Sports"] = "adidas_sports",
    ["No Boundaries"] = "no_boundaries",
    ["Catwalk Glam"] = "catwalk_glam",
    ["Adidas Aura"] = "adidas_aura"
}

local v70 = {}

local function v71(v72)
    local v73 = v7.Character
    if not v73 then return end
    local v74 = v73:FindFirstChild("Animate")
    if not v74 then return end

    v7:SetAttribute("AnimPack_Last", v72)
    v35("Pack: " .. v72, v13.Accent)
end

for v75, v76 in pairs(v69) do
    local v77 = Instance.new("TextButton")
    v77.Name = v75
    v77.Size = UDim2.new(1, 0, 0, 30)
    v77.BackgroundColor3 = v13.Card
    v77.BorderSizePixel = 0
    v77.Text = v75
    v77.TextColor3 = v13.Text
    v77.Font = Enum.Font.Gotham
    v77.TextSize = 12
    v77.Parent = v67

    local v78 = Instance.new("UICorner")
    v78.CornerRadius = UDim.new(0, 4)
    v78.Parent = v77

    v77.MouseButton1Click:Connect(function()
        v71(v75)
    end)

    table.insert(v70, v77)
end

v65:GetPropertyChangedSignal("Text"):Connect(function()
    local v79 = v65.Text:lower()
    for _, v80 in ipairs(v70) do
        if v79 == "" or string.find(v80.Text:lower(), v79, 1, true) then
            v80.Visible = true
        else
            v80.Visible = false
        end
    end
end)

local v81 = Instance.new("Frame")
v81.Name = "Divider2"
v81.Size = UDim2.new(1, -24, 0, 1)
v81.Position = UDim2.new(0, 12, 0, 445)
v81.BackgroundColor3 = v13.Divider
v81.BorderSizePixel = 0
v81.Parent = v32

local v82 = Instance.new("TextLabel")
v82.Name = "EmoteTitle"
v82.Size = UDim2.new(1, -24, 0, 20)
v82.Position = UDim2.new(0, 12, 0, 455)
v82.BackgroundTransparency = 1
v82.Text = "Custom Emote Player by ID"
v82.TextColor3 = v13.Text
v82.Font = Enum.Font.GothamBold
v82.TextSize = 12
v82.TextXAlignment = Enum.TextXAlignment.Left
v82.Parent = v32

local v83 = Instance.new("TextBox")
v83.Name = "EmoteBox"
v83.Size = UDim2.new(1, -24, 0, 30)
v83.Position = UDim2.new(0, 12, 0, 480)
v83.BackgroundColor3 = v13.Card
v83.BorderSizePixel = 0
v83.PlaceholderText = "Insert ID Emote..."
v83.PlaceholderColor3 = v13.TextDark
v83.Text = ""
v83.TextColor3 = v13.Text
v83.Font = Enum.Font.Gotham
v83.TextSize = 12
v83.ClearTextOnFocus = false
v83.Parent = v32

local v84 = Instance.new("UICorner")
v84.CornerRadius = UDim.new(0, 4)
v84.Parent = v83

local v85 = Instance.new("TextButton")
v85.Name = "PlayBtn"
v85.Size = UDim2.new(0.5, -16, 0, 28)
v85.Position = UDim2.new(0, 12, 0, 515)
v85.BackgroundColor3 = v13.Success
v85.BorderSizePixel = 0
v85.Text = "Play"
v85.TextColor3 = v13.Text
v85.Font = Enum.Font.GothamBold
v85.TextSize = 12
v85.Parent = v32

local v86 = Instance.new("UICorner")
v86.CornerRadius = UDim.new(0, 4)
v86.Parent = v85

local v87 = Instance.new("TextButton")
v87.Name = "StopBtn"
v87.Size = UDim2.new(0.5, -16, 0, 28)
v87.Position = UDim2.new(0.5, 4, 0, 515)
v87.BackgroundColor3 = v13.Danger
v87.BorderSizePixel = 0
v87.Text = "Stop"
v87.TextColor3 = v13.Text
v87.Font = Enum.Font.GothamBold
v87.TextSize = 12
v87.Parent = v32

local v88 = Instance.new("UICorner")
v88.CornerRadius = UDim.new(0, 4)
v88.Parent = v87

v85.MouseButton1Click:Connect(function()
    local v89 = tonumber(v83.Text)
    if not v89 then
        v35("Invalid Emote ID", v13.Danger)
        return
    end

    local v90 = v7.Character
    if not v90 then return end
    local v91 = v90:FindFirstChildOfClass("Humanoid")
    if not v91 then return end

    local v92 = Instance.new("Animation")
    v92.AnimationId = "rbxassetid://" .. tostring(v89)

    local v93, v94 = pcall(function()
        return v91:LoadAnimation(v92)
    end)

    if v93 and v94 then
        v94:Play()
        v94:AdjustWeight(1)
        table.insert(v12, v94)
        v35("Playing emote " .. tostring(v89), v13.Success)
    else
        v35("Failed to load emote", v13.Danger)
    end
end)

v87.MouseButton1Click:Connect(function()
    local v95 = v7.Character
    if not v95 then return end
    local v96 = v95:FindFirstChildOfClass("Humanoid")
    if not v96 then return end

    pcall(function()
        for _, v97 in ipairs(v96:GetPlayingAnimationTracks()) do
            v97:Stop()
        end
    end)
    v12 = {}
    v35("Stopped all emotes", v13.Success)
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        local v98 = v7.Character
        if v98 then
            local v99 = v98:FindFirstChild("Animate")
            if v99 then
                local v100 = v99:FindFirstChild("idle")
                if not v100 then
                    pcall(function()
                        v99:FindFirstChild("idle")
                    end)
                end
            end
        end
    end
end)

v7.CharacterAdded:Connect(function(v101)
    v9 = v101
    v10 = v101:WaitForChild("Humanoid")
end)
