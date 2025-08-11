local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Vgxmod X The Butchery",
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





local Section = Tabs.Main:AddSection("OP / INSTANT")
    -- Instant End Button
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Change "Tabs.Main" if your tab variable is different
local GardenButton = Tabs.Main:AddButton({
    Title = "Instant End",
    Description = "Ending instantly",
    Callback = function()
        local trigger = workspace:FindFirstChild("_Triggers")
            and workspace._Triggers:FindFirstChild("GardenEndingTrigger")
        
        if trigger then
            local touchInterest = trigger:FindFirstChild("TouchInterest", true) -- search inside
            if touchInterest then
                -- Try to simulate touch by moving player's HRP
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local oldCFrame = hrp.CFrame
                    hrp.CFrame = trigger.CFrame -- teleport to trigger
                    task.wait(0.1)
                    hrp.CFrame = oldCFrame
                    print("[Instant End] Garden Ending Triggered")
                end
            else
                warn("[Instant End] TouchInterest not found in GardenEndingTrigger")
            end
        else
            warn("[Instant End] GardenEndingTrigger not found")
        end
    end
})







local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Store triggers dynamically
local triggerList = {}
for _, obj in ipairs(workspace:WaitForChild("_Triggers"):GetChildren()) do
    if obj:IsA("BasePart") then
        table.insert(triggerList, obj.Name)
    end
end

-- Drop-down for trigger selection
local selectedTrigger
local triggerDropdown = Tabs.Main:AddDropdown("TriggerSelect", {
    Title = "Select Trigger",
    Values = triggerList,
    Multi = false,
    Default = nil
})

triggerDropdown:OnChanged(function(value)
    selectedTrigger = value
end)

-- Button to fire selected trigger
Tabs.Main:AddButton({
    Title = "Activate Selected Trigger",
    Description = "Teleport and trigger instantly",
    Callback = function()
        if not selectedTrigger then
            warn("[Trigger ESP] No trigger selected!")
            return
        end

        local trigger = workspace._Triggers:FindFirstChild(selectedTrigger)
        if trigger and trigger:IsA("BasePart") then
            local touchInterest = trigger:FindFirstChild("TouchInterest", true)
            if touchInterest then
                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local oldCFrame = hrp.CFrame
                    hrp.CFrame = trigger.CFrame
                    task.wait(0.1)
                    hrp.CFrame = oldCFrame
                    print("[Trigger ESP] Activated:", selectedTrigger)
                end
            else
                warn("[Trigger ESP] TouchInterest not found inside:", selectedTrigger)
            end
        else
            warn("[Trigger ESP] Trigger not found:", selectedTrigger)
        end
    end
})

-- Auto update dropdown when new triggers appear
workspace._Triggers.ChildAdded:Connect(function(child)
    if child:IsA("BasePart") then
        table.insert(triggerList, child.Name)
        triggerDropdown:SetValues(triggerList)
    end
end)

workspace._Triggers.ChildRemoved:Connect(function(child)
    for i, name in ipairs(triggerList) do
        if name == child.Name then
            table.remove(triggerList, i)
            break
        end
    end
    triggerDropdown:SetValues(triggerList)
end)



local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Toggle state
local freezeEnabled = false

-- Create the toggle in the "Main" tab
Tabs.Main:AddToggle("Freeze All Monsters", {
    Title = "Freeze All Monsters",
    Default = false,
    Callback = function(state)
        freezeEnabled = state
    end
})

-- Loop to handle freezing
task.spawn(function()
    while true do
        if freezeEnabled then
            for _, monster in pairs(workspace._Characters:GetChildren()) do
                if monster:FindFirstChild("Humanoid") and monster.Name ~= LocalPlayer.Name then
                    monster.Humanoid.WalkSpeed = 0
                    if monster:FindFirstChild("HumanoidRootPart") then
                        monster.HumanoidRootPart.Anchored = true
                    end
                end
            end
        else
            for _, monster in pairs(workspace._Characters:GetChildren()) do
                if monster:FindFirstChild("Humanoid") and monster.Name ~= LocalPlayer.Name then
                    if monster.Humanoid.WalkSpeed == 0 then
                        monster.Humanoid.WalkSpeed = 16 -- default walk speed
                    end
                    if monster:FindFirstChild("HumanoidRootPart") then
                        monster.HumanoidRootPart.Anchored = false
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)




