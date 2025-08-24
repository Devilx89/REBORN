local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Vgxmod X PetaPeta Chapter 2",
    SubTitle = "by Pkgx1",
    TabWidth = 160,
    Size = UDim2.fromOffset(470, 260),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),
    Main = Window:AddTab({ Title = "Main", Icon = "layout-dashboard" }),
    Esp = Window:AddTab({ Title = "Esp", Icon = "eye" }),    
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),    
}

Tabs.Info:AddParagraph({
    Title = "Welcome to Vgxmod",
    Content = "Kindly Request Script"
})

Tabs.Info:AddButton({
    Title = "Discord",
    Description = "",
    Callback = function()
        setclipboard("https://discord.gg/n9gtmefsjc")
        Fluent:Notify({
            Title = "Vgxmod X Hub",
            Content = "Discord Link",
            SubContent = "Link copied to clipboard! Paste it in your browser.",
            Duration = 5
        })
    end
})













getgenv().InstantPromptEnabled = getgenv().InstantPromptEnabled or false

local function setInstant(prompt)
    if prompt:IsA("ProximityPrompt") then
        prompt.HoldDuration = 0
    end
end

for _, prompt in ipairs(workspace:GetDescendants()) do
    setInstant(prompt)
end

workspace.DescendantAdded:Connect(function(prompt)
    setInstant(prompt)
end)

local toggle = Tabs.Main:AddToggle("InstantPromptToggle", {
    Title = "Instant Prompt",
    Default = getgenv().InstantPromptEnabled,
    Callback = function(state)
        getgenv().InstantPromptEnabled = state
        if state then
            for _, prompt in ipairs(workspace:GetDescendants()) do
                setInstant(prompt)
            end
        end
    end
})












local toggle = Tabs.Esp:AddToggle("ItemESP", {
    Title = "ESP Item",
    Default = false
})


local function runItemESP()
    if getgenv().ItemESP_Running then return end
    getgenv().ItemESP_Running = true

    local SETTINGS = getgenv().ItemESP_Settings or {
        Color = Color3.fromRGB(80, 255, 80),
        Offset = Vector3.new(0, 2, 0),
        Size = UDim2.new(0, 150, 0, 40),
        ShowDistance = true
    }
    getgenv().ItemESP_Settings = SETTINGS

    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")

    local server = Workspace:WaitForChild("Server")
    local itemFolder = server:WaitForChild("SpawnedItems")

    local Tracked = {} -- [Instance] = {bb, conns}

    local function getAttachPart(obj)
        if obj:IsA("BasePart") then return obj
        elseif obj:IsA("Model") then return obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") end
    end

    local function removeESP(obj)
        local t = Tracked[obj]
        if not t then return end
        for _,c in ipairs(t.conns) do pcall(function() c:Disconnect() end) end
        if t.bb then t.bb:Destroy() end
        Tracked[obj] = nil
    end

    local function ensureESP(obj)
        if Tracked[obj] then return end
        local part = getAttachPart(obj)
        if not part or part:FindFirstChild("ItemESP") then return end

        local bb = Instance.new("BillboardGui")
        bb.Name = "ItemESP"
        bb.AlwaysOnTop = true
        bb.Size = SETTINGS.Size
        bb.StudsOffset = SETTINGS.Offset
        bb.Parent = part

        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextScaled = true
        lbl.TextStrokeTransparency = 0
        lbl.TextColor3 = SETTINGS.Color
        lbl.Text = obj.Name
        lbl.Parent = bb

        local conns = {}
        conns[#conns+1] = RunService.RenderStepped:Connect(function()
            if not obj.Parent or not part.Parent then return end
            if SETTINGS.ShowDistance then
                local cam = Workspace.CurrentCamera
                local dist = (cam.CFrame.Position - part.Position).Magnitude
                lbl.Text = string.format("%s (%.0f)", obj.Name, dist)
            else
                lbl.Text = obj.Name
            end
        end)
        conns[#conns+1] = obj.AncestryChanged:Connect(function(_, parent)
            if not parent then removeESP(obj) end
        end)

        Tracked[obj] = {bb = bb, conns = conns}
    end


    for _,child in ipairs(itemFolder:GetChildren()) do
        if child:IsA("Model") or child:IsA("BasePart") then
            ensureESP(child)
        end
    end

    -- New items
    itemFolder.ChildAdded:Connect(function(child)
        if child:IsA("Model") or child:IsA("BasePart") then
            task.delay(0.5, function()
                ensureESP(child)
            end)
        end
    end)

    getgenv().ItemESP_Tracked = Tracked
    print("[ItemESP] running for workspace.Server.SpawnedItems")
