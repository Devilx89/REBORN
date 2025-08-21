if game.PlaceId ~= 142823291 then
    warn("This script only works in the supported game......")
    return
end
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en"] = {
            ["WINDUI_EXAMPLE"] = "Vgxmod Hub",
            ["WELCOME"] = "discord.gg/vgxmod",
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
    Author = "loc:WELCOME",
    Folder = "WindUI_Example",
    Size = UDim2.fromOffset(580, 490),
    Theme = "Dark",
    SideBarWidth = 200,
})


local Tab_Info = Window:Tab({ Title = "Info", Icon = "info" })
local Tab_Main = Window:Tab({ Title = "Main", Icon = "layout-grid" })
local Tab_Automation = Window:Tab({ Title = "Automation", Icon = "cpu" })
local Tab_Player = Window:Tab({ Title = "Player", Icon = "user" })
local Tab_Combat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
local Tab_Visual = Window:Tab({ Title = "Visual", Icon = "eye" })
local Tab_Teleport = Window:Tab({ Title = "Teleport", Icon = "map-pin" })


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
                setclipboard("https://discord.gg/vgxmod")
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord link copied to clipboard",
                    Duration = 2
                })
            end
        }
    }
})
























--[[

MAIN

]]--




local EspSection = Tab_Main:Section({ 
    Title = "OTHER" 
})

Tab_Main:Button({
    Title = "Grab Gun",
    Desc = "",
    Callback = function()
        local Workspace = game:GetService("Workspace")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Char = LocalPlayer.Character
        local Root = Char and Char:FindFirstChild("HumanoidRootPart")

        if Char and Root then
            local gun = Workspace:FindFirstChild("GunDrop", true)

            if gun then
                if firetouchinterest then
                    firetouchinterest(Root, gun, 0)
                    firetouchinterest(Root, gun, 1)
                else
                    gun.CFrame = Root.CFrame
                end

               
                WindUI:Notify({
                    Title = "Grab Gun",
                    Content = "Gun grabbed successfully!",
                    Duration = 2
                })
            else
               
                WindUI:Notify({
                    Title = "Grab Gun",
                    Content = "Gun not dropped yet.",
                    Duration = 2
                })
            end
        end
    end
})




Tab_Main:Toggle({
    Title = "Auto Grab Gun",
    Desc = "",
    Value = false,
    Callback = function(Value)
        local env = getgenv()
        env.AGG = Value

        local Workspace = game:GetService("Workspace")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Root = Char:FindFirstChild("HumanoidRootPart")

        task.spawn(function()
            while env.AGG do
                Char = LocalPlayer.Character
                Root = Char and Char:FindFirstChild("HumanoidRootPart")

                if Char and Root then
                    local gun = Workspace:FindFirstChild("GunDrop", true)
                    if gun then
                        if firetouchinterest then
                            firetouchinterest(Root, gun, 0)
                            firetouchinterest(Root, gun, 1)
                        else
                            gun.CFrame = Root.CFrame
                        end
                    end
                end

                task.wait(0.1)
            end
        end)
    end
})
























local EspSection = Tab_Main:Section({ 
    Title = "BUTTON" 
})

local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local guip = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")

local originalSize = Vector2.new(70, 70)
local speedButton
local speedOn = false
local normalSpeed = 16
local boostedSpeed = 25

Tab_Main:Toggle({
    Title = "Speed Boost Button",
    Desc = "",
    Value = false,
    Callback = function(Value)
        if Value then
            if not guip:FindFirstChild("SpeedBoostGui") then
                local SpeedGui = Instance.new("ScreenGui")
                SpeedGui.Name = "SpeedBoostGui"
                SpeedGui.Parent = guip

                speedButton = Instance.new("TextButton")
                speedButton.Size = UDim2.new(0, originalSize.X, 0, originalSize.Y)
                speedButton.Position = UDim2.new(0.5, 45, 0.5, -35)
                speedButton.AnchorPoint = Vector2.new(0.5, 0.5)
                speedButton.BackgroundTransparency = 0.5
                speedButton.BackgroundColor3 = Color3.new(0, 0, 0)
                speedButton.BorderSizePixel = 0
                speedButton.Text = "SPEED\nBOOST"
                speedButton.TextColor3 = Color3.new(1, 1, 1)
                speedButton.TextScaled = false
                speedButton.Font = Enum.Font.GothamBlack
                speedButton.TextWrapped = true
                speedButton.TextYAlignment = Enum.TextYAlignment.Center
                speedButton.TextXAlignment = Enum.TextXAlignment.Center
                speedButton.AutoButtonColor = false
                speedButton.TextSize = 12
                speedButton.Active = true
                speedButton.Draggable = true
                speedButton.Parent = SpeedGui

                local padding = Instance.new("UIPadding")
                padding.PaddingTop = UDim.new(0, 6)
                padding.PaddingBottom = UDim.new(0, 6)
                padding.PaddingLeft = UDim.new(0, 6)
                padding.PaddingRight = UDim.new(0, 6)
                padding.Parent = speedButton

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1, 0)
                corner.Parent = speedButton

                local border = Instance.new("UIStroke")
                border.Thickness = 2
                border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                border.Parent = speedButton

                -- ✅ Use smooth rainbow animation (RenderStepped with 0.1 speed)
                local hue = 0
                RunService.RenderStepped:Connect(function(deltaTime)
                    if speedButton and speedButton.Parent then
                        hue = (hue + deltaTime * 0.1) % 1
                        border.Color = Color3.fromHSV(hue, 1, 1)
                    end
                end)

                speedButton.MouseButton1Click:Connect(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChildOfClass("Humanoid") then
                        local humanoid = char:FindFirstChildOfClass("Humanoid")
                        speedOn = not speedOn
                        humanoid.WalkSpeed = speedOn and boostedSpeed or normalSpeed
                    end
                end)
            end
        else
            local existing = guip:FindFirstChild("SpeedBoostGui")
            if existing then existing:Destroy() end
            speedButton = nil
            speedOn = false
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").WalkSpeed = normalSpeed
            end
        end
    end
})



