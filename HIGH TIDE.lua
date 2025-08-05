
--[[
 
              V G X M O D   X   H I G H  T I D E

]]



local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Vgxmod X High Tide",
    SubTitle = "by Pkgx1",
    TabWidth = 160,
    Size = UDim2.fromOffset(470, 260),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "book-open" }),
    Main = Window:AddTab({ Title = "Main", Icon = "layout-dashboard" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "puzzle" }), -- updated here
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











------------------------ BUTTON ------------------------














------------------------ Auto Farm ------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Teams = game:GetService("Teams")
local LocalPlayer = Players.LocalPlayer
local Live = workspace:WaitForChild("Live")

-- Utility: Get HRP
local function getHRP()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char:FindFirstChild("HumanoidRootPart")
end

-- Enemy checker with all team matchups
local function isEnemy(player)
    if not player or player == LocalPlayer then return false end

    local myTeam = LocalPlayer.Team
    local theirTeam = player.Team

    if myTeam == nil or theirTeam == nil then
        return true -- Free For All mode
    end

    local red = Teams:FindFirstChild("Red Pirates")
    local blue = Teams:FindFirstChild("Blue Pirates")
    local infected = Teams:FindFirstChild("Infected")
    local marauders = Teams:FindFirstChild("Marauders")
    local attackers = Teams:FindFirstChild("Attackers")
    local defenders = Teams:FindFirstChild("Defenders")
    local purple = Teams:FindFirstChild("Purple Plunderers")
    local yellow = Teams:FindFirstChild("Yellow Plunderers")
    local redBucc = Teams:FindFirstChild("Red Buccaneers")
    local blueBucc = Teams:FindFirstChild("Blue Buccaneers")

    if (myTeam == red and theirTeam == blue) or (myTeam == blue and theirTeam == red) then
        return true
    end
    if (myTeam == infected and theirTeam == marauders) or (myTeam == marauders and theirTeam == infected) then
        return true
    end
    if (myTeam == attackers and theirTeam == defenders) or (myTeam == defenders and theirTeam == attackers) then
        return true
    end
    if (myTeam == purple and theirTeam == yellow) or (myTeam == yellow and theirTeam == purple) then
        return true
    end
    if (myTeam == redBucc and theirTeam == blueBucc) or (myTeam == blueBucc and theirTeam == redBucc) then
        return true
    end

    return false
end

-- Toggle (in Fluent UI)
local ToggleAutoFarm = Tabs.Main:AddToggle("ToggleAutoFarm", {
    Title = "Kill All",
    Default = false
})

local autofarmConnection

ToggleAutoFarm:OnChanged(function(state)
    if state then
        autofarmConnection = RunService.Stepped:Connect(function()
            local HRP = getHRP()
            if not HRP then return end

            for _, target in pairs(Live:GetChildren()) do
                if target:IsA("Model") and target.Name ~= LocalPlayer.Name then
                    local targetHRP = target:FindFirstChild("HumanoidRootPart")
                    local humanoid = target:FindFirstChildOfClass("Humanoid")
                    local player = Players:FindFirstChild(target.Name)

                    if targetHRP and humanoid and humanoid.Health > 0 and isEnemy(player) then
                        local offset = HRP.CFrame.LookVector * 5
                        targetHRP.CFrame = HRP.CFrame + offset
                        targetHRP.Anchored = true
                    end
                end
            end
        end)
    else
        if autofarmConnection then
            autofarmConnection:Disconnect()
            autofarmConnection = nil
        end
    end
end)




Tabs.Main:AddParagraph({
    Title = "Gun & Melee 1 hit",
    Content = "Instant Kill high damage"
})

------------------------ Instant kill------------------------
Tabs.Main:AddToggle("Toggle_InstantKill", {
    Title = "Instant Kill (Gun Damage)",
    Default = false
}):OnChanged(function(state)
    local lp = game:GetService("Players").LocalPlayer
    local char = workspace.Live:FindFirstChild(lp.Name)
    if not char then return end

    local stats = char:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("GunDamageMultiplier") then
        stats.GunDamageMultiplier.Value = state and math.huge or 1
    end
end)




------------------------ Melee ------------------------
local ToggleMeleeDamage = Tabs.Main:AddToggle("ToggleMeleeDamage", {
    Title = "Instant Kill (Melee Damage)",
    Default = false
})

local meleeDamageConnection

ToggleMeleeDamage:OnChanged(function(state)
    if state then
        meleeDamageConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local char = workspace.Live:FindFirstChild(game.Players.LocalPlayer.Name)
            if char and char:FindFirstChild("Stats") and char.Stats:FindFirstChild("MeleeDamageMultiplier") then
                char.Stats.MeleeDamageMultiplier.Value = 999
            end
        end)
    else
        if meleeDamageConnection then
            meleeDamageConnection:Disconnect()
            meleeDamageConnection = nil
        end
    end
end)
































------------------------ Esp enemy ------------------------
local ToggleEsp= Tabs.Combat:AddToggle("EnemyESP", {
    Title = "ESP Enemy",
    Default = false
})