local Section = Tabs.Esp:AddSection("ESP / PLAYER")




local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local PLAYER_TAG_NAME = "PlayerESPTag"
local PLAYER_HL_NAME  = "PlayerESPHighlight"

local playerESPEnabled = false
local playerESPConnection

-- Billboard name tag
local function makeBillboard(displayText)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = PLAYER_TAG_NAME
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 120, 0, 25)
    billboard.StudsOffset = Vector3.new(0, 3, 0)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = displayText
    label.TextColor3 = Color3.fromRGB(255, 255, 0) -- yellow
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = billboard

    return billboard
end

-- Highlight (yellow outline only)
local function makeHighlight(model)
    local hl = Instance.new("Highlight")
    hl.Name = PLAYER_HL_NAME
    hl.FillTransparency = 1
    hl.OutlineTransparency = 0
    hl.OutlineColor = Color3.fromRGB(255, 255, 0) -- yellow
    hl.Parent = model
end

-- Apply ESP to player
local function attachPlayerESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart

        if not hrp:FindFirstChild(PLAYER_TAG_NAME) then
            local tag = makeBillboard(player.Name)
            tag.Adornee = hrp
            tag.Parent = hrp
        end

        if not char:FindFirstChild(PLAYER_HL_NAME) then
            makeHighlight(char)
        end
    end
end

-- Remove ESP from player
local function removePlayerESP(player)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        local tag = hrp:FindFirstChild(PLAYER_TAG_NAME)
        if tag then tag:Destroy() end
    end
    if char then
        local hl = char:FindFirstChild(PLAYER_HL_NAME)
        if hl then hl:Destroy() end
    end
end

-- Update loop
local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if playerESPEnabled then
            attachPlayerESP(player)
        else
            removePlayerESP(player)
        end
    end
end

-- Toggle UI
Tabs.Esp:AddToggle("PlayerESP_Toggle", {
    Title = "Esp All Player",
    Default = false
}):OnChanged(function(state)
    playerESPEnabled = state
    if playerESPEnabled then
        updatePlayerESP()
        if not playerESPConnection then
            playerESPConnection = RunService.RenderStepped:Connect(updatePlayerESP)
        end
    else
        if playerESPConnection then
            playerESPConnection:Disconnect()
            playerESPConnection = nil
        end
        updatePlayerESP()
    end
end)

-- Keep updating for new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if playerESPEnabled then
            attachPlayerESP(player)
        end
    end)
end)



local Section = Tabs.Esp:AddSection("ESP / MONSTER")

-- Monster ESP (script #1)
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not Tabs or not Tabs.Esp then
    warn("[Monster ESP] Tabs.Esp not found. Make sure this runs where `Tabs` exists.")
    return
end

local CHAR_FOLDER = workspace:FindFirstChild("_Characters") or workspace:FindFirstChild("Characters") or workspace:WaitForChild("_Characters")
local MONSTER_TAG_NAME = "MonsterESP_NameTag"
local MONSTER_HL_NAME  = "MonsterESP_Highlight"

local monsterEnabled = false
local monsterLoop

local function createMonsterBillboard(text, color)
    local bg = Instance.new("BillboardGui")
    bg.Name = MONSTER_TAG_NAME
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 120, 0, 25)
    bg.StudsOffset = Vector3.new(0, 2.8, 0)
    bg.ResetOnSpawn = false

    local lbl = Instance.new("TextLabel")
    lbl.Name = "ESPLabel"
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lbl.TextColor3 = color or Color3.fromRGB(255,50,50)
    lbl.Text = text or "Monster"
    lbl.Parent = bg

    return bg
end

local function createMonsterHighlight(model, color)
    if not model then return end
    -- try to set PrimaryPart if missing (helps highlight)
    if model:IsA("Model") and not model.PrimaryPart then
        local p = model:FindFirstChildWhichIsA("BasePart")
        if p then model.PrimaryPart = p end
    end
    if model:FindFirstChild(MONSTER_HL_NAME) then
        local ex = model:FindFirstChild(MONSTER_HL_NAME)
        if ex and ex:IsA("Highlight") then ex.OutlineColor = color or Color3.fromRGB(255,50,50); return end
    end
    local ok, h = pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = MONSTER_HL_NAME
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = color or Color3.fromRGB(255,50,50)
        hl.Parent = model
        return hl
    end)
    if not ok then
        -- some models may not accept highlight; ignore
    end