local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local guip = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")

local originalSize = Vector2.new(70, 70)
local grabButton

local function grabGun()
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")

    if Char and Root then
        local gun = Workspace:FindFirstChild("GunDrop", true)
        if gun then
            if firetouchinterest then
                firetouchinterest(Root, gun, 0)
                firetouchinterest(Root, gun, 1)
            else
                gun.CFrame = Root.CFrame
            end
        end
    end
end

Tab_Main:Toggle({
    Title = "Grab Gun Button",
    Desc = "",
    Value = false,
    Callback = function(Value)
        if Value then
            if not guip:FindFirstChild("GrabGunGui") then
                local GrabGui = Instance.new("ScreenGui")
                GrabGui.Name = "GrabGunGui"
                GrabGui.Parent = guip

                grabButton = Instance.new("TextButton")
                grabButton.Size = UDim2.new(0, originalSize.X, 0, originalSize.Y)
                grabButton.Position = UDim2.new(0.5, -originalSize.X / 2, 0.5, -originalSize.Y / 2)
                grabButton.AnchorPoint = Vector2.new(0.5, 0.5)
                grabButton.BackgroundTransparency = 0.5
                grabButton.BackgroundColor3 = Color3.new(0, 0, 0)
                grabButton.BorderSizePixel = 0
                grabButton.Text = "GRAB\nGUN"
                grabButton.TextColor3 = Color3.new(1, 1, 1)
                grabButton.TextScaled = false
                grabButton.TextSize = 12
                grabButton.Font = Enum.Font.GothamBlack
                grabButton.TextWrapped = true
                grabButton.TextYAlignment = Enum.TextYAlignment.Center
                grabButton.TextXAlignment = Enum.TextXAlignment.Center
                grabButton.AutoButtonColor = false
                grabButton.Active = true
                grabButton.Draggable = true
                grabButton.Parent = GrabGui

                local padding = Instance.new("UIPadding")
                padding.PaddingTop = UDim.new(0, 6)
                padding.PaddingBottom = UDim.new(0, 6)
                padding.PaddingLeft = UDim.new(0, 6)
                padding.PaddingRight = UDim.new(0, 6)
                padding.Parent = grabButton

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1, 0)
                corner.Parent = grabButton

                local border = Instance.new("UIStroke")
                border.Thickness = 2
                border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                border.Parent = grabButton

                -- Use RenderStepped with 0.1 speed multiplier for smooth rainbow
                local hue = 0
                RunService.RenderStepped:Connect(function(deltaTime)
                    if grabButton and grabButton.Parent then
                        hue = (hue + deltaTime * 0.1) % 1
                        border.Color = Color3.fromHSV(hue, 1, 1)
                    end
                end)

                grabButton.MouseButton1Click:Connect(function()
                    grabGun()
                end)
            end
        else
            local existing = guip:FindFirstChild("GrabGunGui")
            if existing then existing:Destroy() end
            grabButton = nil
        end
    end
})

--[[

AUTOMATION

]]--









































--[[

PLAYER

]]--

local EspSection = Tab_Player:Section({ 
    Title = "MOVEMENT" 
})

local DEFAULT_WALKSPEED = 16
local customWalkEnabled = false
local customWalkSpeed = DEFAULT_WALKSPEED

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function applyWalkSpeed()
    if humanoid then
        humanoid.WalkSpeed = customWalkEnabled and customWalkSpeed or DEFAULT_WALKSPEED
    end
end

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    applyWalkSpeed()
end)

Tab_Player:Toggle({
    Title = "WalkSpeed",
    Desc = "",
    Value = false,
    Callback = function(state)
        customWalkEnabled = state
        applyWalkSpeed()
    end
})

