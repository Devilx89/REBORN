local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Vgxmod X 99 Nights in the Forest",
    SubTitle = "by Pkgx1",
    TabWidth = 160,
    Size = UDim2.fromOffset(470, 260),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftAlt
})

local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "info" }),    
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Esp = Window:AddTab({ Title = "Esp", Icon = "eye" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Item = Window:AddTab({ Title = "Item", Icon = "package" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "radar" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
}




-------------------------------------- INFO -------------------------------------




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
















-------------------------------------- PLAYER -------------------------------------
-- Already defined at the top globally
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local currentSpeed = 16
local speedEnabled = false
local currentJump = 50
local jumpEnabled = false

-- Reuse one Player section (don't redefine `Section`)
local sectionPlayer = Tabs.Player:AddSection("Player / Feature")

-- WalkSpeed Toggle
Tabs.Player:AddToggle("WalkSpeedToggle", {
	Title = "WalkSpeed",
	Default = false,
	Callback = function(state)
		speedEnabled = state
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if hum then
			hum.WalkSpeed = speedEnabled and currentSpeed or 16
		end
	end,
})

-- WalkSpeed Input
Tabs.Player:AddInput("WalkSpeedInput", {
	Title = "Set Value",
	Default = tostring(currentSpeed),
	Numeric = true,
	Callback = function(val)
		local num = tonumber(val)
		if num then
			currentSpeed = math.clamp(num, 1, 300)
			if speedEnabled then
				local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if hum then hum.WalkSpeed = currentSpeed end
			end
		end
	end,
})

-- JumpPower Toggle
Tabs.Player:AddToggle("JumpPowerToggle", {
	Title = "JumpPower",
	Default = false,
	Callback = function(state)
		jumpEnabled = state
		local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = jumpEnabled and currentJump or 50
		end
	end,
})

-- JumpPower Input
Tabs.Player:AddInput("JumpPowerInput", {
	Title = "Set Value",
	Default = tostring(currentJump),
	Numeric = true,
	Callback = function(val)
		local num = tonumber(val)
		if num then
			currentJump = math.clamp(num, 1, 300)
			if jumpEnabled then
				local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local hum = char:FindFirstChildWhichIsA("Humanoid")
				if hum then hum.JumpPower = currentJump end
			end
		end
	end,
})

-- Reapply after respawn
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.25)
	if speedEnabled then
		local hum = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then hum.WalkSpeed = currentSpeed end
	end
	if jumpEnabled then
		local hum = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = currentJump
		end
	end
end)






-------------------------------------- ESP -------------------------------------
local Section = Tabs.Esp:AddSection("Esp / Player")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local espEnabled = false
local rainbowESP = {}
local colorSpeed = 2

-- Add toggle to Esp tab
local Toggle = Tabs.Esp:AddToggle("RainbowNameESP", {
    Title = "Esp Player",
    Default = false
})

-- Create BillboardGui
local function createESP(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("Head") then return end
    if rainbowESP[player] then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "RainbowNameESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = character:FindFirstChild("Head")

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = player.DisplayName
    text.TextColor3 = Color3.fromRGB(255, 0, 0)
    text.TextStrokeTransparency = 0.5
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Parent = billboard

    billboard.Parent = character
    rainbowESP[player] = text
end

-- Remove ESP
local function removeESP(player)
    local char = player.Character
    if char and char:FindFirstChild("RainbowNameESP") then
        char.RainbowNameESP:Destroy()
    end
    rainbowESP[player] = nil
end

-- Rainbow update
RunService.RenderStepped:Connect(function(dt)
    if not espEnabled then return end
    for player, label in pairs(rainbowESP) do
        local t = tick() * colorSpeed
        label.TextColor3 = Color3.fromHSV((t % 5) / 5, 1, 1)
    end
end)

-- Toggle handler
Toggle:OnChanged(function(state)
    espEnabled = state
    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            createESP(player)
        end

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                task.wait(1)
                createESP(player)
            end)
        end)

        Players.PlayerRemoving:Connect(removeESP)
    else
        for player, _ in pairs(rainbowESP) do
            removeESP(player)
        end
        rainbowESP = {}
    end
end)



local Section = Tabs.Esp:AddSection("Esp / Name")

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local folder = workspace:WaitForChild("Characters")

local activeESPs = {}
local isRunning = false

local function clearESP()
	for model, gui in pairs(activeESPs) do
		if gui and gui.Parent then gui:Destroy() end
	end
	table.clear(activeESPs)
end

local function createESP(model)
	if activeESPs[model] then return end
	if not model:IsA("Model") or model.Name == localPlayer.Name then return end
	local head = model:FindFirstChild("Head")
	if not head then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = "ESP"
	gui.Adornee = head
	gui.Size = UDim2.new(0, 100, 0, 20)
	gui.StudsOffset = Vector3.new(0, 2, 0)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 10000
	gui.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = model.Name
	label.TextColor3 = Color3.new(1, 1, 0)
	label.TextStrokeTransparency = 0.5
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.Parent = gui

	activeESPs[model] = gui
end

local function refresh()
	for model, esp in pairs(activeESPs) do
		if not model or not model.Parent then
			if esp then esp:Destroy() end
			activeESPs[model] = nil
		end
	end

	for _, model in pairs(folder:GetChildren()) do
		createESP(model)
	end
end

local function loop()
	isRunning = true
	task.spawn(function()
		while isRunning do
			refresh()
			task.wait(10)
		end
	end)
end

Tabs.Esp:AddToggle("CharactersESP", {
	Title = "Mob ESP",
	Default = false,
	Callback = function(state)
		if state then
			loop()
		else
			isRunning = false
			clearESP()
		end
	end
})


local espFolder = game:GetService("CoreGui"):FindFirstChild("OneESPPerItem") or Instance.new("Folder", game:GetService("CoreGui"))
espFolder.Name = "OneESPPerItem"

local connections = {}
local tracked = {}

local function clearESP()
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    espFolder:ClearAllChildren()
    table.clear(tracked)
end

local function getESPPart(item)
    if item:IsA("Model") then
        if item.PrimaryPart then return item.PrimaryPart end
        for _, v in ipairs(item:GetDescendants()) do
            if v:IsA("BasePart") then return v end
        end
    elseif item:IsA("BasePart") then
        return item
    end
end

local function addESP(item)
    if tracked[item] then return end
    local part = getESPPart(item)
    if not part then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 120, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Name = item.Name .. "_ESP"
    billboard.Parent = espFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = item.Name
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(255, 255, 0)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0.4
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    tracked[item] = true
end

local function setupESP()
    local itemsFolder = workspace:FindFirstChild("Items")
    if not itemsFolder then return end

    for _, item in ipairs(itemsFolder:GetChildren()) do
        addESP(item)
    end

    table.insert(connections, itemsFolder.ChildAdded:Connect(function(item)
        task.wait(0.1)
        addESP(item)
    end))

    table.insert(connections, itemsFolder.ChildRemoved:Connect(function(item)
        local esp = espFolder:FindFirstChild(item.Name .. "_ESP")
        if esp then esp:Destroy() end
        tracked[item] = nil
    end))
end

-- ⬇️ PLACE THIS WHEREVER YOU SET YOUR TOGGLES
local EspItem = Tabs.Esp:AddToggle("ItemESP_Toggle", {
    Title = "Esp Item",
    Default = false
})

EspItem:OnChanged(function(state)
    if state then
        setupESP()
    else
        clearESP()
    end
end)









local Section = Tabs.Esp:AddSection("Esp / Custom")















-------------------------------------- COMBAT -------------------------------------
local Section = Tabs.Combat:AddSection("Safety / Feature")



local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")

local floatHeight = 20
local floatEnabled = false
local bodyPos = nil
local floatConnection

-- List of friendly NPCs to exclude from float targeting
local excluded = {
    ["Pelt Trader"] = true,
    ["Furniture Trader"] = true,
    ["Fairy"] = true,
    ["Missing Kids"] = true,
    ["Bunny"] = true
}

-- UI Toggle under COMBAT tab
local Toggle1 = Tabs.Combat:AddToggle("AutoFloatNearMob", {
    Title = "Auto Float Near Mob",
    Default = false
})

Toggle1:OnChanged(function(state)
    floatEnabled = state

    if not state then
        -- Turn off and clean up
        if bodyPos then
            bodyPos:Destroy()
            bodyPos = nil
        end
        if floatConnection then
            floatConnection:Disconnect()
            floatConnection = nil
        end
    else
        -- Enable float logic
        floatConnection = RunService.Heartbeat:Connect(function()
            local closest = nil
            local shortestDist = math.huge

            for _, model in ipairs(workspace.Characters:GetChildren()) do
                if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model.Name ~= LocalPlayer.Name then
                    if not excluded[model.Name] then
                        local dist = (HRP.Position - model.HumanoidRootPart.Position).Magnitude
                        if dist < 20 and dist < shortestDist then
                            closest = model
                            shortestDist = dist
                        end
                    end
                end
            end

            if closest then
                if not bodyPos then
                    bodyPos = Instance.new("BodyPosition")
                    bodyPos.Name = "FloatBP"
                    bodyPos.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bodyPos.P = 10000
                    bodyPos.D = 1000
                    bodyPos.Parent = HRP
                end
                bodyPos.Position = closest.HumanoidRootPart.Position + Vector3.new(0, floatHeight, 0)
            elseif bodyPos then
                bodyPos:Destroy()
                bodyPos = nil
            end
        end)
    end
end)




local Section = Tabs.Combat:AddSection("Combat / Feature")

local folder = workspace:WaitForChild("Characters")
local localPlayer = game.Players.LocalPlayer
local running = false
local currentSize = Vector3.new(5, 5, 5)

-- Function to apply hitbox size
local function applyHitbox()
	for _, model in pairs(folder:GetChildren()) do
		if model:IsA("Model") and model.Name ~= localPlayer.Name then
			local root = model:FindFirstChild("HumanoidRootPart")
			if root then
				root.Size = currentSize
				root.Transparency = 1
				root.CanCollide = false
				root.Material = Enum.Material.ForceField
			end
		end
	end
end

-- Toggle
Tabs.Combat:AddToggle("HitboxToggle", {
	Title = "Hitbox Mob",
	Description = "",
	Default = false,
	Callback = function(state)
		running = state
	end
})

-- Input for size with limit
Tabs.Combat:AddInput("HitboxInput", {
	Title = "Hitbox Size",
	Description = "",
	Placeholder = "",
	Numeric = true,
	Callback = function(val)
		local num = tonumber(val)
		if num and num > 0 then
			if num > 1000 then num = 1000 end
			currentSize = Vector3.new(num, num, num)
			applyHitbox()
		end
	end
})

-- Auto-apply every 10s if enabled
task.spawn(function()
	while true do
		if running then
			applyHitbox()
		end
		task.wait(10)
	end
end)






local Section = Tabs.Combat:AddSection("Kill Aura")
-------------------------------------- ITEM -------------------------------------
local Section = Tabs.Item:AddSection("Chest / Feature")

Tabs.Item:AddButton({
	Title = "Open All Chests",
	Description = "Instantly open all",
	Callback = function()
		for _, item in ipairs(workspace:GetDescendants()) do
			if item:IsA("ProximityPrompt") and item.Name == "ProximityInteraction" then
				pcall(function()
					fireproximityprompt(item, 1, true)
				end)
			end
		end
	end,
})

local Section = Tabs.Item:AddSection("Get / Item")


-------------------------------------- TELEPORT -------------------------------------
local Section = Tabs.Teleport:AddSection("Teleport / Feature")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Create UI Tab/Button

Tabs.Teleport:AddButton({
    Title = "Tp Campground",
    Description = "Teleport you to Map.Campground",
    Callback = function()
        local target = workspace:FindFirstChild("Map"):FindFirstChild("Campground")

        if target then
            local foundPart
            for _, child in pairs(target:GetDescendants()) do
                if child:IsA("BasePart") then
                    foundPart = child
                    break
                end
            end

            if foundPart then
                hrp.CFrame = foundPart.CFrame + Vector3.new(0, 5, 0)
            else
                warn("No BasePart found in Campground.")
            end
        else
            warn("Campground not found.")
        end
    end
})


































Window:SelectInfo(1)
