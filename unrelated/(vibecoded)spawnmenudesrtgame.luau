local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local objects2026 = replicatedStorage:FindFirstChild("2026")
local buildings = replicatedStorage:FindFirstChild("buildings")
local items = replicatedStorage:FindFirstChild("items")

if not objects2026 or not buildings or not items then
    print("2026, buildings, or items not found")
    return
end

local sandbox = replicatedStorage:FindFirstChild("sandboxconnection")
if not sandbox then
    print("sandboxconnection not found")
    return
end

local spawnRemote = sandbox:FindFirstChild("spawnobject")
if not spawnRemote then
    print("spawnobject not found")
    return
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpawnMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 450)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60, 60, 80)
Stroke.Thickness = 1.5
Stroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Spawn Menu"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize, Title.Font = 18, Enum.Font.GothamBold
Title.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(0.9, 0, 0, 34)
SearchBar.Position = UDim2.new(0.05, 0, 0, 48)
SearchBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
SearchBar.PlaceholderText = "Search..."
SearchBar.PlaceholderColor3 = Color3.fromRGB(150, 150, 180)
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBar.TextSize, SearchBar.Font = 13, Enum.Font.GothamMedium
SearchBar.ClearTextOnFocus = false
SearchBar.Parent = MainFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBar

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 30)
TabContainer.Position = UDim2.new(0, 10, 0, 88)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainFrame

local Tab2026 = Instance.new("TextButton")
Tab2026.Size = UDim2.new(0, 70, 1, 0)
Tab2026.Position = UDim2.new(0, 0, 0, 0)
Tab2026.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
Tab2026.Text = "2026"
Tab2026.TextColor3 = Color3.fromRGB(255, 255, 255)
Tab2026.TextSize, Tab2026.Font = 12, Enum.Font.GothamMedium
Tab2026.Parent = TabContainer

local Tab2026Corner = Instance.new("UICorner")
Tab2026Corner.CornerRadius = UDim.new(0, 6)
Tab2026Corner.Parent = Tab2026

local TabBuildings = Instance.new("TextButton")
TabBuildings.Size = UDim2.new(0, 70, 1, 0)
TabBuildings.Position = UDim2.new(0, 75, 0, 0)
TabBuildings.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabBuildings.Text = "Buildings"
TabBuildings.TextColor3 = Color3.fromRGB(180, 180, 200)
TabBuildings.TextSize, TabBuildings.Font = 12, Enum.Font.GothamMedium
TabBuildings.Parent = TabContainer

local TabBuildingsCorner = Instance.new("UICorner")
TabBuildingsCorner.CornerRadius = UDim.new(0, 6)
TabBuildingsCorner.Parent = TabBuildings

local TabItems = Instance.new("TextButton")
TabItems.Size = UDim2.new(0, 70, 1, 0)
TabItems.Position = UDim2.new(0, 150, 0, 0)
TabItems.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabItems.Text = "Items"
TabItems.TextColor3 = Color3.fromRGB(180, 180, 200)
TabItems.TextSize, TabItems.Font = 12, Enum.Font.GothamMedium
TabItems.Parent = TabContainer

local TabItemsCorner = Instance.new("UICorner")
TabItemsCorner.CornerRadius = UDim.new(0, 6)
TabItemsCorner.Parent = TabItems

local TabExtras = Instance.new("TextButton")
TabExtras.Size = UDim2.new(0, 70, 1, 0)
TabExtras.Position = UDim2.new(0, 225, 0, 0)
TabExtras.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TabExtras.Text = "Extras"
TabExtras.TextColor3 = Color3.fromRGB(180, 180, 200)
TabExtras.TextSize, TabExtras.Font = 12, Enum.Font.GothamMedium
TabExtras.Parent = TabContainer

local TabExtrasCorner = Instance.new("UICorner")
TabExtrasCorner.CornerRadius = UDim.new(0, 6)
TabExtrasCorner.Parent = TabExtras

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -20, 1, -140)
ContentContainer.Position = UDim2.new(0, 10, 0, 125)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainFrame

local Panel2026 = Instance.new("Frame")
Panel2026.Size = UDim2.new(1, 0, 1, 0)
Panel2026.BackgroundTransparency = 1
Panel2026.Visible = true
Panel2026.Parent = ContentContainer

