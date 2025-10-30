--================================================================--
--                    VGXMOD HUB - VIOLENCE DISTRICT
--        ESP + Hitbox + FOV + Third Person + Day Mode + More
--================================================================--

print("------------------------------------------------------------------")
print("Load ................................ Armor V3")
print("Load ................................ Vgxmod Hub")
print("------------------------------------------------------------------")

--================================================================--
-- LOAD LIBRARY (Vgxmod UI)
--================================================================--
local repo = "https://raw.githubusercontent.com/Devilx89/Jwuwekkeledkdndnd/main/"
local success, err = pcall(function()
    Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
    SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
end)

if not success then
    warn("Failed to load Vgxmod Hub libraries: " .. tostring(err))
    return
end

local Options = Library.Options
local Toggles = Library.Toggles

--================================================================--
-- CORE SERVICES
--================================================================--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--================================================================--
-- CONFIGURATION
--================================================================--
local DESIRED_FOV = 95
local DistanceCheck = 500

local espSettings = {
    Survivors  = {Enabled=false, Color=Color3.fromRGB(255,255,255)},  -- White
    Killers    = {Enabled=false, Color=Color3.fromRGB(255,0,0)},      -- Red
    Generators = {Enabled=false, Color=Color3.fromRGB(0,170,255)},    -- Light Blue
    Pallets    = {Enabled=false, Color=Color3.fromRGB(139,69,19)},    -- Brown
    ExitGates  = {Enabled=false, Color=Color3.fromRGB(0,255,0)},      -- Green
    Windows    = {Enabled=false, Color=Color3.fromRGB(0,255,255)},    -- Cyan
}

local playerHitboxes = {}
local hitboxEnabledAll = false
local headSize = 15
local hitboxTransparency = 0.9

--================================================================--
-- ITEM DISPLAY NAMES (Portuguese)
--================================================================--
local displayNames = {
    ["Motion Tracker"] = "Motion Tracker",
    ["Gate"] = "Gate",
    ["Flashlight"] = "Flashlight",
    ["Bandage"] = "Bandage",
    ["Parrying Dagger"] = "Parrying Dagger",
    ["Adrenaline Shot"] = "Adrenaline Shot",
    ["Shadow Clone"] = "Shadow Clone",
}

--================================================================--
-- GET SURVIVOR ITEM (Tool or Accessory)
--================================================================--
local function getSurvivorItem(player)
    if not player or not player.Character then return nil end
    for _, obj in pairs(player.Character:GetDescendants()) do
        if obj:IsA("Tool") or obj:IsA("Accessory") or obj:IsA("Model") then
            if displayNames[obj.Name] then
                return "("..displayNames[obj.Name]..")"
            end
        end
    end
    return nil
end

--================================================================--
-- TRACK OBJECTS (Generators, Pallets, Gates, Windows)
--================================================================--
local trackedObjects = {}

local function trackObject(obj)
    if not obj or not obj.Name then return end
    local n = obj.Name:lower()
    if n:find("generator") then trackedObjects[obj] = "Generators"
    elseif n:find("pallet") then trackedObjects[obj] = "Pallets"
    elseif n:find("gate") then trackedObjects[obj] = "ExitGates"
    elseif n:find("window") then trackedObjects[obj] = "Windows"
    end
end

-- Track existing objects
for _, v in ipairs(Workspace:GetDescendants()) do
    if v:IsA("Model") then trackObject(v) end
end

-- Track new objects
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Model") then trackObject(obj) end
end)

--================================================================--
-- GET PLAYER ROLE (Killer or Survivor)
--================================================================--
local function getRole(p)
    if p and p.Team and p.Team.Name then
        local n = p.Team.Name:lower()
        if n:find("killer") then return "Killer" end
        if n:find("survivor") then return "Survivor" end
    end
    return "Survivor"
end

--================================================================--
-- HIGHLIGHT (Chams)
--================================================================--
local function ensureHighlight(model, color)
    if not model then return end
    local hl = model:FindFirstChild("VD_HL")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "VD_HL"
        hl.Adornee = model
        hl.FillColor = color
        hl.FillTransparency = 0.7
        hl.OutlineColor = Color3.fromRGB(255,255,255)
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = model
    else
        hl.FillColor = color
        hl.OutlineColor = Color3.fromRGB(255,255,255)
    end
end

local function clearHighlight(model)
    if model and model:FindFirstChild("VD_HL") then
        model.VD_HL:Destroy()
    end
end