end


local function removeItemESP()
    local Tracked = getgenv().ItemESP_Tracked
    if Tracked then
        for obj,t in pairs(Tracked) do
            if t.bb then t.bb:Destroy() end
            for _,c in ipairs(t.conns) do pcall(function() c:Disconnect() end) end
        end
        getgenv().ItemESP_Tracked = nil
        getgenv().ItemESP_Running = false
        print("[ItemESP] removed")
    end
end


toggle:OnChanged(function(value)
    if value then
        runItemESP()
    else
        removeItemESP()
    end
end)











local toggle = Tabs.Esp:AddToggle("EnemyHighlightESP", {
    Title = "ESP Highlights Monster",
    Default = false
})

local Workspace = game:GetService("Workspace")

local function highlightObject(obj, color)
    if obj:FindFirstChild("EnemyESP") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "EnemyESP"
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = obj
end

local function scanFolder(folder, color)
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            highlightObject(obj, color)
        end
    end
    local conn
    conn = folder.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") or obj:IsA("Model") then
            highlightObject(obj, color)
        end
    end)
    return conn
end

local connections = {}

local function runESP()
    if getgenv().EnemyHighlightESP_Running then return end
    getgenv().EnemyHighlightESP_Running = true

    local enemyFolder = Workspace:WaitForChild("Client"):WaitForChild("Enemy")
    local clientEnemyFolder = enemyFolder:WaitForChild("ClientEnemy"):WaitForChild("EnemyModel")

    connections[#connections+1] = scanFolder(enemyFolder, Color3.fromRGB(255, 0, 0))
    connections[#connections+1] = scanFolder(clientEnemyFolder, Color3.fromRGB(255, 100, 0))
end

local function stopESP()
    if connections then
        for _, conn in ipairs(connections) do
            if conn and conn.Disconnect then
                conn:Disconnect()
            end
        end
        connections = {}
    end
    getgenv().EnemyHighlightESP_Running = false
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:FindFirstChild("EnemyESP") then
            obj.EnemyESP:Destroy()
        end
    end
end

toggle:OnChanged(function(value)
    if value then
        runESP()
    else
        stopESP()
    end
end)







local toggle = Tabs.Esp:AddToggle("EnemyNotifier", {
    Title = "Monster Spawn Notifier",
    Default = false
})

local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Enemy Update",
            Text = msg,
            Duration = 5
        })
    end)
end

local function runNotifier()
    if getgenv().ClientEnemyNotifier then return end
    getgenv().ClientEnemyNotifier = true

    local clientFolder = Workspace:WaitForChild("Client")
    local enemyFolder = clientFolder:WaitForChild("Enemy")
    local Notified = {}

    local heartbeat
    heartbeat = RunService.Heartbeat:Connect(function()
        for _,child in ipairs(enemyFolder:GetChildren()) do
            if not Notified[child] then
                Notified[child] = true
                notify(child.Name .. " has spawned!")
            end
        end

        for enemy,_ in pairs(Notified) do
            if not enemy.Parent then
                notify(enemy.Name .. " has despawned!")
                Notified[enemy] = nil
            end
        end
    end)

    getgenv().ClientEnemyNotifierHeartbeat = heartbeat
end

local function stopNotifier()
    if getgenv().ClientEnemyNotifierHeartbeat then
        getgenv().ClientEnemyNotifierHeartbeat:Disconnect()
        getgenv().ClientEnemyNotifierHeartbeat = nil
        getgenv().ClientEnemyNotifier = false
    end