local PanelBuildings = Instance.new("Frame")
PanelBuildings.Size = UDim2.new(1, 0, 1, 0)
PanelBuildings.BackgroundTransparency = 1
PanelBuildings.Visible = false
PanelBuildings.Parent = ContentContainer

local PanelItems = Instance.new("Frame")
PanelItems.Size = UDim2.new(1, 0, 1, 0)
PanelItems.BackgroundTransparency = 1
PanelItems.Visible = false
PanelItems.Parent = ContentContainer

local PanelExtras = Instance.new("Frame")
PanelExtras.Size = UDim2.new(1, 0, 1, 0)
PanelExtras.BackgroundTransparency = 1
PanelExtras.Visible = false
PanelExtras.Parent = ContentContainer

local Scroll2026 = Instance.new("ScrollingFrame")
Scroll2026.Size = UDim2.new(1, 0, 1, 0)
Scroll2026.BackgroundTransparency = 1
Scroll2026.BorderSizePixel = 0
Scroll2026.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll2026.ScrollBarThickness = 4
Scroll2026.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
Scroll2026.Parent = Panel2026

local List2026 = Instance.new("UIListLayout")
List2026.SortOrder = Enum.SortOrder.LayoutOrder
List2026.Padding = UDim.new(0, 6)
List2026.Parent = Scroll2026

local ScrollBuildings = Instance.new("ScrollingFrame")
ScrollBuildings.Size = UDim2.new(1, 0, 1, 0)
ScrollBuildings.BackgroundTransparency = 1
ScrollBuildings.BorderSizePixel = 0
ScrollBuildings.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollBuildings.ScrollBarThickness = 4
ScrollBuildings.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
ScrollBuildings.Parent = PanelBuildings

local ListBuildings = Instance.new("UIListLayout")
ListBuildings.SortOrder = Enum.SortOrder.LayoutOrder
ListBuildings.Padding = UDim.new(0, 6)
ListBuildings.Parent = ScrollBuildings

local ScrollItems = Instance.new("ScrollingFrame")
ScrollItems.Size = UDim2.new(1, 0, 1, 0)
ScrollItems.BackgroundTransparency = 1
ScrollItems.BorderSizePixel = 0
ScrollItems.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollItems.ScrollBarThickness = 4
ScrollItems.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
ScrollItems.Parent = PanelItems

local ListItems = Instance.new("UIListLayout")
ListItems.SortOrder = Enum.SortOrder.LayoutOrder
ListItems.Padding = UDim.new(0, 6)
ListItems.Parent = ScrollItems

local ScrollExtras = Instance.new("ScrollingFrame")
ScrollExtras.Size = UDim2.new(1, 0, 1, 0)
ScrollExtras.BackgroundTransparency = 1
ScrollExtras.BorderSizePixel = 0
ScrollExtras.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollExtras.ScrollBarThickness = 4
ScrollExtras.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
ScrollExtras.Parent = PanelExtras

local ListExtras = Instance.new("UIListLayout")
ListExtras.SortOrder = Enum.SortOrder.LayoutOrder
ListExtras.Padding = UDim.new(0, 6)
ListExtras.Parent = ScrollExtras

local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function spawnObject(folder, objName)
    local obj = folder:FindFirstChild(objName)
    if not obj then return end
    
    local data = {
        color = Color3.new(1, 1, 1),
        ammo = "",
        grade = 100,
        fluids = {}
    }
    
    spawnRemote:InvokeServer(obj, data)
end

local function createObjectButton(folder, panel, objName, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 45)
    btn.Text = objName
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize, btn.Font = 13, Enum.Font.GothamMedium
    btn.Parent = panel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = color and Color3.fromRGB(color.R*1.5, color.G*1.5, color.B*1.5) or Color3.fromRGB(55, 55, 75)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 45)
    end)
    
    btn.MouseButton1Click:Connect(function()
        spawnObject(folder, objName)
        print("spawned: " .. objName)
    end)
end