--================================================================--
-- ESP LABEL (Text Size = 10, Fixed)
--================================================================--
local function ensureLabel(model, text)
    if not model then return end
    local lbl = model:FindFirstChild("VD_Label")
    if not lbl then
        lbl = Instance.new("BillboardGui")
        lbl.Name = "VD_Label"
        lbl.Size = UDim2.new(0, 200, 0, 22)
        lbl.StudsOffset = Vector3.new(0, 4.5, 0)
        lbl.AlwaysOnTop = true
        lbl.MaxDistance = 500
        lbl.Parent = model

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextScaled = false
        textLabel.TextSize = 10
        textLabel.RichText = true
        textLabel.TextStrokeTransparency = 0.2
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.Text = text
        textLabel.FontFace = Font.new("rbxassetid://11702779517")
        textLabel.Parent = lbl
    else
        local textLabel = lbl:FindFirstChild("TextLabel")
        if textLabel then
            textLabel.FontFace = Font.new("rbxassetid://11702779517")
            textLabel.RichText = true
            textLabel.Text = text
        end
    end
end

local function clearLabel(model)
    if model and model:FindFirstChild("VD_Label") then
        model.VD_Label:Destroy()
    end
end

--================================================================--
-- GENERATOR PROGRESS & COLOR
--================================================================--
local function getGeneratorProgress(gen)
    if not gen then return 0 end
    local progress = 0
    if gen:GetAttribute("Progress") then
        progress = gen:GetAttribute("Progress")
    elseif gen:GetAttribute("RepairProgress") then
        progress = gen:GetAttribute("RepairProgress")
    else
        for _, child in ipairs(gen:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local n = child.Name:lower()
                if n:find("progress") or n:find("repair") or n:find("percent") then
                    progress = child.Value
                    break
                end
            end
        end
    end
    progress = (progress > 1) and progress / 100 or progress
    return math.clamp(progress, 0, 1)
end

local function getProgressColor(percent)
    local r = 255 * (1 - percent)
    local g = 255 * percent
    return Color3.fromRGB(r, g, 0)
end

local function generatorFinished(gen)
    return getGeneratorProgress(gen) >= 0.99 or gen:FindFirstChild("Finished") or gen:FindFirstChild("Repaired")
end

--================================================================--
-- FOV CONTROL
--================================================================--
local function applyFOV()
    if Camera and Camera.FieldOfView ~= DESIRED_FOV then
        Camera.FieldOfView = DESIRED_FOV
    end
end

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.wait(0.1)
    Camera = Workspace.CurrentCamera
end)

RunService.RenderStepped:Connect(applyFOV)

--================================================================--
-- HITBOX EXPANDER
--================================================================--
local function applyHitbox(player)
    if not hitboxEnabledAll then return end
    if getRole(player) ~= "Survivor" then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    playerHitboxes[player] = hrp
    hrp.Size = Vector3.new(headSize, headSize, headSize)
    hrp.Transparency = hitboxTransparency
    hrp.BrickColor = BrickColor.new("Really black")
    hrp.Material = Enum.Material.Neon
    hrp.CanCollide = false
end

local function removeHitbox(player)
    local hrp = playerHitboxes[player]
    if hrp and hrp.Parent then
        hrp.Size = Vector3.new(2,2,1)
        hrp.Transparency = 0
        hrp.BrickColor = BrickColor.new("Medium stone grey")
        hrp.Material = Enum.Material.Plastic
        hrp.CanCollide = true
        playerHitboxes[player] = nil
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LP then
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if hitboxEnabledAll and getRole(p) == "Survivor" then
                applyHitbox(p)
            end
        end)
        if hitboxEnabledAll and getRole(p) == "Survivor" then
            applyHitbox(p)
        end
    end
end

Players.PlayerRemoving:Connect(function(player)
    removeHitbox(player)
end)

RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            if hitboxEnabledAll then
                if getRole(p) == "Survivor" then
                    applyHitbox(p)
                else
                    removeHitbox(p)
                end
            else
                removeHitbox(p)
            end
        end
    end
end)