Tab_Player:Slider({
    Title = "Set Speed",
    Desc = "",
    Value = { Min = 0, Max = 300, Default = DEFAULT_WALKSPEED },
    Callback = function(value)
        customWalkSpeed = value
        if customWalkEnabled then
            applyWalkSpeed()
        end
    end
})


local DEFAULT_JUMPPOWER = 50
local customJumpEnabled = false
local customJumpPower = DEFAULT_JUMPPOWER

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local function applyJumpPower()
    if humanoid then
        humanoid.JumpPower = customJumpEnabled and customJumpPower or DEFAULT_JUMPPOWER
    end
end

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    applyJumpPower()
end)

Tab_Player:Toggle({
    Title = "JumpPower",
    Desc = "",
    Value = false,
    Callback = function(state)
        customJumpEnabled = state
        applyJumpPower()
    end
})

Tab_Player:Slider({
    Title = "Set Jump",
    Desc = "",
    Value = { Min = 0, Max = 300, Default = DEFAULT_JUMPPOWER },
    Callback = function(value)
        customJumpPower = value
        if customJumpEnabled then
            applyJumpPower()
        end
    end
})


local EspSection = Tab_Player:Section({ 
    Title = "CHARACTER" 
})



local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local env = getgenv()

Tab_Player:Toggle({
    Title = "Anti Fling",
    Desc = "",
    Value = false,
    Callback = function(value)
        env.NoclipPlr = value

        if not value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = true
                        end
                    end
                end
            end
            return
        end

        task.spawn(function()
            while env.NoclipPlr do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        for _, v in pairs(player.Character:GetDescendants()) do
                            if v:IsA("BasePart") then
                                v.CanCollide = false
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    end
})




local godcon, deathcon
local LocalPlayer = game.Players.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Hum = Char:FindFirstChildOfClass("Humanoid")
local env = getgenv()

Tab_Player:Toggle({
    Title = "Second Life",
    Desc = "",
    Value = false,
    Callback = function(Value)
        env.enableGodmode = Value

        local function IsGodmode()
            return env.enableGodmode
        end

        local function UpdateGod()
            if godcon then
                godcon:Disconnect()
                godcon = nil
            end
            if Hum then
                godcon = Hum.HealthChanged:Connect(function()
                    if IsGodmode() and Hum.Health < Hum.MaxHealth then
                        Hum.Health = Hum.MaxHealth
                    end
                end)
            end
        end

        local function OnCharacterAdded(newChar)
            Char = newChar
            Hum = Char:WaitForChild("Humanoid")
            UpdateGod()
        end

        if deathcon then deathcon:Disconnect() end
        deathcon = LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

        UpdateGod()

        task.spawn(function()
            if not env.enableGodmode then
                if godcon then
                    godcon:Disconnect()
                    godcon = nil
                end
            else
                if not godcon then
                    UpdateGod()
                end
            end
        end)
    end
})





























--[[

COMBAT

]]--

local EspSection = Tab_Combat:Section({ 
    Title = "SHERIFF / FEATURE" 
})

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = game.Players.LocalPlayer
local guip = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:FindFirstChild("PlayerGui")

local targetScale = 0 -- Amount to ADD to width/height
local shootButton
local originalWidth, originalHeight = 180, 90

Tab_Combat:Toggle({
    Title = "Shoot Murder Button",
    Desc = "",
    Value = false,
    Callback = function(Value)
        if Value then
            if not guip:FindFirstChild("GunW") then
                local GunGui = Instance.new("ScreenGui")
                GunGui.Name = "GunW"
                GunGui.Parent = guip

                shootButton = Instance.new("TextButton")
                shootButton.Size = UDim2.new(0, originalWidth, 0, originalHeight)
                shootButton.Position = UDim2.new(0.5, 187, 0.5, -176)
                shootButton.AnchorPoint = Vector2.new(0.5, 0.5)
                shootButton.BackgroundTransparency = 0.5
                shootButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                shootButton.BorderSizePixel = 0

                -- Text properties
                shootButton.Text = "Shoot\nMurder"
                shootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                shootButton.TextScaled = true
                shootButton.Font = Enum.Font.GothamBold
                shootButton.TextYAlignment = Enum.TextYAlignment.Center
                shootButton.TextXAlignment = Enum.TextXAlignment.Center
                shootButton.TextStrokeTransparency = 1
                shootButton.TextWrapped = true

                shootButton.Active = true
                shootButton.Draggable = true
                shootButton.Parent = GunGui

                -- Rounded corners
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 20)
                corner.Parent = shootButton

                -- Rainbow border
                local border = Instance.new("UIStroke")
                border.Thickness = 3
                border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                border.Parent = shootButton

                -- Smooth rainbow animation (slow, like grab gun)
                local hue = 0
                RunService.RenderStepped:Connect(function(deltaTime)
                    if shootButton and shootButton.Parent then
                        hue = (hue + deltaTime * 0.1) % 1
                        border.Color = Color3.fromHSV(hue, 1, 1)
                    end
                end)

                -- Aspect ratio constraint
                local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint", shootButton)
                UIAspectRatioConstraint.AspectRatio = originalWidth / originalHeight

                -- Shoot functionality
                local function getMurdererTarget()
                    local data = game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true):InvokeServer()
                    for plrName, plrData in pairs(data) do
                        if plrData.Role == "Murderer" then
                            local target = game.Players:FindFirstChild(plrName)
                            if target and target ~= LocalPlayer and target.Character then
                                local hrp = target.Character:FindFirstChild("HumanoidRootPart")
                                local head = target.Character:FindFirstChild("Head")
                                return (hrp and hrp.Position) or (head and head.Position)
                            end
                        end
                    end
                end

                shootButton.MouseButton1Click:Connect(function()
                    local Char = LocalPlayer.Character
                    if Char and Char:FindFirstChild("Gun") then
                        pcall(function()
                            local gun = Char.Gun
                            local knifeScript = gun:FindFirstChild("KnifeLocal")
                            local cb = knifeScript and knifeScript:FindFirstChild("CreateBeam")
                            local remote = cb and cb:FindFirstChild("RemoteFunction")
                            local targetPos = getMurdererTarget()
                            if remote and targetPos then
                                remote:InvokeServer(1, targetPos, "AH2")
                            end
                        end)
                    end
                end)

                -- Smooth additive scaling
                RunService.RenderStepped:Connect(function()
                    if shootButton and shootButton.Parent then
                        local currentX = shootButton.Size.X.Offset
                        local currentY = shootButton.Size.Y.Offset

                        local desiredX = originalWidth + targetScale
                        local desiredY = originalHeight + targetScale

                        local newX = currentX + (desiredX - currentX) * 0.1
                        local newY = currentY + (desiredY - currentY) * 0.1

                        shootButton.Size = UDim2.new(0, newX, 0, newY)
                        shootButton.TextSize = 12 * (newY / originalHeight)
                    end
                end)
            end
        else
            local existing = guip:FindFirstChild("GunW")
            if existing then existing:Destroy() end
            shootButton = nil
        end
    end
})

