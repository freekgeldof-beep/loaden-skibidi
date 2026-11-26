-- GameClient: alles wat de speler ziet en indrukt (menu, HUD, toetsen).
-- Plek in Roblox Studio: StarterPlayer > StarterPlayerScripts > GameClient (LocalScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local ChooseCharacter = remotes:WaitForChild("ChooseCharacter") :: RemoteEvent
local AttackRemote = remotes:WaitForChild("Attack") :: RemoteEvent
local SpecialRemote = remotes:WaitForChild("Special") :: RemoteEvent
local GameState = remotes:WaitForChild("GameState") :: RemoteEvent

local player = Players.LocalPlayer

local YELLOW = Color3.fromRGB(255, 210, 63)
local BG = Color3.fromRGB(20, 18, 35)

---------------------------------------------------------------------
-- Kleine hulpjes om schermen te bouwen
---------------------------------------------------------------------
local function new(className: string, props: { [string]: any }, parent: Instance?): any
	local obj = Instance.new(className)
	for k, v in props do
		(obj :: any)[k] = v
	end
	if parent then
		obj.Parent = parent
	end
	return obj
end

local function corner(parent: Instance, r: number?)
	new("UICorner", { CornerRadius = UDim.new(0, r or 10) }, parent)
end

local function label(parent: Instance, text: string, size: number, props: { [string]: any }?)
	local l = new("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		TextSize = size,
		Font = Enum.Font.GothamBlack,
		TextColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 0, size + 6),
	}, parent)
	if props then
		for k, v in props do
			l[k] = v
		end
	end
	return l
end

local gui = new("ScreenGui", { Name = "LoadenSkibidi", ResetOnSpawn = false, IgnoreGuiInset = true }, player:WaitForChild("PlayerGui"))

---------------------------------------------------------------------
-- Menu: karakter kiezen
---------------------------------------------------------------------
local menu = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = BG, BackgroundTransparency = 0.15 }, gui)
label(menu, "LOADEN SKIBIDI", 54, { Position = UDim2.new(0, 0, 0.06, 0), TextColor3 = YELLOW })
label(menu, "Kies je skibidi-karakter en verover Alphahills", 20, { Position = UDim2.new(0, 0, 0.06, 64), Font = Enum.Font.GothamBold })

local cards = new("Frame", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.06, 110),
	Size = UDim2.new(0.9, 0, 0.6, 0),
}, menu)
new("UIGridLayout", {
	CellSize = UDim2.new(0, 210, 0, 170),
	CellPadding = UDim2.new(0, 12, 0, 12),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
}, cards)

local selected = "toilet"
local cardButtons: { [string]: TextButton } = {}
local STAT_NAMES = { "Kracht", "Snelheid", "Leven" }

local function refreshCards()
	for kind, btn in cardButtons do
		local stroke = btn:FindFirstChildOfClass("UIStroke") :: UIStroke
		stroke.Color = if kind == selected then YELLOW else Color3.fromRGB(70, 65, 100)
		stroke.Thickness = if kind == selected then 3 else 1
	end
end

for i, kind in Config.Order do
	local T = Config.Characters[kind]
	local btn = new("TextButton", {
		Text = "",
		AutoButtonColor = true,
		BackgroundColor3 = Color3.fromRGB(38, 34, 64),
		LayoutOrder = i,
	}, cards)
	corner(btn)
	new("UIStroke", { ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, btn)
	new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 8) }, btn)
	label(btn, T.name, 18, { TextXAlignment = Enum.TextXAlignment.Left })
	label(btn, T.desc, 13, {
		Position = UDim2.new(0, 0, 0, 26),
		Size = UDim2.new(1, 0, 0, 36),
		TextWrapped = true,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	for s = 1, 3 do
		local y = 70 + (s - 1) * 22
		label(btn, STAT_NAMES[s], 12, {
			Position = UDim2.new(0, 0, 0, y),
			Size = UDim2.new(0, 64, 0, 16),
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		local bar = new("Frame", { Position = UDim2.new(0, 68, 0, y + 4), Size = UDim2.new(1, -68, 0, 9), BackgroundColor3 = Color3.fromRGB(20, 18, 35) }, btn)
		corner(bar, 4)
		local fill = new("Frame", { Size = UDim2.fromScale(T.stats[s], 1), BackgroundColor3 = YELLOW }, bar)
		corner(fill, 4)
	end
	btn.MouseButton1Click:Connect(function()
		selected = kind
		refreshCards()
	end)
	cardButtons[kind] = btn
end
refreshCards()

local playBtn = new("TextButton", {
	Text = "SPELEN",
	Font = Enum.Font.GothamBlack,
	TextSize = 30,
	TextColor3 = BG,
	BackgroundColor3 = YELLOW,
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.8, 0),
	Size = UDim2.new(0, 240, 0, 60),
}, menu)
corner(playBtn, 14)
label(menu, "WASD lopen · Shift rennen · Spatie springen · Klik aanval · Q speciaal · E dash · M muziek", 15, {
	Position = UDim2.new(0, 0, 0.8, 72),
	Font = Enum.Font.GothamMedium,
	TextColor3 = Color3.fromRGB(200, 200, 220),
})

---------------------------------------------------------------------
-- HUD: golf, score, baas, berichten, cooldowns
---------------------------------------------------------------------
local hud = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false }, gui)
local waveLabel = label(hud, "Golf 1", 28, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 60),
	Size = UDim2.new(0, 260, 0, 34),
	TextXAlignment = Enum.TextXAlignment.Right,
	TextStrokeTransparency = 0.5,
})
local scoreLabel = label(hud, "Score 0", 20, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 94),
	Size = UDim2.new(0, 260, 0, 24),
	TextXAlignment = Enum.TextXAlignment.Right,
	TextStrokeTransparency = 0.5,
	Font = Enum.Font.GothamBold,
})
local leftLabel = label(hud, "", 15, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 120),
	Size = UDim2.new(0, 260, 0, 20),
	TextXAlignment = Enum.TextXAlignment.Right,
	TextStrokeTransparency = 0.5,
	Font = Enum.Font.GothamMedium,
})

