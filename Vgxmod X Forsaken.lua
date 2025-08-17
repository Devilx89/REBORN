local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Vgxmod X Forsaken",
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







-------------------------------------------------------------------------- MAIN ----------------------------------------------------------------------------------------
local Section = Tabs.Main:AddSection("Player / Stamina")
Tabs.Main:AddButton({
    Title = "Unlimited Stamina",
    Description = "Execute This Every Game",
    Callback = function()
        local StaminaModule = require(game.ReplicatedStorage.Systems.Character.Game.Sprinting)

        StaminaModule.StaminaLossDisabled = true
        task.spawn(function()
            while true do
                task.wait(0.1)
                StaminaModule.Stamina = StaminaModule.MaxStamina
                StaminaModule.StaminaChanged:Fire()
            end
        end)
    end
})










local Section = Tabs.Main:AddSection("Auto / Generator")

local repairing = false

local Toggle = Tabs.Main:AddToggle("AutoGen", {
    Title = "Auto Repair Generators",
    Description = "Toggle This Every Game",
    Default = false
})

Toggle:OnChanged(function(val)
    repairing = val
    if repairing then
        task.spawn(function()
            local plr = game.Players.LocalPlayer
            local gens = workspace.Map.Ingame.Map:GetChildren()

            local function doRepair(g)
                local rem = g:FindFirstChild("Remotes")
                local prog = g:FindFirstChild("Progress")
                if not rem or not prog then return end
                local rf = rem:FindFirstChild("RF")
                local re = rem:FindFirstChild("RE")

                while repairing and prog.Value < 100 do
                    if rf then pcall(function() rf:InvokeServer() end) end
                    if re then pcall(function() re:FireServer() end) end
                    wait(3)
                end
            end

            for i,v in pairs(gens) do
                if v:FindFirstChild("Remotes") and v:FindFirstChild("Progress") then
                    spawn(function() doRepair(v) end)
                end
            end
        end)
    end
end)








local Section = Tabs.Main:AddSection("Auto / Aimbot")


local AutoAimToggle = Tabs.Main:AddToggle("AutoAim", {
    Title = "Auto Aim",
    Default = false
})

local active = false
local aimDuration = 1.7
local aimTargets = { "Jason", "c00lkidd", "JohnDoe", "1x1x1x1", "Noli" }
local trackedAnimations = {
    ["103601716322988"] = true,
    ["133491532453922"] = true,
    ["86371356500204"] = true,
    ["76649505662612"] = true,
    ["81698196845041"] = true
}

local Humanoid, HRP = nil, nil
local lastTriggerTime = 0
local aiming = false
local originalWS, originalJP, originalAutoRotate = nil, nil, nil

AutoAimToggle:OnChanged(function(value)
    active = value
end)

local function getValidTarget()
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if killersFolder then
        for _, name in ipairs(aimTargets) do
            local target = killersFolder:FindFirstChild(name)
            if target and target:FindFirstChild("HumanoidRootPart") then
                return target.HumanoidRootPart
            end
        end
    end
    return nil
end

local function getPlayingAnimationIds()
    local ids = {}
    if Humanoid then
        for _, track in ipairs(Humanoid:GetPlayingAnimationTracks()) do
            if track.Animation and track.Animation.AnimationId then
                local id = track.Animation.AnimationId:match("%d+")
                if id then
                    ids[id] = true
                end
            end
        end
    end
    return ids
end

local function setupCharacter(char)
    Humanoid = char:WaitForChild("Humanoid")
    HRP = char:WaitForChild("HumanoidRootPart")
end

if game.Players.LocalPlayer.Character then
    setupCharacter(game.Players.LocalPlayer.Character)
end
game.Players.LocalPlayer.CharacterAdded:Connect(setupCharacter)