Tab_Combat:Slider({
    Title = "Set Button Size",
    Desc = "",
    Value = {Min = 0, Max = 50, Default = 0},
    Callback = function(scale)
        targetScale = scale
    end
})






local GunAimbotEnabled

Tab_Combat:Toggle({
    Title = "Auto Shoot Murder",
    Desc = "",
    Value = false,
    Callback = function(state)
        if GunAimbotEnabled ~= state then
            GunAimbotEnabled = state

            local env = getgenv()
            env.enabledGunBot = state

            if state then
                task.spawn(function()
                    while env.enabledGunBot do
                        local Char = game.Players.LocalPlayer.Character
                        if Char and Char:FindFirstChild("Gun") then
                            local gun = Char:FindFirstChild("Gun")
                            local knifeScript = gun:FindFirstChild("KnifeLocal")
                            local cb = knifeScript and knifeScript:FindFirstChild("CreateBeam")
                            local remote = cb and cb:FindFirstChild("RemoteFunction")
                            if remote then
                                local data = game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true):InvokeServer()
                                for plrName, plrData in pairs(data) do
                                    if plrData.Role == "Murderer" then
                                        local target = game.Players:FindFirstChild(plrName)
                                        if target and target ~= game.Players.LocalPlayer then
                                            local targetChar = target.Character
                                            if targetChar then
                                                local hrp = targetChar:FindFirstChild("HumanoidRootPart")
                                                local head = targetChar:FindFirstChild("Head")
                                                local targetPos = hrp and hrp.Position or head and head.Position
                                                if targetPos then
                                                    pcall(function()
                                                        remote:InvokeServer(1, targetPos, "AH2")
                                                    end)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.25)
                    end
                end)
            end
        end
    end
})












local EspSection = Tab_Combat:Section({ 
    Title = "MURDER / FEATURE" 
})

Tab_Combat:Toggle({
    Title = "Silent Slash",
    Desc = "",
    Value = false,
    Callback = (function()
        local initialized = false
        return function(state)
            if initialized and featureEnabled ~= state then
                WindUI:Notify({
                    Title = "Feature",
                    Content = state and "Feature Enabled" or "Feature Disabled",
                    Icon = state and "check" or "x",
                    Duration = 2
                })
            end
            featureEnabled = state
            initialized = true
        end
    end)()
})


Tab_Combat:Slider({
    Title = "Set Range",
    Desc = "",
    Value = { Min = 0, Max = 100, Default = 50 },
    Callback = function(value)
        print("Intensity set to:", value)
    end
})