local bossFrame = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 56),
	Size = UDim2.new(0, 420, 0, 46),
	BackgroundTransparency = 1,
	Visible = false,
}, hud)
local bossName = label(bossFrame, "", 18, { TextColor3 = Color3.fromRGB(255, 122, 138), TextStrokeTransparency = 0.5 })
local bossBar = new("Frame", { Position = UDim2.new(0, 0, 0, 26), Size = UDim2.new(1, 0, 0, 14), BackgroundColor3 = Color3.fromRGB(40, 20, 30) }, bossFrame)
corner(bossBar, 6)
local bossFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(255, 60, 80) }, bossBar)
corner(bossFill, 6)

local msg = label(hud, "", 56, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.35),
	Size = UDim2.new(1, 0, 0, 70),
	TextColor3 = YELLOW,
	TextStrokeTransparency = 0.3,
	TextTransparency = 1,
	TextStrokeColor3 = BG,
})

local function showMsg(text: string)
	msg.Text = text
	msg.TextTransparency = 0
	msg.TextStrokeTransparency = 0.3
	TweenService:Create(msg, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.2), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
end

-- Cooldown-blokjes linksonder: Klik / Q / E
local cdRow = new("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.new(0, 20, 1, -20),
	Size = UDim2.new(0, 220, 0, 60),
	BackgroundTransparency = 1,
}, hud)
new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 10) }, cdRow)
local function cdBox(text: string)
	local f = new("Frame", { Size = UDim2.new(0, 60, 0, 60), BackgroundColor3 = Color3.fromRGB(38, 34, 64), BackgroundTransparency = 0.2 }, cdRow)
	corner(f)
	local shade = new("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.fromScale(1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.4,
	}, f)
	corner(shade)
	label(f, text, 16, { Size = UDim2.fromScale(1, 1) })
	return shade
end
local cdAttack = cdBox("Klik")
local cdSpecial = cdBox("Q")
local cdDash = cdBox("E")

-- Game over-scherm
local over = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = BG, BackgroundTransparency = 0.25, Visible = false }, gui)
label(over, "GAME OVER", 64, { Position = UDim2.fromScale(0, 0.35), TextColor3 = Color3.fromRGB(255, 80, 100) })
local overStats = label(over, "", 24, { Position = UDim2.new(0, 0, 0.35, 80), Font = Enum.Font.GothamBold })

---------------------------------------------------------------------
-- Besturing
---------------------------------------------------------------------
local lastAttack, lastSpecial, lastDash = -100, -100, -100
local myKind: string? = nil

local function myCharacter()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hum and root and hum.Health > 0 then
		return hum, root
	end
	return nil, nil
end

local function playSound(id: string, volume: number)
	local s = new("Sound", { SoundId = id, Volume = volume }, gui)
	s:Play()
	Debris:AddItem(s, 2)
end

local function onAttack(_, inputState)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local now = os.clock()
	if now - lastAttack >= Config.AttackCooldown and myCharacter() then
		lastAttack = now
		AttackRemote:FireServer()
		playSound("rbxasset://sounds/swordslash.wav", 0.5)
	end
	return Enum.ContextActionResult.Sink
end

local function onSpecial(_, inputState)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local now = os.clock()
	if now - lastSpecial >= Config.SpecialCooldown and myCharacter() then
		lastSpecial = now
		SpecialRemote:FireServer()
		playSound("rbxasset://sounds/electronicpingshort.wav", 0.6)
	end
	return Enum.ContextActionResult.Sink
