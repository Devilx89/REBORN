local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "Vgxmod Hub",
            ["WELCOME"] = "https://discord.gg/n9gtmefsjc",
            ["Info"] = "Info",
            ["Main"] = "Main",
            ["Automation"] = "Automation",
            ["Player"] = "Player",
            ["Combat"] = "Combat",
            ["Visual"] = "Visual",
            ["Teleport"] = "Teleport"
        }
    }
})

WindUI.TransparencyValue = 0.2
WindUI:SetTheme("Dark")

local Window = WindUI:CreateWindow({
    Title = "loc:WINDUI_EXAMPLE",
    Icon = "moon",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Dark",
    SideBarWidth = 200,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            WindUI:Notify({
                Title = "Profile",
                Content = "You clicked the profile!",
                Duration = 3
            })
        end
    }
})

local Tab_Info = Window:Tab({ Title = "Info", Icon = "info" })
-- local Tab_Main = Window:Tab({ Title = "Main", Icon = "layout-grid" })
-- local Tab_Automation = Window:Tab({ Title = "Automation", Icon = "cpu" })
-- local Tab_Player = Window:Tab({ Title = "Player", Icon = "user" })
local Tab_Combat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local Tab_Visual = Window:Tab({ Title = "Visual", Icon = "eye" })
-- local Tab_Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" })

Tab_Info:Paragraph({
    Title = "Discord Link",
    Desc = "Kindly request the script on my Discord server.",
    Image = "user-plus",
    ImageSize = 20,
    Color = "Grey",
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "copy",
            Variant = "Tertiary",
            Callback = function()
                setclipboard("https://discord.gg/n9gtmefsjc")
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord link copied to clipboard",
                    Duration = 2
                })
            end
        }
    }
})




























local EspSection = Tab_Combat:Section({ Title = "AIMBOT / FEATURE" })





local LP = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local SAFOV = 500
local SAFOVFilled = false
local SAFOVOutline = true
local HitPart = "Head"
local SAHitChance = 100
local SASnaplines = true
local CircleMode = "Center"

local SilentAimEnabled = false -- Default: OFF on script execution
local WallCheckEnabled = false -- Default: OFF on script execution

local C1, C2 = Drawing.new("Circle"), Drawing.new("Circle")
local SnaplineDrawing = nil
local SAConnections = {}
local SAHook = nil
local CC = Workspace.CurrentCamera
local Tgt = nil

local function hsvToRgb(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then return Color3.new(v, t, p)
    elseif i == 1 then return Color3.new(q, v, p)
    elseif i == 2 then return Color3.new(p, v, t)
    elseif i == 3 then return Color3.new(p, q, v)
    elseif i == 4 then return Color3.new(t, p, v)
    elseif i == 5 then return Color3.new(v, p, q) end
end

SAConnections.RenderStepped = RunService.Stepped:Connect(function()
    if not SilentAimEnabled then
        C1.Visible = false
        C2.Visible = false
        if SnaplineDrawing then SnaplineDrawing.Visible = false end
        return
    end

    local sc
    if CircleMode == "Center" then
        sc = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
    else
        local mouse = LP:GetMouse()
        sc = Vector2.new(mouse.X, mouse.Y)
    end

    local hue = (tick() * 0.1) % 1
    local rainbowColor = hsvToRgb(hue, 1, 1)

    C1.Position = sc
    C1.Radius = SAFOV
    C1.Color = rainbowColor
    C1.Filled = SAFOVFilled
    C1.Transparency = SAFOVFilled and 0.3 or 0
    C1.Visible = SAFOVFilled

    C2.Position = sc
    C2.Radius = SAFOV
    C2.Color = rainbowColor
    C2.Thickness = SAFOVOutline and 2 or 0
    C2.Filled = false
    C2.Visible = SAFOVOutline

    local closest, dist = nil, SAFOV
    for _, v in ipairs(Players:GetPlayers()) do
        local h = v.Character and v.Character:FindFirstChild(HitPart)
        if v ~= LP and h then
            local hum = v.Character:FindFirstChildOfClass("Humanoid")
            local pos, on = CC:WorldToViewportPoint(h.Position + Vector3.new(0, 0.2, 0))
            if on and hum and hum.Health > 0 then
                local canTarget = true
                if WallCheckEnabled then
                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                    rayParams.FilterDescendantsInstances = {LP.Character}
                    local result = Workspace:Raycast(CC.CFrame.Position, (h.Position - CC.CFrame.Position).Unit * 1000, rayParams)
                    canTarget = not result or result.Instance:IsDescendantOf(v.Character)
                end
                if canTarget then
                    local m = (Vector2.new(pos.X, pos.Y) - sc).Magnitude
                    if m < dist then
                        dist, closest = m, v
                    end
                end
            end
        end
    end
    Tgt = closest

    if SASnaplines then
        if not SnaplineDrawing then
            SnaplineDrawing = Drawing.new("Line")
            SnaplineDrawing.Thickness = 2
        end
        if Tgt and Tgt.Character and Tgt.Character:FindFirstChild(HitPart) then
            local tgtPos, onScreen = CC:WorldToViewportPoint(Tgt.Character[HitPart].Position)
            if onScreen then
                SnaplineDrawing.From = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
                SnaplineDrawing.To = Vector2.new(tgtPos.X, tgtPos.Y)
                SnaplineDrawing.Color = rainbowColor
                SnaplineDrawing.Visible = true
            else
                SnaplineDrawing.Visible = false
            end
        else
            SnaplineDrawing.Visible = false
        end
    elseif SnaplineDrawing then
        SnaplineDrawing.Visible = false
    end
end)

SAHook = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    if not checkcaller() and getnamecallmethod() == "FindPartOnRayWithIgnoreList" and SilentAimEnabled and Tgt and Tgt.Character then
        if math.random(1, 100) <= SAHitChance then
            local origin = args[1].Origin
            args[1] = Ray.new(origin, Tgt.Character[HitPart].Position - origin)
        end
    end
    return SAHook(self, unpack(args))
end)

