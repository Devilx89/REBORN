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
local Tab_Player = Window:Tab({ Title = "Player", Icon = "user" })
local Tab_Combat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local Tab_Visual = Window:Tab({ Title = "Visual", Icon = "eye" })


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









local EspSection = Tab_Player:Section({ Title = "MOVEMENT" })

getgenv().SpeedWalkEnabled = false
getgenv().SpeedWalkValue = 16

getgenv().JumpBoostEnabled = false
getgenv().JumpPowerValue = 50

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChild("Humanoid")
    if humanoid then
        if getgenv().SpeedWalkEnabled then
            humanoid.WalkSpeed = getgenv().SpeedWalkValue
        else
            humanoid.WalkSpeed = 16
        end

        if getgenv().JumpBoostEnabled then
            humanoid.JumpPower = getgenv().JumpPowerValue
        else
            humanoid.JumpPower = 50
        end
    end
end)

Tab_Player:Toggle({
    Title = "Speed Walk",
    Value = false,
    Callback = function(v)
        getgenv().SpeedWalkEnabled = v
    end
})

Tab_Player:Slider({
    Title = "Set Speed",
    Desc = "",
    Value = { Min = 16, Max = 500, Default = 16 },
    Callback = function(v)
        getgenv().SpeedWalkValue = v
    end
})

Tab_Player:Toggle({
    Title = "Jump Boost",
    Value = false,
    Callback = function(v)
        getgenv().JumpBoostEnabled = v
    end
})

Tab_Player:Slider({
    Title = "Set Power",
    Desc = "",
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(v)
        getgenv().JumpPowerValue = v
    end
})












local EspSection = Tab_Player:Section({ Title = "CHARACTER" })





local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

getgenv().NoclipEnabled = false
getgenv().OriginalCanCollide = {}

-- Apply noclip continuously
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                if getgenv().NoclipEnabled then
                    if getgenv().OriginalCanCollide[part] == nil then
                        getgenv().OriginalCanCollide[part] = part.CanCollide
                    end
                    part.CanCollide = false
                else
                    if getgenv().OriginalCanCollide[part] ~= nil then
                        part.CanCollide = getgenv().OriginalCanCollide[part]
                        getgenv().OriginalCanCollide[part] = nil
                    end
                end
            end
        end
    end
end)

Tab_Player:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(v)
        getgenv().NoclipEnabled = v
    end
})


















local EspSection = Tab_Combat:Section({ Title = "GUN / FEATURE" })

getgenv().AutoPickupGun = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function grabDroppedGun()
    local gun = workspace:FindFirstChild("GunSpawn") and workspace.GunSpawn:FindFirstChild("DroppedGun")
    if gun and gun:FindFirstChild("TouchInterest") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, gun, 0)
        task.wait()
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, gun, 1)
    end
end

task.spawn(function()
    while task.wait(0.3) do
        if getgenv().AutoPickupGun then
            grabDroppedGun()
        end
    end
end)

Tab_Combat:Toggle({
    Title = "Auto Pickup Gun",
    Value = false,
    Callback = function(v)
        getgenv().AutoPickupGun = v
    end
})










local EspSection = Tab_Combat:Section({ Title = "MURDERER / FEATURE" })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local loopDelay = 0.3

Tab_Combat:Toggle({
    Title = "Kill All",
    Desc = "",
    Callback = function(state)
        spawn(function()
            while state do
                local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
                if knife then
                    if knife.Parent == LocalPlayer.Backpack then
                        LocalPlayer.Character.Humanoid:EquipTool(knife)
                    end

                    local lpChar = LocalPlayer.Character
                    if lpChar and lpChar:FindFirstChild("HumanoidRootPart") then
                        local lpHRP = lpChar.HumanoidRootPart

                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer then
                                local char = player.Character
                                if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid:FindFirstChild("Role") then
                                    lpHRP.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                                    wait(loopDelay)
                                end
                            end
                        end
                    end
                else
                    WindUI:Notify({
                        Title = "You are not murder",
                        Content = "",
                        Icon = "x",
                        Duration = 2
                    })
                    state = false
                    break
                end
                wait(0.1)
            end
        end)
    end
})