local espConnections = {}
local espDrawings = {}

local function clearESP()
    for _, con in pairs(espConnections) do pcall(function() con:Disconnect() end) end
    espConnections = {}
    for _, drawings in pairs(espDrawings) do
        for _, d in pairs(drawings) do pcall(function() d:Remove() end) end
    end
    espDrawings = {}
end

local function isEnemy(plr)
    local localPlr = game.Players.LocalPlayer
    if plr == localPlr then return false end
    if plr.Team ~= nil and localPlr.Team ~= nil then
        return plr.Team ~= localPlr.Team
    end
    return true -- fallback if no team system
end

local function isInCombat(plr)
    if not plr.Character then return false end
    local toolEquipped = plr.Character:FindFirstChildOfClass("Tool")
    return toolEquipped ~= nil
end

local function startESP()
    local camera = workspace.CurrentCamera
    local localPlayer = game.Players.LocalPlayer

    for _, plr in ipairs(game.Players:GetPlayers()) do
        if isEnemy(plr) then
            local function createESP()
                if espDrawings[plr] then return end

                espDrawings[plr] = {
                    name = Drawing.new("Text"),
                    box = Drawing.new("Square"),
                    tracer = Drawing.new("Line"),
                    health = Drawing.new("Text"),
                    distance = Drawing.new("Text"),
                }

                local esp = espDrawings[plr]
                for _, d in pairs(esp) do
                    d.Visible = false
                    d.Color = Color3.fromRGB(255, 0, 0)
                    d.Thickness = 1
                    d.Transparency = 1
                end

                esp.name.Size = 14
                esp.name.Center = true
                esp.name.Outline = true

                esp.health.Size = 13
                esp.health.Center = true
                esp.health.Outline = true

                esp.distance.Size = 13
                esp.distance.Center = true
                esp.distance.Outline = true

                esp.box.Filled = false

                local con = game:GetService("RunService").RenderStepped:Connect(function()
                    if isEnemy(plr) and isInCombat(plr) and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                        if not hum or hum.Health <= 0 then
                            for _, d in pairs(esp) do d.Visible = false end
                            return
                        end

                        local pos, visible = camera:WorldToViewportPoint(hrp.Position)
                        if visible then
                            -- Box size
                            local top = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
                            local bottom = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                            local boxWidth = 60
                            local boxHeight = bottom.Y - top.Y

                            -- Tracer
                            esp.tracer.Visible = true
                            esp.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            esp.tracer.To = Vector2.new(pos.X, pos.Y)

                            -- Box
                            esp.box.Visible = true
                            esp.box.Position = Vector2.new(top.X - boxWidth / 2, top.Y)
                            esp.box.Size = Vector2.new(boxWidth, boxHeight)

                            -- Name
                            esp.name.Visible = true
                            esp.name.Text = plr.Name
                            esp.name.Position = Vector2.new(pos.X, pos.Y - 40)

                            -- Health
                            esp.health.Visible = true
                            esp.health.Text = "HP: " .. math.floor(hum.Health)
                            esp.health.Position = Vector2.new(pos.X, pos.Y - 25)

                            -- Distance
                            esp.distance.Visible = true
                            local dist = math.floor((localPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                            esp.distance.Text = dist .. "m"
                            esp.distance.Position = Vector2.new(pos.X, pos.Y - 10)
                        else
                            for _, d in pairs(esp) do d.Visible = false end
                        end
                    else
                        for _, d in pairs(esp) do d.Visible = false end
                    end
                end)

                table.insert(espConnections, con)
            end

            createESP()
        end
    end

    -- Update for new players
    table.insert(espConnections, game.Players.PlayerAdded:Connect(function(plr)
        task.wait(1)
        if isEnemy(plr) then
            startESP()
        end
    end))

    table.insert(espConnections, game.Players.PlayerRemoving:Connect(function(plr)
        if espDrawings[plr] then
            for _, obj in pairs(espDrawings[plr]) do obj:Remove() end
            espDrawings[plr] = nil
        end
    end))
end

ToggleEsp:OnChanged(function(state)
    if state then
        startESP()
        Fluent:Notify({ Title = "ESP", Content = "Enemy ESP ON ", Duration = 4 })
    else
        clearESP()
        Fluent:Notify({ Title = "ESP", Content = "Enemy ESP OFF ", Duration = 4 })
    end
end)





Tabs.Combat:AddParagraph({
    Title = "Gun Menu",
    Content = ""
})

------------------------ RAPID FIRE ------------------------
Tabs.Combat:AddToggle("Toggle_RapidFire", {
    Title = "Rapid Fire",
    Default = false
}):OnChanged(function(state)
    local lp = game:GetService("Players").LocalPlayer
    local char = workspace.Live:FindFirstChild(lp.Name)
    if not char then return end

    local stats = char:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("FireRateMultiplier") then
        stats.FireRateMultiplier.Value = state and math.huge or 1
    end
end)



------------------------ no reload ------------------------
-- Fluent Toggle for No Reload Delay
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Add to your desired Fluent tab
local Toggle = Tabs.Combat:AddToggle("NoReloadDelay", {
    Title = "No Reload",
    Default = false
})

local reloadConnection

Toggle:OnChanged(function(state)
    if state then
        reloadConnection = RunService.Heartbeat:Connect(function()
            local char = workspace.Live:FindFirstChild(LocalPlayer.Name)
            if char and char:FindFirstChild("Stats") then
                local stat = char.Stats:FindFirstChild("ReloadSpeedMultiplier")
                if stat then
                    stat.Value = math.huge
                end
            end
        end)
    else
        if reloadConnection then
            reloadConnection:Disconnect()
        end
    end
end)



------------------------ Instant Gun charge ------------------------
local ToggleInstantCharge = Tabs.Combat:AddToggle("ToggleInstantCharge", {
    Title = "Instant Gun Charge",
    Default = false
})

ToggleInstantCharge:OnChanged(function(enabled)
    local char = workspace.Live:FindFirstChild(Players.LocalPlayer.Name)
    if char and char:FindFirstChild("Stats") then
        local stats = char.Stats

        local dmgCancel = stats:FindFirstChild("DamageCancelsGunCharge")
        local chargeTime = stats:FindFirstChild("GunChargeTime")

        if dmgCancel and chargeTime then
            dmgCancel.Value = not enabled -- false when enabled
            chargeTime.Value = enabled and 0 or 1 -- 0 for instant
        end
    end
end)



Tabs.Combat:AddParagraph({
    Title = "Melee Menu",
    Content = ""
})

------------------------ No Melee Slash delay ------------------------
local ToggleMeleeCooldown = Tabs.Combat:AddToggle("ToggleMeleeCooldown", {
    Title = "No Slash Delay",
    Default = false
})

local meleeCooldownConnection

ToggleMeleeCooldown:OnChanged(function(state)
    if state then
        meleeCooldownConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local char = workspace.Live:FindFirstChild(game.Players.LocalPlayer.Name)
            if char and char:FindFirstChild("Stats") and char.Stats:FindFirstChild("MeleeCooldownMultiplier") then
                char.Stats.MeleeCooldownMultiplier.Value = 0
            end
        end)
    else
        if meleeCooldownConnection then
            meleeCooldownConnection:Disconnect()
            meleeCooldownConnection = nil
        end
    end
end)




Tabs.Misc:AddParagraph({
    Title = "God Mode",
    Content = "Immunity all damage Melee & Gun"
})

------------------------ misc ------------------------
local ToggleGunResist = Tabs.Misc:AddToggle("ToggleGunResist", {
    Title = "Gun Damage Immunity",
    Default = false
})

local gunResistConn

ToggleGunResist:OnChanged(function(state)
    if state then
        gunResistConn = game:GetService("RunService").RenderStepped:Connect(function()
            local char = workspace.Live:FindFirstChild(game.Players.LocalPlayer.Name)
            if char and char:FindFirstChild("Stats") and char.Stats:FindFirstChild("GunDamageReduction") then
                char.Stats.GunDamageReduction.Value = 999
            end
        end)
    else
        if gunResistConn then
            gunResistConn:Disconnect()
            gunResistConn = nil
        end
    end
end)

local ToggleMeleeImmunity = Tabs.Misc:AddToggle("ToggleMeleeImmunity", {
    Title = "Melee Damage Immunity",
    Default = false
})

local meleeImmunityConnection

ToggleMeleeImmunity:OnChanged(function(state)
    if state then
        meleeImmunityConnection = game:GetService("RunService").RenderStepped:Connect(function()
            local char = workspace.Live:FindFirstChild(game.Players.LocalPlayer.Name)
            if char and char:FindFirstChild("Stats") and char.Stats:FindFirstChild("MeleeDamageReduction") then
                char.Stats.MeleeDamageReduction.Value = 999
            end
        end)
    else
        if meleeImmunityConnection then
            meleeImmunityConnection:Disconnect()
            meleeImmunityConnection = nil
        end
    end
end)



------------------------ Unli Oxygen ------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local oxygenConnection

local ToggleOxygen = Tabs.Misc:AddToggle("ToggleOxygen", {
    Title = "Unlimited Oxygen",
    Default = false
})

ToggleOxygen:OnChanged(function(state)
    if state then
        oxygenConnection = RunService.Heartbeat:Connect(function()
            local liveChar = workspace:FindFirstChild("Live")
            if not liveChar then return end

            local myChar = liveChar:FindFirstChild(LocalPlayer.Name)
            if not myChar then return end

            local stats = myChar:FindFirstChild("Stats")
            if not stats then return end

            local oxygen = stats:FindFirstChild("Oxygen")
            if oxygen then
                oxygen.Value = 100
            end
        end)
    else
        if oxygenConnection then
            oxygenConnection:Disconnect()
            oxygenConnection = nil
        end
    end
end)


------------------------ End ------------------------




Window:SelectInfo(1)