--================================================================--
-- UPDATE PLAYER ESP (Killer & Survivor)
--================================================================--
local function updatePlayersESP()
    local LPPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
    if not LPPos then return end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local role = getRole(p)
                local set = (role == "Killer") and espSettings.Killers or espSettings.Survivors
                if set and set.Enabled then
                    local dist = math.floor((hrp.Position - LPPos).Magnitude)
                    local labelText = "<font color='rgb("..math.floor(set.Color.R*255)..","..math.floor(set.Color.G*255)..","..math.floor(set.Color.B*255)..")'>"..p.DisplayName.."</font>"

                    if role == "Killer" then
                        -- Always show killer ESP, ignore distance
                        ensureHighlight(p.Character, set.Color)
                        labelText = labelText.." <font color='rgb(0,255,0)'>["..dist.."]</font>"
                        ensureLabel(p.Character, labelText)
                    else
                        local item = getSurvivorItem(p)
                        if item then
                            labelText = labelText.." <font color='rgb(255,255,0)'>"..item.."</font>"
                        end
                        ensureHighlight(p.Character, set.Color)
                        ensureLabel(p.Character, labelText)
                    end
                else
                    clearHighlight(p.Character)
                    clearLabel(p.Character)
                end
            end
        end
    end
end

--================================================================--
-- MAIN ESP LOOP (Objects + Players)
--================================================================--
RunService.Heartbeat:Connect(function()
    local LPPos = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character.HumanoidRootPart.Position
    if not LPPos then return end

    -- Update tracked objects (Gens, Pallets, etc.)
    for obj, typeName in pairs(trackedObjects) do
        if obj and obj.Parent then
            local set = espSettings[typeName]
            if set and set.Enabled then
                local hl = obj:FindFirstChild("VD_HL")
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "VD_HL"
                    hl.Adornee = obj
                    hl.FillTransparency = 1
                    hl.OutlineColor = set.Color
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = obj
                else
                    hl.OutlineColor = set.Color
                end

                if typeName == "Generators" then
                    local progress = getGeneratorProgress(obj)
                    local rootPart = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if rootPart then
                        local dist = math.floor((rootPart.Position - LPPos).Magnitude)
                        local percent = math.floor(progress * 100)
                        if percent == 0 and progress > 0 then percent = 1 end
                        local progColor = getProgressColor(progress)
                        local txt = string.format(
                            "<font color='rgb(255,255,255)'>Gen</font> <font color='rgb(200,200,200)'>(%d)</font> <font color='rgb(%d,%d,0)'>[%d%%]</font>",
                            dist,
                            math.floor(progColor.R*255), math.floor(progColor.G*255),
                            percent
                        )
                        ensureLabel(obj, txt)
                    else
                        clearLabel(obj)
                    end
                    if generatorFinished(obj) then
                        clearLabel(obj)
                    end
                else
                    clearLabel(obj)
                end
            else
                clearHighlight(obj)
                clearLabel(obj)
            end
        end
    end

    updatePlayersESP()
end)






--================================================================--
-- LOW GRAPHICS TOGGLE (FPS BOOST)
--================================================================--



local lowGraphicsEnabled = false
local originalMaterials = {}
local originalTransparencies = {}