local EspSection = Tab_Combat:Section({ Title = "HITBOX" })
getgenv().HitboxEnabled = false
getgenv().HitboxSize = 10

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local OriginalHRPProps = {}

local function applyHitbox(player)
    if player == LocalPlayer then return end
    if not player.Character then return end

    local humanoid = player.Character:FindFirstChild("Humanoid")
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local role = humanoid and humanoid:FindFirstChild("Role")
    if not hrp or not role then return end

    if not OriginalHRPProps[player] then
        OriginalHRPProps[player] = {
            Size = hrp.Size,
            Transparency = hrp.Transparency,
            BrickColor = hrp.BrickColor,
            Material = hrp.Material,
            CanCollide = hrp.CanCollide
        }
    end

    hrp.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
    hrp.Transparency = 0.7
    hrp.BrickColor = BrickColor.new("Really black")
    hrp.Material = Enum.Material.Neon
    hrp.CanCollide = false
end

local function restoreOriginal(player)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local props = OriginalHRPProps[player]
    if hrp and props then
        hrp.Size = props.Size
        hrp.Transparency = props.Transparency
        hrp.BrickColor = props.BrickColor
        hrp.Material = props.Material
        hrp.CanCollide = props.CanCollide
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local role = humanoid and humanoid:FindFirstChild("Role")
            if getgenv().HitboxEnabled and role then
                pcall(applyHitbox, player)
            elseif not getgenv().HitboxEnabled then
                pcall(restoreOriginal, player)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    pcall(restoreOriginal, player)
    OriginalHRPProps[player] = nil
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if getgenv().HitboxEnabled then
            pcall(applyHitbox, player)
        end
    end)
end)

Tab_Combat:Toggle({
    Title = "Hitbox",
    Value = false,
    Callback = function(v)
        getgenv().HitboxEnabled = v
    end
})

Tab_Combat:Slider({
    Title = "Hitbox Size",
    Desc = "Adjust the hitbox size",
    Value = { Min = 1, Max = 100, Default = 10 },
    Callback = function(value)
        getgenv().HitboxSize = value
    end
})


















local EspSection = Tab_Visual:Section({ Title = "ESP / NAME" })