local function updatePanel(panel, folder, color)
    for _, child in ipairs(panel:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local searchText = string.lower(SearchBar.Text or "")
    local count = 0
    
    for _, obj in ipairs(folder:GetChildren()) do
        if searchText == "" or string.lower(obj.Name):find(searchText) then
            createObjectButton(folder, panel, obj.Name, color)
            count = count + 1
        end
    end
    
    panel.CanvasSize = UDim2.new(0, 0, 0, count * 44 + 10)
end

local extrasList = {
    "AK-47",
    "Keyboard",
    "Model",
    "bridge",
    "engine2",
    "h",
    "hood",
    "lightingbolts",
    "pillar",
    "pillarphysical",
    "ramp",
    "scraps",
    "speedbump",
    "test2",
    "toplace",
    "tree",
    "tumbleweed",
    "viewmodel",
    "viewmodel2"
}

local function updateExtrasPanel()
    for _, child in ipairs(ScrollExtras:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local searchText = string.lower(SearchBar.Text or "")
    local count = 0
    
    for _, objName in ipairs(extrasList) do
        if searchText == "" or string.lower(objName):find(searchText) then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(55, 45, 35)
            btn.Text = objName
            btn.TextColor3 = Color3.fromRGB(255, 200, 200)
            btn.TextSize, btn.Font = 13, Enum.Font.GothamMedium
            btn.Parent = ScrollExtras
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(75, 55, 45)
            end)
            
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(55, 45, 35)
            end)
            
            btn.MouseButton1Click:Connect(function()
                local obj = replicatedStorage:FindFirstChild(objName)
                if obj then
                    local data = {
                        color = Color3.new(1, 1, 1),
                        ammo = "",
                        grade = 100,
                        fluids = {}
                    }
                    spawnRemote:InvokeServer(obj, data)
                    print("spawned: " .. objName)
                else
                    print(objName .. " not found in ReplicatedStorage")
                end
            end)
            
            count = count + 1
        end
    end
    
    ScrollExtras.CanvasSize = UDim2.new(0, 0, 0, count * 44 + 10)
end

Tab2026.MouseButton1Click:Connect(function()
    Tab2026.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Tab2026.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBuildings.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBuildings.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabItems.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabItems.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabExtras.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabExtras.TextColor3 = Color3.fromRGB(180, 180, 200)
    Panel2026.Visible = true
    PanelBuildings.Visible = false
    PanelItems.Visible = false
    PanelExtras.Visible = false
    updatePanel(Scroll2026, objects2026, Color3.fromRGB(35, 45, 55))
end)

TabBuildings.MouseButton1Click:Connect(function()
    TabBuildings.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TabBuildings.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2026.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Tab2026.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabItems.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabItems.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabExtras.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabExtras.TextColor3 = Color3.fromRGB(180, 180, 200)
    PanelBuildings.Visible = true
    Panel2026.Visible = false
    PanelItems.Visible = false
    PanelExtras.Visible = false
    updatePanel(ScrollBuildings, buildings, Color3.fromRGB(45, 55, 35))
end)

TabItems.MouseButton1Click:Connect(function()
    TabItems.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TabItems.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2026.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Tab2026.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabBuildings.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBuildings.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabExtras.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabExtras.TextColor3 = Color3.fromRGB(180, 180, 200)
    PanelItems.Visible = true
    Panel2026.Visible = false
    PanelBuildings.Visible = false
    PanelExtras.Visible = false
    updatePanel(ScrollItems, items, Color3.fromRGB(55, 35, 45))
end)

TabExtras.MouseButton1Click:Connect(function()
    TabExtras.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    TabExtras.TextColor3 = Color3.fromRGB(255, 255, 255)
    Tab2026.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Tab2026.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabBuildings.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabBuildings.TextColor3 = Color3.fromRGB(180, 180, 200)
    TabItems.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabItems.TextColor3 = Color3.fromRGB(180, 180, 200)
    PanelExtras.Visible = true
    Panel2026.Visible = false
    PanelBuildings.Visible = false
    PanelItems.Visible = false
    updateExtrasPanel()
end)

SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
    if Panel2026.Visible then
        updatePanel(Scroll2026, objects2026, Color3.fromRGB(35, 45, 55))
    elseif PanelBuildings.Visible then
        updatePanel(ScrollBuildings, buildings, Color3.fromRGB(45, 55, 35))
    elseif PanelItems.Visible then
        updatePanel(ScrollItems, items, Color3.fromRGB(55, 35, 45))
    elseif PanelExtras.Visible then
        updateExtrasPanel()
    end
end)

updatePanel(Scroll2026, objects2026, Color3.fromRGB(35, 45, 55))
print("Spawn Menu loaded")