end

local function attachMonsterESP(model)
    if not model or not model:IsA("Model") then return end
    -- skip local player's character
    if Players:GetPlayerFromCharacter(model) == LocalPlayer then return end

    local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not hrp then return end

    -- billboard
    if not hrp:FindFirstChild(MONSTER_TAG_NAME) then
        local bill = createMonsterBillboard(model.Name, Color3.fromRGB(255,50,50))
        bill.Adornee = hrp
        bill.Parent = hrp
    else
        local existing = hrp:FindFirstChild(MONSTER_TAG_NAME)
        local lbl = existing and existing:FindFirstChild("ESPLabel")
        if lbl then lbl.Text = model.Name end
    end

    -- highlight
    if not model:FindFirstChild(MONSTER_HL_NAME) then
        createMonsterHighlight(model, Color3.fromRGB(255,50,50))
    end
end

local function removeMonsterESP(model)
    if not model then return end
    local hrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if hrp then
        local t = hrp:FindFirstChild(MONSTER_TAG_NAME)
        if t then t:Destroy() end
    end
    local h = model:FindFirstChild(MONSTER_HL_NAME)
    if h then h:Destroy() end
end

local function updateMonsterLoop()
    for _, m in ipairs(CHAR_FOLDER:GetChildren()) do
        if monsterEnabled then
            attachMonsterESP(m)
        else
            removeMonsterESP(m)
        end
    end
end

-- Toggle (monster ESP)
local MonsterToggle = Tabs.Esp:AddToggle("MonsterESP_Toggle", {
    Title = "Esp All Monsters",
    Default = false
})

MonsterToggle:OnChanged(function(state)
    monsterEnabled = state
    if monsterEnabled then
        if not monsterLoop then
            monsterLoop = RunService.Heartbeat:Connect(updateMonsterLoop)
        end
        updateMonsterLoop()
    else
        if monsterLoop then monsterLoop:Disconnect(); monsterLoop = nil end
        updateMonsterLoop()
    end
end)

-- Child handlers to keep things snappy
CHAR_FOLDER.ChildAdded:Connect(function(c) if monsterEnabled then attachMonsterESP(c) end end)
CHAR_FOLDER.ChildRemoved:Connect(function(c) removeMonsterESP(c) end)





local Section = Tabs.Esp:AddSection("ESP / ITEM")

-- Item ESP (script #2)
local RunService = game:GetService("RunService")

if not Tabs or not Tabs.Esp then
    warn("[Item ESP] Tabs.Esp not found. Make sure this runs where `Tabs` exists.")
    return
end

local ITEM_FOLDER = workspace:FindFirstChild("_Items") or workspace:WaitForChild("_Items")
local ITEM_TAG_NAME = "ItemESP_NameTag"
local ITEM_HL_NAME  = "ItemESP_Highlight"

local itemEnabled = false
local itemLoop

local COLOR_MAP = {
    Key      = Color3.fromRGB(255, 165, 0),
    Tool     = Color3.fromRGB(0, 170, 255),
    Battery  = Color3.fromRGB(0, 255, 0),
    Weapon   = Color3.fromRGB(255, 0, 0),
    Ammo     = Color3.fromRGB(255, 255, 0),
    Medkit   = Color3.fromRGB(255, 105, 180),
}

local function nameHashColor(name)
    local h = 0
    for i = 1, #name do h = (h + string.byte(name,i) * i) % 256 end
    return Color3.fromRGB((h*97)%256, (h*57)%256, (h*27)%256)
end

local function getItemColor(name)
    for k,v in pairs(COLOR_MAP) do
        if string.find(string.lower(name or ""), string.lower(k)) then return v end
    end
    return nameHashColor(name or "item")
end

local function createItemBillboard(text, color)
    local bg = Instance.new("BillboardGui")
    bg.Name = ITEM_TAG_NAME
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 140, 0, 28)
    bg.StudsOffset = Vector3.new(0, 2.5, 0)
    bg.ResetOnSpawn = false

    local lbl = Instance.new("TextLabel")
    lbl.Name = "ESPLabel"
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    lbl.TextColor3 = color
    lbl.Text = text
    lbl.Parent = bg

    return bg
end

local function ensurePrimaryPart(model)
    if model and model:IsA("Model") and not model.PrimaryPart then
        local p = model:FindFirstChildWhichIsA("BasePart")
        if p then model.PrimaryPart = p end
    end
