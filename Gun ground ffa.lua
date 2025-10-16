
local repo = "https://raw.githubusercontent.com/Devilx89/Jwuwekkeledkdndnd/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
Title = "Vgxmod Hub",
Footer = "version: 1.6",
Icon = 94858886314945,
NotifySide = "Right",
ShowCustomCursor = true,
})

local InfoTab = Window:AddTab("Info", "info")
local InfoLeft = InfoTab:AddLeftGroupbox("Credits")
local InfoRight = InfoTab:AddRightGroupbox("Discord")

InfoLeft:AddLabel("Made By : Pkgx1")
InfoLeft:AddLabel("Discord : https://discord.gg/n9gtmefsjc")
InfoLeft:AddDivider()
InfoLeft:AddLabel("You Can Request Script")
InfoLeft:AddLabel("On Discord !!!!!!!!?????")
InfoLeft:AddDivider()

InfoRight:AddLabel("Discord Link")
InfoRight:AddButton({
Text = "Copy",	
Func = function()
setclipboard("https://discord.gg/n9gtmefsjc")
Library:Notify({
Title = "Copied!",
Description = "Paste it on your browser",
Time = 4,
})
end,
})

local MainTab = Window:AddTab("Main", "sword")
local MainLeft = MainTab:AddLeftGroupbox("Aimbot Control")
local MiscRight = MainTab:AddLeftGroupbox("Misc Control")
local MainRight = MainTab:AddRightGroupbox("Esp Control")




MainLeft:AddToggle("HitboxToggle", {
	Text = "Enable Bullet Track",
	Default = false,
	Callback = function(Value)
		getgenv().Disabled = Value
	end,
})

MainLeft:AddInput("HitboxSizeInput", {
	Default = "10",
	Numeric = true,
	ClearTextOnFocus = true,
	Text = "Bullet Track Value",
	Placeholder = "Enter Value...",
	Callback = function(Value)
		local num = tonumber(Value)
		if num then
			getgenv().HeadSize = math.clamp(num, 1, 100)
		end
	end,
})

getgenv().HeadSize = 10
getgenv().Disabled = false

game:GetService("RunService").RenderStepped:Connect(function()
	if getgenv().Disabled then
		for _, player in next, game:GetService("Players"):GetPlayers() do
			if player.Name ~= game:GetService("Players").LocalPlayer.Name then
				pcall(function()
					local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if hrp then
						hrp.Size = Vector3.new(getgenv().HeadSize, getgenv().HeadSize, getgenv().HeadSize)
						hrp.Transparency = 1
						hrp.BrickColor = BrickColor.new("Really black")
						hrp.Material = Enum.Material.Neon
						hrp.CanCollide = false
					end
				end)
			end
		end
	end
end)













MainLeft:AddToggle("AimbotToggle", {
	Text = "Enable Aimbot",
	Default = false,
	Callback = function(Value)
		getgenv().AimbotEnabled = Value
	end,
})

MainLeft:AddDropdown("AimbotSmoothDropdown", {
	Values = { "Smooth", "Mid", "High", "Very High" },
	Default = 1,
	Multi = false,
	Text = "Aimbot Strength",
	Searchable = true,
	Callback = function(Value)
		local strengthMap = {
			["Smooth"] = 0.05,
			["Mid"] = 0.1,
			["High"] = 0.2,
			["Very High"] = 0.35
		}
		getgenv().AIM_STRENGTH = strengthMap[Value] or 0.1
	end,
})

MainLeft:AddCheckbox("AimbotCircleCheckbox", {
	Text = "Show FOV Circle",
	Default = true,
	Callback = function(Value)
		getgenv().ShowAimbotCircle = Value
		if getgenv().AimbotCircle then
			getgenv().AimbotCircle.Visible = Value and getgenv().AimbotEnabled
		end
	end,
})

MainLeft:AddCheckbox("WallCheckCheckbox", {
	Text = "Enable Wall Check",
	Default = true,
	Callback = function(Value)
		getgenv().WallCheck = Value
	end,
})

MainLeft:AddSlider("AimbotFOVSlider", {
	Text = "Aimbot FOV",
	Default = 50,
	Min = 10,
	Max = 300,
	Rounding = 0,
	Callback = function(Value)
		getgenv().FovRadius = Value
		if getgenv().AimbotCircle then
			getgenv().AimbotCircle.Size = UDim2.new(0, Value * 2, 0, Value * 2)
		end
	end,
})

getgenv().AimbotEnabled = false
getgenv().ShowAimbotCircle = true
getgenv().WallCheck = true
getgenv().AIM_FOV = 10
getgenv().AIM_STRENGTH = 0.1
getgenv().FovRadius = 50

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "MobileAimbotUI"
ScreenGui.Parent = game.CoreGui

