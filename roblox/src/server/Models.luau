-- Models: bouwt de skibidi-kostuums uit blokjes (Parts), zodat je geen modellen hoeft te downloaden.
-- Plek in Roblox Studio: ServerScriptService > Models (ModuleScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local Models = {}

local WHITE = Color3.fromRGB(245, 245, 245)
local PORCELAIN = Color3.fromRGB(232, 236, 240)
local DARK = Color3.fromRGB(25, 25, 30)
local BLACK = Color3.fromRGB(12, 12, 14)
local SILVER = Color3.fromRGB(190, 192, 200)
local SKIN = Color3.fromRGB(234, 184, 146)
local WATER = Color3.fromRGB(40, 90, 140)
local RED = Color3.fromRGB(255, 40, 40)

local ROT_UP = CFrame.Angles(0, 0, math.rad(90)) -- cilinder rechtop
local ROT_FWD = CFrame.Angles(0, math.rad(90), 0) -- cilinder wijst naar voren

-- Maakt één blokje vast aan "anchor" (het lichaamsdeel waar het op zit)
-- shape: "Cylinder" of "Ball" of nil (blok). mat: Enum.Material of nil.
local function add(folder: Instance, anchor: BasePart, size: Vector3, color: Color3, offset: CFrame, shape: string?, mat: Enum.Material?)
	local p = Instance.new("Part")
	p.Size = size
	p.Color = color
	p.Material = mat or Enum.Material.SmoothPlastic
	if shape == "Cylinder" then
		p.Shape = Enum.PartType.Cylinder
	elseif shape == "Ball" then
		p.Shape = Enum.PartType.Ball
	end
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = size.Magnitude > 1
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.CFrame = anchor.CFrame * offset
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = anchor
	weld.Part1 = p
	weld.Parent = p
	p.Parent = folder
	return p
end

local NEON = Enum.Material.Neon
local METAL = Enum.Material.Metal
local GLASS = Enum.Material.Glass

---------------------------------------------------------------------
-- Onderdelen
---------------------------------------------------------------------

-- Skibidi-hoofd: kaal hoofd met ogen, wenkbrauwen en een open zingende mond
local function buildSkibidiHead(folder, head: BasePart, evil: boolean)
	local size = if evil then 2.1 else 1.9
	local y = 0.25
	add(folder, head, Vector3.one * size, SKIN, CFrame.new(0, y, 0), "Ball")
	-- oren
	add(folder, head, Vector3.one * 0.5, SKIN, CFrame.new(size / 2, y, 0.05), "Ball")
	add(folder, head, Vector3.one * 0.5, SKIN, CFrame.new(-size / 2, y, 0.05), "Ball")
	-- neus
	add(folder, head, Vector3.new(0.3, 0.4, 0.35), Color3.fromRGB(220, 165, 128), CFrame.new(0, y - 0.05, -size / 2))
	local front = -size / 2 + 0.12
	for _, s in { -1, 1 } do
		-- ogen
		add(folder, head, Vector3.one * 0.48, WHITE, CFrame.new(s * 0.38, y + 0.3, front), "Ball")
		local pupil = if evil then RED else BLACK
		add(folder, head, Vector3.one * 0.22, pupil, CFrame.new(s * 0.38, y + 0.3, front - 0.2), "Ball", if evil then NEON else nil)
		-- wenkbrauwen (boos = schuin)
		local tilt = if evil then s * 22 else s * -6
		add(folder, head, Vector3.new(0.55, 0.13, 0.12), Color3.fromRGB(70, 45, 30),
			CFrame.new(s * 0.38, y + 0.66, front - 0.12) * CFrame.Angles(0, 0, math.rad(tilt)))
	end
	-- open mond (aan het zingen)
	add(folder, head, Vector3.new(0.12, 0.55, 0.7), Color3.fromRGB(110, 20, 30), CFrame.new(0, y - 0.45, front - 0.06) * ROT_FWD, "Cylinder")
	add(folder, head, Vector3.new(0.5, 0.1, 0.1), WHITE, CFrame.new(0, y - 0.27, front - 0.12))
end

-- Skibidi Toilet: het hoofd steekt uit de wc-pot (vast aan het midden van het lichaam)
local function buildToilet(folder, root: BasePart, head: BasePart, color: Color3, accent: Color3, evil: boolean)
	-- voet en poot
	add(folder, root, Vector3.new(2.2, 0.4, 2.6), color, CFrame.new(0, -2.75, 0.2))
	add(folder, root, Vector3.new(1.6, 2.1, 1.8), color, CFrame.new(0, -1.6, 0.2))
	-- pot
	add(folder, root, Vector3.new(1.3, 3.0, 3.0), color, CFrame.new(0, -0.1, -0.1) * ROT_UP, "Cylinder")
	add(folder, root, Vector3.new(0.8, 2.4, 2.4), color, CFrame.new(0, -0.75, -0.1) * ROT_UP, "Cylinder")
	-- bril en water
	add(folder, root, Vector3.new(0.25, 3.15, 3.15), if evil then Color3.fromRGB(255, 200, 60) else PORCELAIN, CFrame.new(0, 0.65, -0.1) * ROT_UP, "Cylinder", if evil then METAL else nil)
	add(folder, root, Vector3.new(0.27, 2.25, 2.25), WATER, CFrame.new(0, 0.66, -0.1) * ROT_UP, "Cylinder", GLASS)
	-- nek
	add(folder, root, Vector3.new(1.0, 0.9, 0.9), SKIN, CFrame.new(0, 0.95, -0.1) * ROT_UP, "Cylinder")
	-- deksel omhoog
	add(folder, root, Vector3.new(0.15, 3.0, 3.0), color, CFrame.new(0, 2.0, 1.35) * CFrame.Angles(math.rad(-12), 0, 0) * ROT_FWD, "Cylinder")
	add(folder, root, Vector3.new(0.4, 0.2, 0.3), SILVER, CFrame.new(-0.7, 0.75, 1.3), nil, METAL)
	add(folder, root, Vector3.new(0.4, 0.2, 0.3), SILVER, CFrame.new(0.7, 0.75, 1.3), nil, METAL)
	-- stortbak
	add(folder, root, Vector3.new(2.8, 2.4, 1.0), color, CFrame.new(0, 1.3, 2.0))
	add(folder, root, Vector3.new(3.0, 0.25, 1.2), PORCELAIN, CFrame.new(0, 2.6, 2.0))
	add(folder, root, Vector3.new(0.2, 0.5, 0.5), SILVER, CFrame.new(0, 2.78, 2.0) * ROT_UP, "Cylinder", METAL)
	add(folder, root, Vector3.new(0.6, 0.15, 0.15), SILVER, CFrame.new(-1.15, 2.1, 1.45), nil, METAL)
	-- gloeiende streep
	add(folder, root, Vector3.new(2.4, 0.15, 0.05), accent, CFrame.new(0, 1.55, 1.48), nil, NEON)
	add(folder, root, Vector3.new(0.12, 0.12, 2.6), accent, CFrame.new(1.5, -0.1, -0.1), nil, NEON)
	add(folder, root, Vector3.new(0.12, 0.12, 2.6), accent, CFrame.new(-1.5, -0.1, -0.1), nil, NEON)

	buildSkibidiHead(folder, head, evil)
end

-- Camera Man: camera als hoofd
local function buildCamera(folder, head: BasePart, color: Color3, accent: Color3)
	add(folder, head, Vector3.new(1.9, 1.5, 1.7), color, CFrame.new(0, 0.15, 0.1), nil, METAL)
	add(folder, head, Vector3.new(1.95, 0.12, 1.75), BLACK, CFrame.new(0, -0.55, 0.1))
	-- handvat bovenop
	add(folder, head, Vector3.new(1.2, 0.22, 0.3), BLACK, CFrame.new(0, 1.15, 0.1))
	add(folder, head, Vector3.new(0.2, 0.3, 0.25), BLACK, CFrame.new(-0.5, 0.98, 0.1))
	add(folder, head, Vector3.new(0.2, 0.3, 0.25), BLACK, CFrame.new(0.5, 0.98, 0.1))
	-- zoeker aan de zijkant
	add(folder, head, Vector3.new(0.45, 0.45, 0.9), BLACK, CFrame.new(0.95, 0.6, 0.6))
	add(folder, head, Vector3.new(0.5, 0.5, 0.15), DARK, CFrame.new(0.95, 0.6, 1.1))
	-- lens
	add(folder, head, Vector3.new(0.8, 1.2, 1.2), BLACK, CFrame.new(0, 0.15, -1.05) * ROT_FWD, "Cylinder")
	add(folder, head, Vector3.new(0.18, 1.35, 1.35), SILVER, CFrame.new(0, 0.15, -1.42) * ROT_FWD, "Cylinder", METAL)
	add(folder, head, Vector3.new(0.05, 0.95, 0.95), accent, CFrame.new(0, 0.15, -1.52) * ROT_FWD, "Cylinder", NEON)
	add(folder, head, Vector3.new(0.05, 0.4, 0.4), BLACK, CFrame.new(0, 0.15, -1.55) * ROT_FWD, "Cylinder", GLASS)
	-- opname-lampje en knopjes
	add(folder, head, Vector3.one * 0.28, RED, CFrame.new(0.65, 0.78, -0.6), "Ball", NEON)
	for i = 0, 2 do
		add(folder, head, Vector3.new(0.08, 0.15, 0.15), SILVER, CFrame.new(-0.98, 0.45 - i * 0.3, 0.3), nil, METAL)
	end
	add(folder, head, Vector3.new(0.05, 0.18, 1.3), accent, CFrame.new(-0.97, -0.25, 0.1), nil, NEON)
end

-- Speaker Man: speaker als hoofd
local function buildSpeaker(folder, head: BasePart, color: Color3, accent: Color3)
	add(folder, head, Vector3.new(1.9, 2.3, 1.5), color, CFrame.new(0, 0.35, 0.1))
	add(folder, head, Vector3.new(2.0, 2.4, 0.1), BLACK, CFrame.new(0, 0.35, -0.66))
	-- grote woofer
	add(folder, head, Vector3.new(0.12, 1.35, 1.35), SILVER, CFrame.new(0, -0.05, -0.73) * ROT_FWD, "Cylinder", METAL)
	add(folder, head, Vector3.new(0.14, 1.05, 1.05), DARK, CFrame.new(0, -0.05, -0.75) * ROT_FWD, "Cylinder")
	add(folder, head, Vector3.new(0.16, 0.6, 0.6), Color3.fromRGB(45, 45, 50), CFrame.new(0, -0.05, -0.77) * ROT_FWD, "Cylinder")
	add(folder, head, Vector3.one * 0.38, accent, CFrame.new(0, -0.05, -0.8), "Ball", NEON)
	-- tweeter
	add(folder, head, Vector3.new(0.12, 0.65, 0.65), SILVER, CFrame.new(0, 1.0, -0.73) * ROT_FWD, "Cylinder", METAL)
	add(folder, head, Vector3.new(0.14, 0.4, 0.4), DARK, CFrame.new(0, 1.0, -0.75) * ROT_FWD, "Cylinder")
	-- schroefjes
	for _, sx in { -0.85, 0.85 } do
		for _, sy in { -0.7, 1.4 } do
			add(folder, head, Vector3.one * 0.12, SILVER, CFrame.new(sx, sy, -0.72), "Ball", METAL)
		end
	end
	-- gloeiende rand
	add(folder, head, Vector3.new(0.08, 2.3, 0.08), accent, CFrame.new(0.98, 0.35, -0.68), nil, NEON)
	add(folder, head, Vector3.new(0.08, 2.3, 0.08), accent, CFrame.new(-0.98, 0.35, -0.68), nil, NEON)
end

-- TV Man: tv als hoofd, met een gezicht op het scherm
local function buildTv(folder, head: BasePart, color: Color3, accent: Color3, evil: boolean)
	add(folder, head, Vector3.new(2.6, 1.9, 1.3), color, CFrame.new(0, 0.35, 0.2))
	add(folder, head, Vector3.new(1.9, 1.4, 0.8), color, CFrame.new(0, 0.35, 1.2))
	add(folder, head, Vector3.new(2.4, 1.7, 0.1), BLACK, CFrame.new(0, 0.35, -0.46))
	local screen = add(folder, head, Vector3.new(2.1, 1.4, 0.08), accent, CFrame.new(0, 0.35, -0.52), nil, NEON)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.PixelsPerStud = 50
	gui.LightInfluence = 0
	gui.Parent = screen
	local face = Instance.new("TextLabel")
	face.Size = UDim2.fromScale(1, 1)
	face.BackgroundTransparency = 1
	face.Text = if evil then ">:(" else ":D"
	face.TextScaled = true
	face.Font = Enum.Font.GothamBlack
	face.TextColor3 = BLACK
	face.Parent = gui
	-- knoppen
	add(folder, head, Vector3.new(0.12, 0.22, 0.22), SILVER, CFrame.new(1.32, 0.7, -0.1), "Cylinder", METAL)
	add(folder, head, Vector3.new(0.12, 0.22, 0.22), SILVER, CFrame.new(1.32, 0.3, -0.1), "Cylinder", METAL)
	-- antennes
	for _, s in { -1, 1 } do
		add(folder, head, Vector3.new(0.08, 1.3, 0.08), SILVER, CFrame.new(s * 0.45, 1.85, 0.3) * CFrame.Angles(0, 0, math.rad(-s * 28)), nil, METAL)
		add(folder, head, Vector3.one * 0.2, accent, CFrame.new(s * 0.78, 2.4, 0.3), "Ball", NEON)
	end
end

-- Pak met wit overhemd en stropdas (voor Camera, Speaker en TV Man)
local function buildSuit(folder, character: Model, suit: Color3, tie: Color3)
	local colors = {
		UpperTorso = suit, LowerTorso = suit,
		LeftUpperArm = suit, RightUpperArm = suit, LeftLowerArm = suit, RightLowerArm = suit,
		LeftHand = BLACK, RightHand = BLACK,
		LeftUpperLeg = suit, RightUpperLeg = suit, LeftLowerLeg = suit, RightLowerLeg = suit,
		LeftFoot = BLACK, RightFoot = BLACK,
		Torso = suit, ["Left Arm"] = suit, ["Right Arm"] = suit, ["Left Leg"] = suit, ["Right Leg"] = suit,
	}
	for name, c in colors do
		local p = character:FindFirstChild(name)
		if p and p:IsA("BasePart") then
			p.Color = c
		end
	end
	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if torso and torso:IsA("BasePart") then
		local front = -torso.Size.Z / 2
		add(folder, torso, Vector3.new(0.7, torso.Size.Y * 0.8, 0.06), WHITE, CFrame.new(0, torso.Size.Y * 0.1, front - 0.02))
		add(folder, torso, Vector3.new(0.22, torso.Size.Y * 0.65, 0.06), tie, CFrame.new(0, torso.Size.Y * 0.05, front - 0.05))
		add(folder, torso, Vector3.new(0.3, 0.2, 0.08), tie, CFrame.new(0, torso.Size.Y * 0.4, front - 0.06))
	end
end

-- Titan-harnas: schouders, borstplaat en een gloeiende kern
local function buildArmor(folder, character: Model, accent: Color3)
	for _, name in { "LeftUpperArm", "RightUpperArm" } do
		local arm = character:FindFirstChild(name)
		if arm and arm:IsA("BasePart") then
			add(folder, arm, Vector3.new(arm.Size.X + 0.5, 0.5, arm.Size.Z + 0.5), SILVER, CFrame.new(0, arm.Size.Y / 2, 0), nil, METAL)
		end
	end
	local torso = character:FindFirstChild("UpperTorso")
	if torso and torso:IsA("BasePart") then
		local front = -torso.Size.Z / 2
		add(folder, torso, Vector3.new(torso.Size.X * 0.85, torso.Size.Y * 0.7, 0.2), SILVER, CFrame.new(0, 0.1, front - 0.1), nil, METAL)
		add(folder, torso, Vector3.one * 0.6, accent, CFrame.new(0, 0.2, front - 0.25), "Ball", NEON)
		local light = Instance.new("PointLight")
		light.Color = accent
		light.Range = 14
		light.Brightness = 2
		light.Parent = torso
	end
end

---------------------------------------------------------------------
-- Kostuum aantrekken
---------------------------------------------------------------------

-- Trekt een karakter (speler of vijand) een skibidi-kostuum aan
function Models.dress(character: Model, kind: string, accent: Color3?, evil: boolean?)
	local T = Config.Characters[kind]
	if not T then
		return
	end
	local head = character:FindFirstChild("Head") :: BasePart?
	local root = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not head or not root then
		return
	end
	local glow = accent or Color3.fromRGB(255, 210, 63)
	local isEvil = evil == true or kind == "gman"

	local old = character:FindFirstChild("Kostuum")
	if old then
		old:Destroy()
	end
	-- Hoeden, haar en kleren weg (ook als ze later nog laden)
	local function strip(c: Instance)
		if c:IsA("Accessory") or c:IsA("Shirt") or c:IsA("Pants") or c:IsA("ShirtGraphic") or c:IsA("BodyColors") then
			task.defer(function()
				c:Destroy()
			end)
		end
	end
	for _, c in character:GetChildren() do
		strip(c)
	end
	character.ChildAdded:Connect(strip)

	-- Toilet: alleen het hoofd blijft over. Andere: het hoofd wordt verstopt.
	local isToilet = T.costume == "toilet"
	for _, p in character:GetDescendants() do
		if p:IsA("BasePart") and p ~= root then
			if isToilet or p == head then
				p.Transparency = 1
			end
		elseif p:IsA("Decal") and p.Parent == head then
			p.Transparency = 1
		end
	end

	local folder = Instance.new("Model")
	folder.Name = "Kostuum"
	folder.Parent = character
	if isToilet then
		buildToilet(folder, root, head, T.color, glow, isEvil)
	else
		if kind == "titan" then
			buildSuit(folder, character, Color3.fromRGB(40, 42, 50), glow)
			buildArmor(folder, character, Color3.fromRGB(90, 200, 255))
		else
			buildSuit(folder, character, T.suit or DARK, T.tie or glow)
		end
		if T.costume == "camera" then
			buildCamera(folder, head, T.color, if kind == "titan" then Color3.fromRGB(90, 200, 255) else glow)
		elseif T.costume == "speaker" then
			buildSpeaker(folder, head, T.color, glow)
		elseif T.costume == "tv" then
			buildTv(folder, head, T.color, glow, isEvil)
		end
	end

	if T.scale and T.scale ~= 1 then
		local ok, err = pcall(function()
			character:ScaleTo(T.scale)
		end)
		if not ok then
			warn("[Loaden Skibidi] groter maken lukte niet:", err)
		end
	end
end

-- Laat een vijand lopen met de standaard Roblox-loopanimatie
local WALK_ANIM = "rbxassetid://507777826"
local IDLE_ANIM = "rbxassetid://507766388"

function Models.animate(humanoid: Humanoid)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	local ok, walk, idle = pcall(function()
		local w = Instance.new("Animation")
		w.AnimationId = WALK_ANIM
		local i = Instance.new("Animation")
		i.AnimationId = IDLE_ANIM
		return animator:LoadAnimation(w), animator:LoadAnimation(i)
	end)
	if not ok then
		return
	end
	idle:Play()
	humanoid.Running:Connect(function(speed)
		if speed > 0.5 then
			if not walk.IsPlaying then
				walk:Play(0.15)
			end
			walk:AdjustSpeed(speed / 14)
		elseif walk.IsPlaying then
			walk:Stop(0.2)
		end
	end)
end

-- Maakt een vijand: een Roblox-poppetje met een kostuum en een Humanoid om te lopen
function Models.makeEnemy(kind: string, tint: Color3): Model
	local ok, model = pcall(function()
		return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
	end)
	if not ok or not model then
		warn("[Loaden Skibidi] kon geen R15-poppetje maken, gebruik reserve:", model)
		model = Instance.new("Model")
		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2, 2, 1)
		root.Transparency = 1
		root.Parent = model
		local head = Instance.new("Part")
		head.Name = "Head"
		head.Size = Vector3.new(1.2, 1.2, 1.2)
		head.CFrame = root.CFrame * CFrame.new(0, 1.6, 0)
		head.Parent = model
		local w = Instance.new("WeldConstraint")
		w.Part0 = root
		w.Part1 = head
		w.Parent = head
		local hum = Instance.new("Humanoid")
		hum.RigType = Enum.HumanoidRigType.R15
		hum.HipHeight = 2
		hum.Parent = model
		model.PrimaryPart = root
	end
	model.Name = Config.Characters[kind].name
	Models.dress(model, kind, tint, true)
	return model
end

-- Gouden standbeeld voor het plein
function Models.statue(cf: CFrame, scale: number)
	local model = Instance.new("Model")
	model.Name = "Standbeeld"
	local root = Instance.new("Part")
	root.Name = "Basis"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CFrame = cf
	root.Parent = model
	local head = Instance.new("Part")
	head.Name = "HoofdPunt"
	head.Size = Vector3.one
	head.Transparency = 1
	head.Anchored = true
	head.CanCollide = false
	head.CFrame = cf * CFrame.new(0, 1.6, 0)
	head.Parent = model
	local gold = Color3.fromRGB(255, 200, 60)
	buildToilet(model, root, head, gold, Color3.fromRGB(255, 255, 255), false)
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Transparency < 1 and p.Material ~= NEON then
			p.Material = METAL
			if p.Color ~= WATER then
				p.Color = gold
			end
		end
	end
	model.PrimaryPart = root
	model.Parent = workspace
	model:ScaleTo(scale)
	return model
end

return Models