end

-- Dash: een korte, snelle duw in de richting waarin je loopt
local function onDash(_, inputState)
	if inputState ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end
	local hum, root = myCharacter()
	local now = os.clock()
	if hum and root and now - lastDash >= Config.DashCooldown then
		lastDash = now
		local dir = hum.MoveDirection
		if dir.Magnitude < 0.1 then
			dir = root.CFrame.LookVector
		end
		dir = Vector3.new(dir.X, 0, dir.Z).Unit
		local att = new("Attachment", {}, root)
		local push = new("LinearVelocity", {
			Attachment0 = att,
			MaxForce = 1e6,
			VectorVelocity = dir * Config.DashSpeed,
			RelativeTo = Enum.ActuatorRelativeTo.World,
		}, root)
		Debris:AddItem(push, 0.18)
		Debris:AddItem(att, 0.18)
	end
	return Enum.ContextActionResult.Sink
end

-- Rennen met Shift
local function onSprint(_, inputState)
	local hum = myCharacter()
	if hum and myKind then
		local base = Config.Characters[myKind].speed
		if inputState == Enum.UserInputState.Begin then
			hum.WalkSpeed = base * Config.SprintMultiplier
		elseif inputState == Enum.UserInputState.End or inputState == Enum.UserInputState.Cancel then
			hum.WalkSpeed = base
		end
	end
	return Enum.ContextActionResult.Pass
end

local function bindControls()
	-- "true" = Roblox maakt ook knoppen op het scherm voor telefoon/tablet
	ContextActionService:BindAction("Aanval", onAttack, true, Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2)
	ContextActionService:BindAction("Speciaal", onSpecial, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonX)
	ContextActionService:BindAction("Dash", onDash, true, Enum.KeyCode.E, Enum.KeyCode.ButtonB)
	ContextActionService:BindAction("Rennen", onSprint, false, Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL3)
	ContextActionService:SetTitle("Aanval", "Klap")
	ContextActionService:SetTitle("Speciaal", "Q")
	ContextActionService:SetTitle("Dash", "Dash")
end

local function unbindControls()
	for _, name in { "Aanval", "Speciaal", "Dash", "Rennen" } do
		ContextActionService:UnbindAction(name)
	end
end

-- Cooldown-blokjes bijwerken
RunService.RenderStepped:Connect(function()
	if not hud.Visible then
		return
	end
	local now = os.clock()
	local function set(shade: Frame, last: number, cd: number)
		local left = math.clamp(1 - (now - last) / cd, 0, 1)
		shade.Size = UDim2.fromScale(1, left)
	end
	set(cdAttack, lastAttack, Config.AttackCooldown)
	set(cdSpecial, lastSpecial, Config.SpecialCooldown)
	set(cdDash, lastDash, Config.DashCooldown)
end)

---------------------------------------------------------------------
-- Menu -> spel
---------------------------------------------------------------------
local function showMenu()
	myKind = nil
	unbindControls()
	hud.Visible = false
	over.Visible = false
	bossFrame.Visible = false
	menu.Visible = true
end

playBtn.MouseButton1Click:Connect(function()
	myKind = selected
	menu.Visible = false
	hud.Visible = true
	ChooseCharacter:FireServer(selected)
	bindControls()
end)

-- Score uit het scorebord (leaderstats) halen
task.spawn(function()
	local stats = player:WaitForChild("leaderstats")
	local score = stats:WaitForChild("Score") :: IntValue
	local function upd()
		scoreLabel.Text = "Score " .. score.Value
	end
	score.Changed:Connect(upd)
	upd()
end)

---------------------------------------------------------------------
-- Berichten van de server
---------------------------------------------------------------------
GameState.OnClientEvent:Connect(function(data)
	if data.type == "wave" then
		waveLabel.Text = "Golf " .. data.wave
		if data.boss then
			showMsg("BAAS: " .. string.upper(data.boss))
		else
			showMsg("GOLF " .. data.wave)
		end
	elseif data.type == "left" then
		leftLabel.Text = data.left .. " vijanden over"
	elseif data.type == "boss" then
		if data.hp and data.hp > 0 then
			bossFrame.Visible = true
			if data.name then
				bossName.Text = data.name
			end
			bossFill.Size = UDim2.fromScale(math.clamp(data.hp / data.max, 0, 1), 1)
		else
			bossFrame.Visible = false
		end
	elseif data.type == "gameover" then
		if myKind == nil then
			return -- je speelde niet mee
		end
		unbindControls()
		hud.Visible = false
		over.Visible = true
		overStats.Text = "Je haalde golf " .. data.wave .. " · " .. scoreLabel.Text
		task.delay(4, showMenu)
	end
end)

showMenu()