Tab_Combat:Toggle({
    Title = "Kill All",
    Desc = "",
    Value = false,
    Callback = function(state)
        if featureEnabled ~= state then
            featureEnabled = state
            WindUI:Notify({
                Title = "Feature",
                Content = state and "Feature Enabled" or "Feature Disabled",
                Icon = state and "check" or "x",
                Duration = 2
            })
        end
    end
})

























--[[

VISUAL

]]--
-- Innocent ESP

local EspSection = Tab_Visual:Section({ 
    Title = "ESP / NAME" 
})
-- Innocent ESP Name
local InnocentESPNameEnabled = false
local InnocentColor = Color3.fromRGB(0, 255, 0) -- Green

Tab_Visual:Toggle({
    Title = "ESP Name Innocent",
    Desc = "",
    Value = false,
    Callback = function(state)
        InnocentESPNameEnabled = state
        local env = getgenv()
        env.InnocentESPName = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local billboard = player.Character and player.Character:FindFirstChild("InnocentNameESP")
                if billboard then billboard:Destroy() end
            end
        end

        local function applyESP(player)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("InnocentNameESP") then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "InnocentNameESP"
                    billboard.Adornee = hrp
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = player.Character

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = player.Name
                    textLabel.TextColor3 = InnocentColor
                    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.Parent = billboard
                end
            end
        end

        if state then
            task.spawn(function()
                while env.InnocentESPName do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Innocent" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player) end
                            end
                        end
                    end
                    task.wait(0.25)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})

-- Murderer ESP Name
local MurdererESPNameEnabled = false
local MurdererColor = Color3.fromRGB(255, 0, 0) -- Red

Tab_Visual:Toggle({
    Title = "ESP Name Murder",
    Desc = "",
    Value = false,
    Callback = function(state)
        MurdererESPNameEnabled = state
        local env = getgenv()
        env.MurdererESPName = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local billboard = player.Character and player.Character:FindFirstChild("MurdererNameESP")
                if billboard then billboard:Destroy() end
            end
        end

        local function applyESP(player)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("MurdererNameESP") then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "MurdererNameESP"
                    billboard.Adornee = hrp
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = player.Character

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = player.Name
                    textLabel.TextColor3 = MurdererColor
                    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.Parent = billboard
                end
            end
        end

        if state then
            task.spawn(function()
                while env.MurdererESPName do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Murderer" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player) end
                            end
                        end
                    end
                    task.wait(0.25)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})

-- Sheriff & Hero ESP Name
local SHHeroESPNameEnabled = false
local roleColors = {Sheriff = Color3.fromRGB(0, 0, 255), Hero = Color3.fromRGB(0, 0, 255)}

Tab_Visual:Toggle({
    Title = "ESP Name Sheriff",
    Desc = "",
    Value = false,
    Callback = function(state)
        SHHeroESPNameEnabled = state
        local env = getgenv()
        env.SHHeroESPName = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local billboard = player.Character and player.Character:FindFirstChild("SHHeroNameESP")
                if billboard then billboard:Destroy() end
            end
        end

        local function applyESP(player, role)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("SHHeroNameESP") then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "SHHeroNameESP"
                    billboard.Adornee = hrp
                    billboard.Size = UDim2.new(0, 100, 0, 30)
                    billboard.StudsOffset = Vector3.new(0, 2, 0)
                    billboard.AlwaysOnTop = true
                    billboard.Parent = player.Character

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = player.Name
                    textLabel.TextColor3 = roleColors[role] or Color3.fromRGB(255,255,0)
                    textLabel.TextStrokeColor3 = Color3.new(0,0,0)
                    textLabel.TextStrokeTransparency = 0
                    textLabel.TextScaled = true
                    textLabel.Font = Enum.Font.SourceSansBold
                    textLabel.Parent = billboard
                end
            end
        end

        if state then
            task.spawn(function()
                while env.SHHeroESPName do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Sheriff" or info.Role == "Hero" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player, info.Role) end
                            end
                        end
                    end
                    task.wait(0.25)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})











local EspSection = Tab_Visual:Section({ 
    Title = "ESP / HIGHLIGHTS" 
})

-- Innocent ESP
local InnocentESPEnabled = false
local roleColor = Color3.fromRGB(0, 255, 0) -- Green

Tab_Visual:Toggle({
    Title = "ESP Highlights Innocent",
    Desc = "",
    Value = false,
    Callback = function(state)
        InnocentESPEnabled = state
        local env = getgenv()
        env.InnocentESP = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local hl = player.Character and player.Character:FindFirstChild("InnocentHighlight")
                if hl then hl:Destroy() end
            end
        end

        local function applyESP(player)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("InnocentHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "InnocentHighlight"
                hl.FillColor = roleColor
                hl.OutlineColor = Color3.new(1,1,1)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.7
                hl.OutlineTransparency = 0
                hl.Parent = player.Character
            end
        end

        if state then
            task.spawn(function()
                while env.InnocentESP do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Innocent" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player) end
                            end
                        end
                    end
                    task.wait(0.25)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})

-- Murderer ESP
local MurdererESPEnabled = false
local roleColor = Color3.fromRGB(255, 0, 0) -- Red

Tab_Visual:Toggle({
    Title = "ESP Highlights Murder",
    Desc = "",
    Value = false,
    Callback = function(state)
        MurdererESPEnabled = state
        local env = getgenv()
        env.MurdererESP = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local hl = player.Character and player.Character:FindFirstChild("MurdererHighlight")
                if hl then hl:Destroy() end
            end
        end

        local function applyESP(player)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("MurdererHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "MurdererHighlight"
                hl.FillColor = roleColor
                hl.OutlineColor = Color3.new(1,1,1)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.7
                hl.OutlineTransparency = 0
                hl.Parent = player.Character
            end
        end

        if state then
            task.spawn(function()
                while env.MurdererESP do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Murderer" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player) end
                            end
                        end
                    end
                    task.wait(0.25)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})

local SHHeroESPEnabled = false
local roleColors = {Sheriff = Color3.fromRGB(0, 0, 255), Hero = Color3.fromRGB(0, 0, 255)}

Tab_Visual:Toggle({
    Title = "ESP Highlights Sheriff",
    Desc = "",
    Value = false,
    Callback = function(state)
        SHHeroESPEnabled = state
        local env = getgenv()
        env.SHHeroESP = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local hl = player.Character and player.Character:FindFirstChild("SHHeroHighlight")
                if hl then hl:Destroy() end
            end
        end

        local function applyESP(player, role)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("SHHeroHighlight") then
                local hl = Instance.new("Highlight")
                hl.Name = "SHHeroHighlight"
                hl.FillColor = roleColors[role] or Color3.fromRGB(255,255,0)
                hl.OutlineColor = Color3.new(1,1,1)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.7
                hl.OutlineTransparency = 0
                hl.Parent = player.Character
            end
        end

        if state then
            task.spawn(function()
                while env.SHHeroESP do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Sheriff" or info.Role == "Hero" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player, info.Role) end
                            end
                        end
                    end
                    task.wait(0.25)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})








local EspSection = Tab_Visual:Section({ 
    Title = "ESP / OUTLINE" 
})


local InnocentESPEnabled = false
local InnocentColor = Color3.fromRGB(0, 255, 0)

Tab_Visual:Toggle({
    Title = "ESP Outline Innocent",
    Desc = "",
    Value = false,
    Callback = function(state)
        InnocentESPEnabled = state
        local env = getgenv()
        env.InnocentOutlineESP = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local hl = player.Character and player.Character:FindFirstChild("InnocentOutlineESP")
                if hl then hl:Destroy() end
            end
        end

        local function applyESP(player)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("InnocentOutlineESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "InnocentOutlineESP"
                hl.FillTransparency = 1 -- fully transparent fill
                hl.OutlineTransparency = 0.5 -- semi-transparent outline
                hl.OutlineColor = InnocentColor
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = player.Character
            end
        end

        if state then
            task.spawn(function()
                while env.InnocentOutlineESP do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Innocent" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player) end
                            end
                        end
                    end
                    task.wait(0.5) -- minimal wait for performance
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})

local MurdererESPEnabled = false
local MurdererColor = Color3.fromRGB(255, 0, 0)

Tab_Visual:Toggle({
    Title = "ESP Outline Murderer",
    Desc = "",
    Value = false,
    Callback = function(state)
        MurdererESPEnabled = state
        local env = getgenv()
        env.MurdererOutlineESP = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local hl = player.Character and player.Character:FindFirstChild("MurdererOutlineESP")
                if hl then hl:Destroy() end
            end
        end

        local function applyESP(player)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("MurdererOutlineESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "MurdererOutlineESP"
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0.5
                hl.OutlineColor = MurdererColor
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = player.Character
            end
        end

        if state then
            task.spawn(function()
                while env.MurdererOutlineESP do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Murderer" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player) end
                            end
                        end
                    end
                    task.wait(0.5)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})

-- Sheriff & Hero Outline ESP
local SHHeroESPEnabled = false
local SHHeroColors = {Sheriff = Color3.fromRGB(0,0,255), Hero = Color3.fromRGB(0,0,255)}

Tab_Visual:Toggle({
    Title = "ESP Outline Sheriff",
    Desc = "",
    Value = false,
    Callback = function(state)
        SHHeroESPEnabled = state
        local env = getgenv()
        env.SHHeroOutlineESP = state

        local function clearESP()
            for _, player in ipairs(game.Players:GetPlayers()) do
                local hl = player.Character and player.Character:FindFirstChild("SHHeroOutlineESP")
                if hl then hl:Destroy() end
            end
        end

        local function applyESP(player, role)
            if player == game.Players.LocalPlayer then return end -- Don't highlight self
            if player.Character and not player.Character:FindFirstChild("SHHeroOutlineESP") then
                local hl = Instance.new("Highlight")
                hl.Name = "SHHeroOutlineESP"
                hl.FillTransparency = 1
                hl.OutlineTransparency = 0.5
                hl.OutlineColor = SHHeroColors[role] or Color3.fromRGB(0,0,255)
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = player.Character
            end
        end

        if state then
            task.spawn(function()
                while env.SHHeroOutlineESP do
                    local success, data = pcall(function()
                        return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
                    end)
                    if success and data then
                        for name, info in pairs(data) do
                            if info.Role == "Sheriff" or info.Role == "Hero" then
                                local player = game.Players:FindFirstChild(name)
                                if player then applyESP(player, info.Role) end
                            end
                        end
                    end
                    task.wait(0.5)
                end
                clearESP()
            end)
        else
            clearESP()
        end
    end
})

















local EspSection = Tab_Visual:Section({ 
    Title = "ESP / TRACER" 
})
local InnocentTracerEnabled = false
local InnocentTracerColor = Color3.fromRGB(0, 255, 0)

Tab_Visual:Toggle({
Title = "ESP Tracer Innocent",
Desc = "",
Value = false,
Callback = function(state)
InnocentTracerEnabled = state
local env = getgenv()
env.InnocentTracer = state

local PlayerTracers = {}

local function clearTracers()
    for _, tracer in pairs(PlayerTracers) do
        if tracer then
            tracer.Visible = false
            tracer:Remove()
        end
    end
    table.clear(PlayerTracers)
end

local function createTracer(player)
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = InnocentTracerColor
    tracer.Thickness = 1
    tracer.Transparency = 0.7
    PlayerTracers[player] = tracer

    RunService.RenderStepped:Connect(function()
        if not InnocentTracerEnabled then
            tracer.Visible = false
            return
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                tracer.To = Vector2.new(pos.X, pos.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end)
end

if state then
    task.spawn(function()
        while env.InnocentTracer do
            local success, data = pcall(function()
                return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
            end)
            if success and data then
                for name, info in pairs(data) do
                    if info.Role == "Innocent" then
                        local player = game.Players:FindFirstChild(name)
                        if player and not PlayerTracers[player] then
                            createTracer(player)
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        clearTracers()
    end)
else
    clearTracers()
end
end
})


local MurdererTracerEnabled = false
local MurdererTracerColor = Color3.fromRGB(255, 0, 0)

Tab_Visual:Toggle({
Title = "ESP Tracer Murder",
Desc = "",
Value = false,
Callback = function(state)
MurdererTracerEnabled = state
local env = getgenv()
env.MurdererTracer = state

local PlayerTracers = {}

local function clearTracers()
    for _, tracer in pairs(PlayerTracers) do
        if tracer then
            tracer.Visible = false
            tracer:Remove()
        end
    end
    table.clear(PlayerTracers)
end

local function createTracer(player)
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = MurdererTracerColor
    tracer.Thickness = 1
    tracer.Transparency = 0.7
    PlayerTracers[player] = tracer

    RunService.RenderStepped:Connect(function()
        if not MurdererTracerEnabled then
            tracer.Visible = false
            return
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                tracer.To = Vector2.new(pos.X, pos.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end)
end

if state then
    task.spawn(function()
        while env.MurdererTracer do
            local success, data = pcall(function()
                return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
            end)
            if success and data then
                for name, info in pairs(data) do
                    if info.Role == "Murderer" then
                        local player = game.Players:FindFirstChild(name)
                        if player and not PlayerTracers[player] then
                            createTracer(player)
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        clearTracers()
    end)
else
    clearTracers()
end
end
})


local SHHeroTracerEnabled = false
local SHHeroTracerColor = Color3.fromRGB(0, 0, 255)

Tab_Visual:Toggle({
Title = "ESP Tracer Sheriff",
Desc = "",
Value = false,
Callback = function(state)
SHHeroTracerEnabled = state
local env = getgenv()
env.SHHeroTracer = state

local PlayerTracers = {}

local function clearTracers()
    for _, tracer in pairs(PlayerTracers) do
        if tracer then
            tracer.Visible = false
            tracer:Remove()
        end
    end
    table.clear(PlayerTracers)
end

local function createTracer(player)
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = SHHeroTracerColor
    tracer.Thickness = 1
    tracer.Transparency = 0.7
    PlayerTracers[player] = tracer

    RunService.RenderStepped:Connect(function()
        if not SHHeroTracerEnabled then
            tracer.Visible = false
            return
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
                tracer.To = Vector2.new(pos.X, pos.Y)
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        else
            tracer.Visible = false
        end
    end)
end

if state then
    task.spawn(function()
        while env.SHHeroTracer do
            local success, data = pcall(function()
                return game.ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
            end)
            if success and data then
                for name, info in pairs(data) do
                    if info.Role == "Sheriff" or info.Role == "Hero" then
                        local player = game.Players:FindFirstChild(name)
                        if player and not PlayerTracers[player] then
                            createTracer(player)
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        clearTracers()
    end)
else
    clearTracers()
end
end
})





local EspSection = Tab_Visual:Section({ 
    Title = "ESP / GUN" 
})



local GunEspEnabled = false
local SelectedGunEspMode = "Esp Name Gun"

Tab_Visual:Toggle({
    Title = "Gun Drop ESP",
    Desc = "",
    Value = false,
    Callback = function(Value)
        GunEspEnabled = Value
        local env = getgenv()
        env.GunEsp = Value

        local function clearGunESP()
            local gun = workspace:FindFirstChild("GunDrop", true)
            if gun then
                local highlight = gun:FindFirstChild("GunHighlight")
                local esp = gun:FindFirstChild("GunEsp")

                if highlight then highlight:Destroy() end
                if esp then esp:Destroy() end
            end
        end

        if not env.GunEsp then
            clearGunESP()
            return
        end

        task.spawn(function()
            while env.GunEsp do
                local gun = workspace:FindFirstChild("GunDrop", true)
                if gun then
                    if SelectedGunEspMode == "ESP Highlights Gun" and not gun:FindFirstChild("GunHighlight") then
                        local gunh = Instance.new("Highlight", gun)
                        gunh.Name = "GunHighlight"
                        gunh.FillColor = Color3.new(1, 0, 0)
                        gunh.OutlineColor = Color3.new(1, 1, 1)
                        gunh.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        gunh.FillTransparency = 0.4
                        gunh.OutlineTransparency = 0.5
                    end

                    if SelectedGunEspMode == "Esp Name Gun" and not gun:FindFirstChild("GunEsp") then
                        local esp = Instance.new("BillboardGui")
                        esp.Name = "GunEsp"
                        esp.Adornee = gun
                        esp.Size = UDim2.new(5, 0, 5, 0)
                        esp.AlwaysOnTop = true
                        esp.Parent = gun

                        local text = Instance.new("TextLabel", esp)
                        text.Name = "GunLabel"
                        text.Size = UDim2.new(1, 0, 1, 0)
                        text.BackgroundTransparency = 1
                        text.TextStrokeTransparency = 0
                        text.TextColor3 = Color3.fromRGB(0, 255, 0)
                        text.Font = Enum.Font.FredokaOne
                        text.TextSize = 16
                        text.Text = "Gun Drop"
                    end
                end
                task.wait(0.1)
            end
            clearGunESP()
        end)
    end
})

Tab_Visual:Dropdown({
    Title = "Select Esp Mode",
    Values = { "Esp Name Gun", "ESP Highlights Gun" },
    Value = "Esp Name Gun",
    Callback = function(option)
        SelectedGunEspMode = option
        WindUI:Notify({
            Title = "ESP Mode Changed",
            Content = "Selected: " .. option,
            Duration = 2
        })
    end
})




--[[

TELEPORT

]]--



local EspSection = Tab_Teleport:Section({ 
    Title = "TELEPORT MAP / LOBBY" 
})



Tab_Teleport:Button({
    Title = "Teleport Map",
    Desc = "",
    Callback = function()
        local map = workspace:FindFirstChild("CoinContainer", true)
        if not map or not map.Parent then return end

        local part = map:FindFirstChildWhichIsA("BasePart", true)
        local parts = map.Parent:FindFirstChildWhichIsA("BasePart", true)

        if Char and part and part.CFrame then
            Char:PivotTo(part.CFrame * CFrame.new(0, 2, 0))
        elseif Char and parts and parts.CFrame then
            Char:PivotTo(parts.CFrame * CFrame.new(0, 2, 0))
        elseif Root and part and part.CFrame then
            Root.CFrame = part.CFrame * CFrame.new(0, 2, 0)
        elseif Root and parts and parts.CFrame then
            Root.CFrame = parts.CFrame * CFrame.new(0, 2, 0)
        end
    end
})




Tab_Teleport:Button({
    Title = "Teleport to Lobby",
    Desc = "",
    Callback = function()
        local lobby = workspace:FindFirstChild("Lobby", true)
        if not lobby or not lobby.Parent then return end

        local part = lobby:FindFirstChildWhichIsA("BasePart", true)
        local parts = lobby.Parent:FindFirstChildWhichIsA("BasePart", true)

        if Char and part and part.CFrame then
            Char:PivotTo(part.CFrame * CFrame.new(0, 2, 0))
        elseif Char and parts and parts.CFrame then
            Char:PivotTo(parts.CFrame * CFrame.new(0, 2, 0))
        elseif Root and part and part.CFrame then
            Root.CFrame = part.CFrame * CFrame.new(0, 2, 0)
        elseif Root and parts and parts.CFrame then
            Root.CFrame = parts.CFrame * CFrame.new(0, 2, 0)
        end
    end
})








Window:OnClose(function()
    print("Window closed")
end)

Window:OnDestroy(function()
    print("Window destroyed")
end)