getgenv().ESPSettings = {
    Murder = false,
    Sheriff = false,
    Innocent = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Names = {}

local function getRoleColor(player)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid:FindFirstChild("Role") then
        local role = char.Humanoid.Role.Value
        if role == "Murderer" and getgenv().ESPSettings.Murder then
            return Color3.fromRGB(255, 0, 0), true
        elseif role == "Sheriff" and getgenv().ESPSettings.Sheriff then
            return Color3.fromRGB(0, 0, 255), true
        elseif role ~= "Murderer" and role ~= "Sheriff" and getgenv().ESPSettings.Innocent then
            return Color3.fromRGB(0, 255, 0), true
        end
    end
    return Color3.fromRGB(255, 255, 255), false
end

local function createName(player)
    if player == LocalPlayer then return end
    local text = Drawing.new("Text")
    text.Visible = false
    text.Size = 14
    text.Center = true
    text.Outline = true
    text.Text = player.Name
    Names[player] = text
end

local function removeName(player)
    if Names[player] then
        Names[player]:Remove()
        Names[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    createName(player)
end

Players.PlayerAdded:Connect(createName)
Players.PlayerRemoving:Connect(removeName)

RunService.RenderStepped:Connect(function()
    for player, text in pairs(Names) do
        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        if head then
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
            if onScreen then
                local color, show = getRoleColor(player)
                if show then
                    text.Position = Vector2.new(pos.X, pos.Y)
                    text.Color = color
                    text.Visible = true
                else
                    text.Visible = false
                end
            else
                text.Visible = false
            end
        else
            text.Visible = false
        end
    end
end)

Tab_Visual:Toggle({
    Title = "ESP Name Murder",
    Value = false,
    Callback = function(v)
        getgenv().ESPSettings.Murder = v
    end
})

Tab_Visual:Toggle({
    Title = "ESP Name Sheriff",
    Value = false,
    Callback = function(v)
        getgenv().ESPSettings.Sheriff = v
    end
})

Tab_Visual:Toggle({
    Title = "ESP Name Innocent",
    Value = false,
    Callback = function(v)
        getgenv().ESPSettings.Innocent = v
    end
})



local EspSection = Tab_Visual:Section({ Title = "ESP / CHAM" })

getgenv().ChamSettings = {
    Murder = false,
    Sheriff = false,
    Innocent = false
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local highlights = {}

local function getRoleColor(player)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid:FindFirstChild("Role") then
        local role = char.Humanoid.Role.Value
        if role == "Murderer" and getgenv().ChamSettings.Murder then
            return Color3.fromRGB(255, 0, 0), true
        elseif role == "Sheriff" and getgenv().ChamSettings.Sheriff then
            return Color3.fromRGB(0, 0, 255), true
        elseif role ~= "Murderer" and role ~= "Sheriff" and getgenv().ChamSettings.Innocent then
            return Color3.fromRGB(0, 255, 0), true
        end
    end
    return Color3.fromRGB(255, 255, 255), false
end

local function applyCham(player, character)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.Parent = character
    highlights[player] = highlight
end

local function createCham(player)
    if player == LocalPlayer then return end

    if player.Character then
        applyCham(player, player.Character)
    end
    player.CharacterAdded:Connect(function(char)
        applyCham(player, char)
    end)
end

local function removeCham(player)
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    createCham(player)
end

Players.PlayerAdded:Connect(createCham)
Players.PlayerRemoving:Connect(removeCham)

game:GetService("RunService").RenderStepped:Connect(function()
    for player, highlight in pairs(highlights) do
        if player.Character then
            local color, show = getRoleColor(player)
            highlight.FillColor = color
            highlight.Enabled = show
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.OutlineColor = Color3.fromRGB(255,255,255)
        end
    end
end)

-- UI Toggles
Tab_Visual:Toggle({
    Title = "ESP Cham Murder",
    Value = false,
    Callback = function(v)
        getgenv().ChamSettings.Murder = v
    end
})

Tab_Visual:Toggle({
    Title = "ESP Cham Sheriff",
    Value = false,
    Callback = function(v)
        getgenv().ChamSettings.Sheriff = v
    end
})

Tab_Visual:Toggle({
    Title = "ESP Cham Innocent",
    Value = false,
    Callback = function(v)
        getgenv().ChamSettings.Innocent = v
    end
})




local EspSection = Tab_Visual:Section({ Title = "NOTIFY / GUN" })

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

getgenv().GunDropNotifyEnabled = false
getgenv().KnownGuns = {}

local GunSpawn = Workspace:WaitForChild("GunSpawn")

getgenv().SendGunNotification = function(gunName)
    pcall(function()
        WindUI:Notify({
            Title = "Gun Spawned",
            Content = gunName .. " is available!",
            Duration = 2
        })
    end)
end

local function CheckGuns()
    for _, gun in ipairs(GunSpawn:GetChildren()) do
        if (gun:IsA("Model") or gun:IsA("Tool")) and not getgenv().KnownGuns[gun] then
            getgenv().KnownGuns[gun] = true
            if getgenv().GunDropNotifyEnabled then
                getgenv().SendGunNotification(gun.Name)
            end
        end
    end
end

GunSpawn.ChildAdded:Connect(function(gun)
    task.defer(CheckGuns)
end)

Tab_Visual:Toggle({
    Title = "Gun Drop Notify",
    Value = false,
    Callback = function(v)
        getgenv().GunDropNotifyEnabled = v
        if v then
            CheckGuns()
        end
    end
})




Window:OnClose(function()
    print("Window closed")
end)

Window:OnDestroy(function()
    print("Window destroyed")
end)