local function applyLowGraphics()
    if lowGraphicsEnabled then return end
    lowGraphicsEnabled = true

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            originalMaterials[obj] = obj.Material
            obj.Material = Enum.Material.Plastic
        elseif (obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceGui")) and obj.Name ~= "face" then
            originalTransparencies[obj] = obj.Transparency
            obj.Transparency = 1
        end
    end

    -- Auto-apply to new objects
    Workspace.DescendantAdded:Connect(function(obj)
        if not lowGraphicsEnabled then return end
        if obj:IsA("BasePart") then
            originalMaterials[obj] = obj.Material
            obj.Material = Enum.Material.Plastic
        elseif (obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceGui")) and obj.Name ~= "face" then
            originalTransparencies[obj] = obj.Transparency
            obj.Transparency = 1
        end
    end)
end

local function restoreGraphics()
    lowGraphicsEnabled = false
    for obj, mat in pairs(originalMaterials) do
        if obj.Parent then
            obj.Material = mat
        end
    end
    for obj, trans in pairs(originalTransparencies) do
        if obj.Parent then
            obj.Transparency = trans
        end
    end
    originalMaterials = {}
    originalTransparencies = {}
end




--================================================================--
-- GUI: CREATE WINDOW
--================================================================--
local Window = Library:CreateWindow({
    Title = "Vgxmod Hub",
    Footer = "version: 1.6",
    Icon = 94858886314945,
    NotifySide = "Right",
    ShowCustomCursor = true,
})

--================================================================--
-- INFO TAB
--================================================================--
local InfoTab = Window:AddTab("Info", "info")
local InfoLeft = InfoTab:AddLeftGroupbox("Credits")
local InfoRight = InfoTab:AddRightGroupbox("Discord")

InfoLeft:AddLabel("Made By: Pkgx1")
InfoLeft:AddLabel("Discord: https://discord.gg/n9gtmefsjc")
InfoLeft:AddDivider()
InfoLeft:AddLabel("You Can Request Script")
InfoLeft:AddLabel("On Discord!")
InfoLeft:AddDivider()

InfoRight:AddLabel("Discord Link")
InfoRight:AddButton({
    Text = "Copy",
    Func = function()
        setclipboard("https://discord.gg/n9gtmefsjc")
        Library:Notify({Title = "Copied!", Description = "Paste it on your browser", Time = 4})
    end,
})

--================================================================--
-- MAIN TAB (Left: Killer | Right: ESP + Misc)
--================================================================--
local MainTab = Window:AddTab("Main", "house")

local KillerLeft = MainTab:AddLeftGroupbox("KILLER FEATURE", "skull")
local PlayerLeft = MainTab:AddLeftGroupbox("PLAYER FEATURE", "user")
local ESPRight = MainTab:AddRightGroupbox("ESP FEATURE", "eye")
local MiscRight = MainTab:AddRightGroupbox("MISC FEATURE", "settings")









--=== HITBOX (LEFT) ===
KillerLeft:AddToggle("HitboxAll", {
    Text = "Hitbox",
    Default = false,
    Callback = function(Value)
        hitboxEnabledAll = Value
        Library:Notify({Title = "Hitbox All Survivor", Description = Value and "Enabled" or "Disabled", Time = 2})
    end,
})

KillerLeft:AddSlider("HitboxSize", {
    Text = "Hitbox Size",
    Default = headSize,
    Min = 4,
    Max = 50,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        headSize = Value
        Library:Notify({Title = "Hitbox Size", Description = "Set to " .. Value .. " studs", Time = 2})
    end,
})

KillerLeft:AddSlider("HitboxTransparency", {
    Text = "Hitbox Transparency",
    Default = hitboxTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        hitboxTransparency = Value
        Library:Notify({Title = "Hitbox Transparency", Description = "Set to " .. Value, Time = 2})
    end,
})





KillerLeft:AddToggle("KillerThirdPerson", {
    Text = "Third Person (Killer)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            if getRole(LP) ~= "Killer" then
                Library:Notify({Title="Error", Description="Killer only!", Time=2})
                Toggles.KillerThirdPerson:Set(false)
                return
            end
            
            task.spawn(function()
                while Toggles.KillerThirdPerson.Value do
                    LP.CameraMode = Enum.CameraMode.Classic
                    LP.CameraMaxZoomDistance = 30
                    LP.CameraMinZoomDistance = 0.5
                    LP.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                    if Camera and Camera.FieldOfView ~= DESIRED_FOV then
                        Camera.FieldOfView = DESIRED_FOV
                    end

                    task.wait()
                end
            end)

            Library:Notify({Title="Third Person", Description="ON - Scroll to zoom", Time=3})
        else
            LP.CameraMode = Enum.CameraMode.LockFirstPerson
            Library:Notify({Title="Third Person", Description="OFF", Time=2})
        end
    end,
})

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if Toggles.KillerThirdPerson and Toggles.KillerThirdPerson.Value and getRole(LP) == "Killer" then
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMaxZoomDistance = 30
        LP.CameraMinZoomDistance = 0.5
    end
end)

KillerLeft:AddButton({
    Text = "Anti Blind",
    Func = function()
        local RS = game:GetService("ReplicatedStorage")
        local remote = RS:WaitForChild("Remotes"):WaitForChild("Items"):WaitForChild("Flashlight"):WaitForChild("GotBlinded")
        if remote and remote:IsA("RemoteEvent") then
            remote:Destroy()
        end
    end,
})





--=== Player (LEFT) ===




PlayerLeft:AddToggle("SpeedEnabled", {
Text = "Speed Boost",
Default = false,
Callback = function(Value)
espSettings.Windows.Enabled = Value
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

if Value then  
		local speeds = {18, 19, 20}  
		hum.WalkSpeed = speeds[Options.SpeedValue.Value]  
		hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()  
			if Toggles.SpeedEnabled.Value then  
				hum.WalkSpeed = speeds[Options.SpeedValue.Value]  
			end  
		end)  
	else  
		hum.WalkSpeed = 10  
	end  
end,

})