end

local function createItemHighlight(obj, hlName, color)
    if obj:IsA("Model") then ensurePrimaryPart(obj) end
    if obj:FindFirstChild(hlName) then
        local ex = obj:FindFirstChild(hlName)
        if ex and ex:IsA("Highlight") then ex.OutlineColor = color; return end
    end
    local ok, h = pcall(function()
        local hl = Instance.new("Highlight")
        hl.Name = hlName
        hl.FillTransparency = 1
        hl.OutlineTransparency = 0
        hl.OutlineColor = color
        hl.Parent = obj
        return hl
    end)
    if not ok then
        -- ignore
    end
end

local function attachItemESP(obj)
    if not obj then return end
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end

    local color = getItemColor(obj.Name or "Item")
    if obj:IsA("Model") then ensurePrimaryPart(obj) end
    local adorn = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if not adorn then return end

    if not adorn:FindFirstChild(ITEM_TAG_NAME) then
        local b = createItemBillboard(obj.Name or "Item", color)
        b.Adornee = adorn
        b.Parent = adorn
    else
        local existing = adorn:FindFirstChild(ITEM_TAG_NAME)
        local lbl = existing and existing:FindFirstChild("ESPLabel")
        if lbl then lbl.Text = obj.Name; lbl.TextColor3 = color end
    end

    if not obj:FindFirstChild(ITEM_HL_NAME) then
        createItemHighlight(obj, ITEM_HL_NAME, color)
    end
end

local function removeItemESP(obj)
    if not obj then return end
    local adorn = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if adorn then
        local t = adorn:FindFirstChild(ITEM_TAG_NAME)
        if t then t:Destroy() end
    end
    local h = obj:FindFirstChild(ITEM_HL_NAME)
    if h then h:Destroy() end
end

local function updateItemLoop()
    for _, o in ipairs(ITEM_FOLDER:GetChildren()) do
        if itemEnabled then
            attachItemESP(o)
        else
            removeItemESP(o)
        end
    end
end

-- Toggle (item ESP)
local ItemsToggle = Tabs.Esp:AddToggle("ItemsESP_Toggle", {
    Title = "Esp All Items",
    Default = false
})

ItemsToggle:OnChanged(function(state)
    itemEnabled = state
    if itemEnabled then
        if not itemLoop then
            itemLoop = RunService.Heartbeat:Connect(updateItemLoop)
        end
        updateItemLoop()
    else
        if itemLoop then itemLoop:Disconnect(); itemLoop = nil end
        updateItemLoop()
    end
end)

-- child handlers
ITEM_FOLDER.ChildAdded:Connect(function(c) if itemEnabled then attachItemESP(c) end end)
ITEM_FOLDER.ChildRemoved:Connect(function(c) removeItemESP(c) end)






local function disableMonsterDamage()
    for _, char in ipairs(workspace._Characters:GetChildren()) do
        local cowAI = char:FindFirstChild("CowAI")
        if cowAI then
            local dmg = cowAI:FindFirstChild("AttackDamage")
            if dmg and dmg:IsA("NumberValue") then
                dmg.Value = 0
            end
            local attacking = cowAI:FindFirstChild("Attacking")
            if attacking and attacking:IsA("BoolValue") then
                attacking.Value = false
            end
        end
    end
end

-- Keep disabling damage for any new monsters that spawn
workspace._Characters.ChildAdded:Connect(function(char)
    task.wait(0.1) -- wait to ensure CowAI is loaded
    disableMonsterDamage()
end)

-- Add the button to your "Main" tab
Tabs.Player:AddButton({
    Title = "God Mode",
    Description = "",
    Callback = function()
        disableMonsterDamage()
    end
})




local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local brightnessConnection
local brightnessOn = false

local function enableFullBright()
    if brightnessConnection then brightnessConnection:Disconnect() end
    brightnessConnection = RunService.RenderStepped:Connect(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14 -- midday
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end)
end

local function disableFullBright()
    if brightnessConnection then
        brightnessConnection:Disconnect()
        brightnessConnection = nil
    end
end

Tabs.Player:AddToggle("FullBright_Toggle", {
    Title = "Full Brightness",
    Default = false
}):OnChanged(function(state)
    brightnessOn = state
    if brightnessOn then
        enableFullBright()
    else
        disableFullBright()
    end
end)







Window:SelectInfo(1)