end

toggle:OnChanged(function(value)
    if value then
        runNotifier()
    else
        stopNotifier()
    end
end)











getgenv().TpwalkSpeed = getgenv().TpwalkSpeed or 10
getgenv().TpwalkEnabled = getgenv().TpwalkEnabled or false

local speedToggle = Tabs.Player:AddToggle("TpwalkToggle", {
    Title = "Sprint",
    Default = getgenv().TpwalkEnabled,
    Callback = function(state)
        getgenv().TpwalkEnabled = state
    end
})

local speedInput = Tabs.Player:AddInput("TpwalkSpeedInput", {
    Title = "Set Speed",
    Default = tostring(getgenv().TpwalkSpeed),
    Numeric = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            getgenv().TpwalkSpeed = num
        end
    end
})

game:GetService("RunService").Heartbeat:Connect(function(delta)
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if getgenv().TpwalkEnabled and char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
        local hrp = char.HumanoidRootPart
        local hum = char.Humanoid
        local dir = hum.MoveDirection
        if dir.Magnitude > 0 then
            local newPos = hrp.Position + dir.Unit * getgenv().TpwalkSpeed * delta
            hrp.CFrame = CFrame.new(newPos, newPos + hrp.CFrame.LookVector)
        end
    end
end)




-- Initialize getgenv
getgenv().FullBright_Enabled = getgenv().FullBright_Enabled or false
getgenv().FullBright_Original = getgenv().FullBright_Original or {}

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Save original settings once
if not getgenv().FullBright_Original.Sky then
    local sky = Lighting:FindFirstChildOfClass("Sky")
    getgenv().FullBright_Original.Sky = sky and sky:Clone() or nil
end
if not getgenv().FullBright_Original.Ambient then
    getgenv().FullBright_Original.Ambient = Lighting.Ambient
end
if not getgenv().FullBright_Original.OutdoorAmbient then
    getgenv().FullBright_Original.OutdoorAmbient = Lighting.OutdoorAmbient
end
if not getgenv().FullBright_Original.Brightness then
    getgenv().FullBright_Original.Brightness = Lighting.Brightness
end
if not getgenv().FullBright_Original.ClockTime then
    getgenv().FullBright_Original.ClockTime = Lighting.ClockTime
end

-- Apply FullBright
local function applyFullBright()
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.ClockTime = 14
    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky") then obj:Destroy() end
    end
end

-- Restore original lighting
local function restoreLighting()
    Lighting.Brightness = getgenv().FullBright_Original.Brightness
    Lighting.Ambient = getgenv().FullBright_Original.Ambient
    Lighting.OutdoorAmbient = getgenv().FullBright_Original.OutdoorAmbient
    Lighting.ClockTime = getgenv().FullBright_Original.ClockTime
    if getgenv().FullBright_Original.Sky then
        if not Lighting:FindFirstChildOfClass("Sky") then
            getgenv().FullBright_Original.Sky:Clone().Parent = Lighting
        end
    end
end

-- Heartbeat connection to enforce FullBright
if getgenv().FullBright_Connection then
    getgenv().FullBright_Connection:Disconnect()
end

getgenv().FullBright_Connection = RunService.RenderStepped:Connect(function()
    if getgenv().FullBright_Enabled then
        applyFullBright()
    end
end)

-- Handle respawn
player.CharacterAdded:Connect(function()
    if getgenv().FullBright_Enabled then
        -- wait for character to load completely
        task.wait(0.5)
        applyFullBright()
    end
end)

-- GUI Toggle
local toggle = Tabs.Player:AddToggle("FullBrightToggle", {
    Title = "Full Brightness",
    Default = getgenv().FullBright_Enabled,
    Callback = function(state)
        getgenv().FullBright_Enabled = state
        if not state then
            restoreLighting()
        else
            applyFullBright()
        end
    end
})



Window:SelectInfo(1)