game:GetService("RunService").RenderStepped:Connect(function()
    if not active or not Humanoid or not HRP then return end

    local playing = getPlayingAnimationIds()
    local triggered = false
    for id in pairs(trackedAnimations) do
        if playing[id] then
            triggered = true
            break
        end
    end

    if triggered then
        lastTriggerTime = tick()
        aiming = true
    end

    if aiming and tick() - lastTriggerTime <= aimDuration then
        if not originalWS then
            originalWS = Humanoid.WalkSpeed
            originalJP = Humanoid.JumpPower
            originalAutoRotate = Humanoid.AutoRotate
        end

        Humanoid.AutoRotate = false
        HRP.AssemblyAngularVelocity = Vector3.zero

        local prediction = 4
        local targetHRP = getValidTarget()
        if targetHRP then
            local predictedPos = targetHRP.Position + (targetHRP.CFrame.LookVector * prediction)
            local direction = (predictedPos - HRP.Position).Unit
            local yRot = math.atan2(-direction.X, -direction.Z)
            HRP.CFrame = CFrame.new(HRP.Position) * CFrame.Angles(0, yRot, 0)
        end
    elseif aiming then
        aiming = false
        if originalWS and originalJP and originalAutoRotate ~= nil then
            Humanoid.WalkSpeed = originalWS
            Humanoid.JumpPower = originalJP
            Humanoid.AutoRotate = originalAutoRotate
            originalWS, originalJP, originalAutoRotate = nil, nil, nil
        end
    end
end)

































-------------------------------------------------------------------------- ESP ----------------------------------------------------------------------------------------

local Section = Tabs.Esp:AddSection("Esp / Highlights")

-- Killers ESP
local KillersESP = Tabs.Esp:AddToggle("KillersESP", {
    Title = "Killers ESP",
    Default = false
})

local killersFolder

local function addKillerESP(model)
    if model:IsA("Model") and not model:FindFirstChild("Killer_ESP_Highlight") then
        local esp = Instance.new("Highlight")
        esp.Name = "Killer_ESP_Highlight"
        esp.FillColor = Color3.fromRGB(255, 0, 0)
        esp.FillTransparency = 0.5
        esp.OutlineTransparency = 1
        esp.Adornee = model
        esp.Parent = model
    end
end

local function removeKillerESP(model)
    local esp = model:FindFirstChild("Killer_ESP_Highlight")
    if esp then esp:Destroy() end
end

local function refreshKillerESP()
    if killersFolder then
        for _, killer in ipairs(killersFolder:GetChildren()) do
            if KillersESP.Value then
                addKillerESP(killer)
            else
                removeKillerESP(killer)
            end
        end
    end
end

local function hookKillerFolder(folder)
    killersFolder = folder
    folder.ChildAdded:Connect(function(child)
        if KillersESP.Value then
            addKillerESP(child)
        end
    end)
    folder.ChildRemoved:Connect(function(child)
        removeKillerESP(child)
    end)
    refreshKillerESP()
end

local playersFolder = workspace:WaitForChild("Players")

playersFolder.ChildAdded:Connect(function(child)
    if child.Name == "Killers" then
        hookKillerFolder(child)
    end
end)

local existingKillers = playersFolder:FindFirstChild("Killers")
if existingKillers then
    hookKillerFolder(existingKillers)
end

KillersESP:OnChanged(function()
    refreshKillerESP()
end)

-- Survivors ESP
local SurvivorsESP = Tabs.Esp:AddToggle("SurvivorsESP", {
    Title = "Survivors ESP",
    Default = false
})

local survivorsFolder

local function addSurvivorESP(model)
    if model:IsA("Model") and not model:FindFirstChild("Survivor_ESP_Highlight") then
        local esp = Instance.new("Highlight")
        esp.Name = "Survivor_ESP_Highlight"
        esp.FillColor = Color3.fromRGB(0, 255, 0)
        esp.FillTransparency = 0.5
        esp.OutlineTransparency = 1
        esp.Adornee = model
        esp.Parent = model
    end
end

local function removeSurvivorESP(model)
    local esp = model:FindFirstChild("Survivor_ESP_Highlight")
    if esp then esp:Destroy() end
end

local function refreshSurvivorESP()
    if survivorsFolder then
        for _, survivor in ipairs(survivorsFolder:GetChildren()) do
            if SurvivorsESP.Value then
                addSurvivorESP(survivor)
            else
                removeSurvivorESP(survivor)
            end
        end
    end
end

local function hookSurvivorFolder(folder)
    survivorsFolder = folder
    folder.ChildAdded:Connect(function(child)
        if SurvivorsESP.Value then
            addSurvivorESP(child)
        end
    end)
    folder.ChildRemoved:Connect(function(child)
        removeSurvivorESP(child)
    end)
    refreshSurvivorESP()
end

playersFolder.ChildAdded:Connect(function(child)
    if child.Name == "Survivors" then
        hookSurvivorFolder(child)
    end
end)