PlayerLeft:AddSlider("SpeedValue", {
Text = "Speed Level",
Default = 1,
Min = 1,
Max = 3,
Rounding = 0,
Callback = function(Value)
local speeds = {18, 19, 20}
if Toggles.SpeedEnabled.Value then
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
hum.WalkSpeed = speeds[Value]
end
end,
})



ESPRight:AddToggle("KillersESP", {
    Text = "Killers ESP",
    Default = espSettings.Killers.Enabled,
    Callback = function(Value)
        espSettings.Killers.Enabled = Value
        Library:Notify({Title = "Killers ESP", Description = Value and "Enabled" or "Disabled", Time = 2})
    end,
})

ESPRight:AddToggle("SurvivorsESP", {
    Text = "Survivors ESP",
    Default = espSettings.Survivors.Enabled,
    Callback = function(Value)
        espSettings.Survivors.Enabled = Value
        Library:Notify({Title = "Survivors ESP", Description = Value and "Enabled" or "Disabled", Time = 2})
    end,
})

--=== ESP TOGGLES (RIGHT) ===
ESPRight:AddToggle("GeneratorsESP", {
    Text = "Generators ESP",
    Default = espSettings.Generators.Enabled,
    Callback = function(Value)
        espSettings.Generators.Enabled = Value
        Library:Notify({Title = "Generators ESP", Description = Value and "Enabled" or "Disabled", Time = 2})
    end,
})


ESPRight:AddToggle("PalletsESP", {
    Text = "Pallets ESP",
    Default = espSettings.Pallets.Enabled,
    Callback = function(Value)
        espSettings.Pallets.Enabled = Value
        Library:Notify({Title = "Pallets ESP", Description = Value and "Enabled" or "Disabled", Time = 2})
    end,
})

ESPRight:AddToggle("ExitGatesESP", {
    Text = "Exit Gates ESP",
    Default = espSettings.ExitGates.Enabled,
    Callback = function(Value)
        espSettings.ExitGates.Enabled = Value
        Library:Notify({Title = "Exit Gates ESP", Description = Value and "Enabled" or "Disabled", Time = 2})
    end,
})

--[[
ESPRight:AddSlider("DistanceCheck", {
    Text = "Max Distance",
    Default = DistanceCheck,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Suffix = " studs",
    Callback = function(Value)
        DistanceCheck = Value
        Library:Notify({Title = "Max Distance", Description = "Set to " .. Value .. " studs", Time = 2})
    end,
})
]]
--=== MISC (RIGHT) ===
MiscRight:AddSlider("FOVSlider", {
    Text = "FOV",
    Default = DESIRED_FOV,
    Min = 70,
    Max = 150,
    Rounding = 0,
    Suffix = "°",
    Callback = function(Value)
        DESIRED_FOV = Value
        Library:Notify({Title = "FOV", Description = "Set to " .. Value .. "°", Time = 2})
    end,
})

MiscRight:AddButton({
    Text = "Day Mode",
    Func = function()
        local Lighting = game:GetService("Lighting")
        local function setDay()
            Lighting.TimeOfDay = "14:00:00"
            Lighting.ClockTime = 14
            Lighting.Brightness = 3
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            Lighting.FogColor = Color3.fromRGB(255, 255, 255)
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
        end
        setDay()
        local props = {"TimeOfDay", "ClockTime", "Brightness", "Ambient", "OutdoorAmbient", "FogEnd", "FogStart", "FogColor"}
        for _, prop in ipairs(props) do
            Lighting:GetPropertyChangedSignal(prop):Connect(setDay)
        end
        spawn(function()
            while true do
                setDay()
                task.wait(5)
            end
        end)
        Library:Notify({Title = "Day Mode", Description = "Brightness!", Time = 3})
    end,
})


MiscRight:AddToggle("LowGraphics", {
    Text = "Low Graphics (FPS Boost)",
    Default = false,
    Callback = function(enabled)
        if enabled then
            applyLowGraphics()
            Library:Notify({Title = "Low Graphics", Description = "ON - FPS Boost", Time = 2})
        else
            restoreGraphics()
            Library:Notify({Title = "Low Graphics", Description = "OFF - Full Graphics", Time = 2})
        end
    end,
})





--================================================================--
-- SETTINGS TAB (Save/Load Config)
--================================================================--
local SettingsTab = Window:AddTab("Settings", "cog")
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("Vgxmod")
SaveManager:SetFolder("Vgxmod")
SaveManager:BuildConfigSection(SettingsTab)
ThemeManager:ApplyToTab(SettingsTab)
SaveManager:LoadAutoloadConfig()