-- UI Toggles
local SA_ToggleSet = false
Tab_Combat:Toggle({
    Title = "Silent Aim",
    Value = false,
    Callback = function(Value)
        if SA_ToggleSet then
            SilentAimEnabled = Value
            WindUI:Notify({
                Title = "Silent Aim",
                Content = "State: " .. tostring(Value),
                Duration = 2
            })
        else
            SA_ToggleSet = true
        end
    end
})

local WC_ToggleSet = false
Tab_Combat:Toggle({
    Title = "Wall Check",
    Value = false,
    Callback = function(Value)
        if WC_ToggleSet then
            WallCheckEnabled = Value
            WindUI:Notify({
                Title = "Wall Check",
                Content = "State: " .. tostring(Value),
                Duration = 2
            })
        else
            WC_ToggleSet = true
        end
    end
})






















local EspSection = Tab_Visual:Section({ Title = "ESP / FEATURE" })




local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Tracer
local TracerSettings = {
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 1.5,
    TracerTransparency = 1,
    TracerFrom = "Top"
}

local TracerESPEnabled = false
local Tracer_ToggleSet = false
local TracerLines = {}

local function getTracerOrigin()
    if TracerSettings.TracerFrom == "Bottom" then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    elseif TracerSettings.TracerFrom == "Top" then
        return Vector2.new(Camera.ViewportSize.X / 2, 0)
    elseif TracerSettings.TracerFrom == "Center" then
        return Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
end

local function createTracer(player)
    if player == LocalPlayer or TracerLines[player] then return end
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = TracerSettings.TracerColor
    line.Thickness = TracerSettings.TracerThickness
    line.Transparency = TracerSettings.TracerTransparency
    TracerLines[player] = line
end

local function removeTracer(player)
    if TracerLines[player] then
        TracerLines[player]:Remove()
        TracerLines[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do createTracer(player) end
Players.PlayerAdded:Connect(createTracer)
Players.PlayerRemoving:Connect(removeTracer)

RunService.RenderStepped:Connect(function()
    local origin = getTracerOrigin()
    for player, line in pairs(TracerLines) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root and TracerESPEnabled then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if onScreen then
                line.From = origin
                line.To = Vector2.new(pos.X, pos.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
end)

Tab_Visual:Toggle({
    Title = "ESP Tracer",
    Value = false,
    Callback = function(Value)
        if Tracer_ToggleSet then
            TracerESPEnabled = Value
        else
            Tracer_ToggleSet = true
        end
    end
})




-- Box

local BoxSettings = {
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 2,
    BoxTransparency = 1
}

local BoxESPEnabled = false
local Box_ToggleSet = false
local Boxes = {}
local CachedParts = {}


local function createBox(player)
    if player == LocalPlayer or Boxes[player] then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = BoxSettings.BoxColor
    box.Thickness = BoxSettings.BoxThickness
    box.Transparency = BoxSettings.BoxTransparency
    box.Filled = false

    Boxes[player] = box
    CachedParts[player] = {}
end

-- Remove box
local function removeBox(player)
    if Boxes[player] then
        Boxes[player]:Remove()
        Boxes[player] = nil
    end
    CachedParts[player] = nil
end

-- Cache parts for performance
local function cacheCharacterParts(player)
    local char = player.Character
    if not char then return end

    local parts = {}
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            table.insert(parts, part)
        end
    end
    CachedParts[player] = parts
end


for _, player in ipairs(Players:GetPlayers()) do
    createBox(player)
    player.CharacterAdded:Connect(function()
        task.wait(1) -- Wait for parts to load
        cacheCharacterParts(player)
    end)
end

Players.PlayerAdded:Connect(function(player)
    createBox(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        cacheCharacterParts(player)
    end)
end)

Players.PlayerRemoving:Connect(removeBox)

-- Render loop
RunService.RenderStepped:Connect(function()
    for player, box in pairs(Boxes) do
        local char = player.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not humanoid or humanoid.Health <= 0 or not BoxESPEnabled then
            box.Visible = false
            continue
        end

        local parts = CachedParts[player]
        if not parts or #parts == 0 then
            cacheCharacterParts(player)
            parts = CachedParts[player]
        end

        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local onScreen = false

        for _, part in ipairs(parts) do
            local pos, visible = Camera:WorldToViewportPoint(part.Position)
            if visible then
                onScreen = true
                minX = math.min(minX, pos.X)
                minY = math.min(minY, pos.Y)
                maxX = math.max(maxX, pos.X)
                maxY = math.max(maxY, pos.Y)
            end
        end

        if onScreen then
            box.Position = Vector2.new(minX, minY)
            box.Size = Vector2.new(maxX - minX, maxY - minY)
            box.Visible = true
        else
            box.Visible = false
        end
    end
end)


Tab_Visual:Toggle({
    Title = "ESP Box",
    Value = false,
    Callback = function(Value)
        if Box_ToggleSet then
            BoxESPEnabled = Value
        else
            Box_ToggleSet = true
        end
    end
})









Window:OnClose(function()
    print("Window closed")
end)

Window:OnDestroy(function()
    print("Window destroyed")
end)