local existingSurvivors = playersFolder:FindFirstChild("Survivors")
if existingSurvivors then
    hookSurvivorFolder(existingSurvivors)
end

SurvivorsESP:OnChanged(function()
    refreshSurvivorESP()
end)




local GeneratorESP = Tabs.Esp:AddToggle("GeneratorESP", {
    Title = "Generator ESP",
    Default = false
})

local highlighted = {}
local mapFolder

local function addHighlight(obj)
    if obj:IsA("Model") and not obj:FindFirstChild("GeneratorESP") then
        local h = Instance.new("Highlight")
        h.Name = "GeneratorESP"
        h.FillColor = Color3.new(1,1,1)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 1
        h.Adornee = obj
        h.Parent = obj
        highlighted[obj] = h
    end
end

local function removeHighlight(obj)
    if highlighted[obj] then
        highlighted[obj]:Destroy()
        highlighted[obj] = nil
    end
end

local function refreshESP()
    if not mapFolder then return end
    for _, obj in ipairs(mapFolder:GetChildren()) do
        if obj.Name == "Generator" or obj.Name:find("Generator") then
            if GeneratorESP.Value then
                addHighlight(obj)
            else
                removeHighlight(obj)
            end
        end
    end
end

local function hookMapFolder(folder)
    mapFolder = folder
    refreshESP()
    folder.ChildAdded:Connect(function(child)
        if child.Name == "Generator" or child.Name:find("Generator") then
            if GeneratorESP.Value then
                addHighlight(child)
            end
        end
    end)
    folder.ChildRemoved:Connect(function(child)
        removeHighlight(child)
    end)
end

local ingameFolder = workspace:WaitForChild("Map"):WaitForChild("Ingame")
if ingameFolder:FindFirstChild("Map") then
    hookMapFolder(ingameFolder.Map)
end
ingameFolder.ChildAdded:Connect(function(child)
    if child.Name == "Map" then
        hookMapFolder(child)
    end
end)

GeneratorESP:OnChanged(function()
    refreshESP()
end)








local ItemsESP = Tabs.Esp:AddToggle("ItemsESP", {
    Title = "Items ESP",
    Default = false
})

local player = game.Players.LocalPlayer
local highlighted = {}

local function rainbowColor(tickValue)
    local hue = tickValue % 1
    return Color3.fromHSV(hue, 1, 1)
end

local function addESP(item)
    if not item or highlighted[item] then return end
    local adorneePart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart") or item.PrimaryPart
    if not adorneePart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = adorneePart
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = "ESP_Billboard"
    billboard.Parent = item

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1,0,1,0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.ArialBold
    textLabel.TextStrokeTransparency = 0
    textLabel.TextColor3 = Color3.fromRGB(255,255,255)
    textLabel.Text = item.Name:upper()
    textLabel.Parent = billboard

    highlighted[item] = {label = textLabel}
end

local function removeESP(item)
    if highlighted[item] then
        if highlighted[item].label then highlighted[item].label.Parent:Destroy() end
        highlighted[item] = nil
    end
end

local function getCurrentMapFolder()
    return workspace:FindFirstChild("Map") 
       and workspace.Map:FindFirstChild("Ingame") 
       and workspace.Map.Ingame:FindFirstChild("Map")
end

local function refreshESP()
    local mapFolder = getCurrentMapFolder()
    if not mapFolder then return end

    -- Add ESP to new items
    for _, obj in ipairs(mapFolder:GetChildren()) do
        if (obj.Name == "Medkit" or obj.Name == "BloxyCola") and ItemsESP.Value then
            addESP(obj)
        end
    end

    -- Remove ESP from old/removed items
    for item, _ in pairs(highlighted) do
        if not item.Parent then
            removeESP(item)
        end
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    for item, data in pairs(highlighted) do
        if item and item.Parent then
            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart") or item.PrimaryPart
            if part and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (player.Character.HumanoidRootPart.Position - part.Position).Magnitude
                data.label.Text = item.Name:upper().." | "..math.floor(dist).." studs"
                data.label.TextColor3 = rainbowColor(tick())
            end
        else
            removeESP(item)
        end
    end
end)

-- Reapply ESP whenever the map folder changes (new round)
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Map" then
        task.wait(1)
        refreshESP()
    end
end)

ItemsESP:OnChanged(function() refreshESP() end)
refreshESP()




-------------------------------------------------------------------------- PLAYER ----------------------------------------------------------------------------------------






Window:SelectInfo(1)