local Circle = Instance.new("Frame")
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.Size = UDim2.new(0, getgenv().FovRadius * 2, 0, getgenv().FovRadius * 2)
Circle.BackgroundTransparency = 1
Circle.BorderSizePixel = 0
Circle.Visible = getgenv().ShowAimbotCircle and getgenv().AimbotEnabled
Circle.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke", Circle)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 0)
UIStroke.Transparency = 0.8

local UICorner = Instance.new("UICorner", Circle)
UICorner.CornerRadius = UDim.new(1, 0)

getgenv().AimbotCircle = Circle

local function isVisible(part)
	if not getgenv().WallCheck then return true end
	local origin = Camera.CFrame.Position
	local direction = (part.Position - origin)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, direction, params)
	if not result then return true end
	return result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestTarget()
	local closest, shortestDist = nil, getgenv().FovRadius
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
			local hrp = p.Character.HumanoidRootPart
			local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
				if dist < shortestDist and isVisible(hrp) then
					shortestDist = dist
					closest = hrp
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if not Camera then return end
	Circle.Visible = getgenv().ShowAimbotCircle and getgenv().AimbotEnabled
	Circle.Size = UDim2.new(0, getgenv().FovRadius * 2, 0, getgenv().FovRadius * 2)
	Circle.Position = UDim2.new(0.5, 0, 0.5, 0)

	if not getgenv().AimbotEnabled then return end

	local target = getClosestTarget()
	if target then
		local look = Camera.CFrame.LookVector:Lerp((target.Position - Camera.CFrame.Position).Unit, getgenv().AIM_STRENGTH)
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + look)
	end
end)
















MainRight:AddToggle("PlayTeamESP", {
	Text = "ESP Enemy",
	Default = false,
	Callback = function(Value)
		getgenv().ESPEnabled = Value
	end,
})

getgenv().ESPEnabled = false
getgenv().ESPColor = Color3.fromRGB(0, 255, 0)
getgenv().ESPFillTransparency = 1
getgenv().ESPOutlineTransparency = 0

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local targetTeam = Teams:FindFirstChild("Play")

local highlights = {}

local function makeHighlight(char)
	if not char then return nil end
	local h = Instance.new("Highlight")
	h.Adornee = char
	h.FillColor = getgenv().ESPColor
	h.OutlineColor = getgenv().ESPColor
	h.FillTransparency = getgenv().ESPFillTransparency
	h.OutlineTransparency = getgenv().ESPOutlineTransparency
	h.Parent = char
	return h
end

local function removeHighlight(player)
	local h = highlights[player]
	if h and h.Parent then
		h:Destroy()
	end
	highlights[player] = nil
end

local function updatePlayer(player)
	removeHighlight(player)
	if not getgenv().ESPEnabled then return end
	if not player or not player.Character then return end
	local teamMatches = false
	if targetTeam then
		teamMatches = (player.Team == targetTeam)
	else
		teamMatches = (player.Team and player.Team.Name == "Play")
	end
	if teamMatches and player.Character.Parent then
		highlights[player] = makeHighlight(player.Character)
	end
end

for _, p in ipairs(Players:GetPlayers()) do
	p.CharacterAdded:Connect(function()
		task.wait(0.1)
		updatePlayer(p)
	end)
	p.CharacterRemoving:Connect(function()
		removeHighlight(p)
	end)
	updatePlayer(p)
end

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function()
		task.wait(0.1)
		updatePlayer(p)
	end)
	p.CharacterRemoving:Connect(function()
		removeHighlight(p)
	end)
	updatePlayer(p)
end)

RunService.Heartbeat:Connect(function()
	for p, h in pairs(highlights) do
		if not getgenv().ESPEnabled or not p.Character or not p.Character.Parent then
			removeHighlight(p)
		else
			if h and h.Parent then
				h.FillColor = getgenv().ESPColor
				h.OutlineColor = getgenv().ESPColor
				h.FillTransparency = getgenv().ESPFillTransparency
				h.OutlineTransparency = getgenv().ESPOutlineTransparency
			end
		end
	end
end)






MiscRight:AddToggle("BunnyHopToggle", {
	Text = "Enable Bunny Hop",
	Default = false,
	Callback = function(Value)
		getgenv().BhopEnabled = Value
	end,
})

getgenv().BhopEnabled = false

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

RunService.RenderStepped:Connect(function()
	if getgenv().BhopEnabled and Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air then
		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	Humanoid = char:WaitForChild("Humanoid")
end)



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

