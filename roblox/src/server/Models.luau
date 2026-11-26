-- Models: bouwt de skibidi-kostuums uit blokjes (Parts), zodat je geen modellen hoeft te downloaden.
-- Plek in Roblox Studio: ServerScriptService > Models (ModuleScript)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local Models = {}

local WHITE = Color3.fromRGB(245, 245, 245)
local DARK = Color3.fromRGB(25, 25, 30)
local SILVER = Color3.fromRGB(190, 190, 200)

local ROT_UP = CFrame.Angles(0, 0, math.rad(90)) -- cilinder rechtop
local ROT_FWD = CFrame.Angles(0, math.rad(90), 0) -- cilinder naar voren

-- Maakt één blokje vast aan "anchor" (het lichaamsdeel waar het op zit)
local function add(folder: Instance, anchor: BasePart, size: Vector3, color: Color3, offset: CFrame, shape: string?, neon: boolean?)
	local p = Instance.new("Part")
	p.Size = size
	p.Color = color
	p.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
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

-- Skibidi Toilet: het hoofd steekt uit de wc-pot (vast aan het midden van het lichaam)
local function buildToilet(folder, root: BasePart, color: Color3, accent: Color3)
	add(folder, root, Vector3.new(1.4, 2.8, 2.8), color, CFrame.new(0, 0.4, 0) * ROT_UP, "Cylinder")
	add(folder, root, Vector3.new(0.2, 2.2, 2.2), DARK, CFrame.new(0, 1.15, 0) * ROT_UP, "Cylinder")
	add(folder, root, Vector3.new(1.8, 2.6, 1.8), color, CFrame.new(0, -1.3, 0))
	add(folder, root, Vector3.new(2.4, 0.4, 2.6), color, CFrame.new(0, -2.8, 0))
	add(folder, root, Vector3.new(2.6, 2.6, 0.9), color, CFrame.new(0, 1.2, 1.6))
	add(folder, root, Vector3.new(0.5, 0.15, 0.15), SILVER, CFrame.new(-0.9, 2.2, 1.1))
	add(folder, root, Vector3.new(2.7, 0.25, 1.0), accent, CFrame.new(0, 2.6, 1.6), nil, true)
end

-- Camera Man: camera als hoofd
local function buildCamera(folder, head: BasePart, color: Color3, accent: Color3)
	add(folder, head, Vector3.new(1.8, 1.4, 1.6), color, CFrame.new(0, 0.1, 0))
	add(folder, head, Vector3.new(0.6, 1, 1), DARK, CFrame.new(0, 0.1, -1.0) * ROT_FWD, "Cylinder")
	add(folder, head, Vector3.new(0.05, 0.7, 0.7), accent, CFrame.new(0, 0.1, -1.32) * ROT_FWD, "Cylinder", true)
	add(folder, head, Vector3.new(0.25, 0.25, 0.25), Color3.fromRGB(255, 40, 40), CFrame.new(0.6, 0.7, -0.5), "Ball", true)
end

-- Speaker Man: speaker als hoofd
local function buildSpeaker(folder, head: BasePart, color: Color3, accent: Color3)
	add(folder, head, Vector3.new(1.8, 2.2, 1.4), color, CFrame.new(0, 0.3, 0))
	add(folder, head, Vector3.new(0.1, 1.1, 1.1), SILVER, CFrame.new(0, -0.1, -0.72) * ROT_FWD, "Cylinder")
	add(folder, head, Vector3.new(0.12, 0.5, 0.5), accent, CFrame.new(0, -0.1, -0.75) * ROT_FWD, "Cylinder", true)
	add(folder, head, Vector3.new(0.1, 0.6, 0.6), SILVER, CFrame.new(0, 0.85, -0.72) * ROT_FWD, "Cylinder")
end

-- TV Man: tv als hoofd, het scherm gloeit
local function buildTv(folder, head: BasePart, color: Color3, accent: Color3)
	add(folder, head, Vector3.new(2.4, 1.8, 0.9), color, CFrame.new(0, 0.3, 0))
	add(folder, head, Vector3.new(2.0, 1.4, 0.1), accent, CFrame.new(0, 0.3, -0.46), nil, true)
	add(folder, head, Vector3.new(0.1, 1.0, 0.1), SILVER, CFrame.new(-0.4, 1.6, 0) * CFrame.Angles(0, 0, math.rad(25)))
	add(folder, head, Vector3.new(0.1, 1.0, 0.1), SILVER, CFrame.new(0.4, 1.6, 0) * CFrame.Angles(0, 0, math.rad(-25)))
end

local BUILDERS = { toilet = buildToilet, camera = buildCamera, speaker = buildSpeaker, tv = buildTv }

-- Trekt een karakter (speler of vijand) een skibidi-kostuum aan
function Models.dress(character: Model, kind: string, accent: Color3?)
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

	local old = character:FindFirstChild("Kostuum")
	if old then
		old:Destroy()
	end
	-- Hoeden en haar weg (ook als ze later nog laden)
	for _, c in character:GetChildren() do
		if c:IsA("Accessory") then
			c:Destroy()
		end
	end
	character.ChildAdded:Connect(function(c)
		if c:IsA("Accessory") then
			task.defer(function()
				c:Destroy()
			end)
		end
	end)

	-- Toilet: alleen het hoofd blijft zichtbaar. Andere: het hoofd wordt verstopt.
	local isToilet = T.costume == "toilet"
	for _, p in character:GetDescendants() do
		if p:IsA("BasePart") and p ~= root then
			if isToilet and p ~= head then
				p.Transparency = 1
			elseif not isToilet and p == head then
				p.Transparency = 1
			end
		elseif p:IsA("Decal") and p.Parent == head and not isToilet then
			p.Transparency = 1
		end
	end

	local folder = Instance.new("Model")
	folder.Name = "Kostuum"
	folder.Parent = character
	local build = BUILDERS[T.costume]
	if isToilet then
		build(folder, root, T.color, glow)
	else
		build(folder, head, T.color, glow)
	end

	if T.scale and T.scale ~= 1 then
		pcall(function()
			character:ScaleTo(T.scale)
		end)
	end
end

-- Maakt een vijand: een Roblox-poppetje met een kostuum en een Humanoid om te lopen
function Models.makeEnemy(kind: string, tint: Color3): Model
	local ok, model = pcall(function()
		return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
	end)
	if not ok or not model then
		-- Reserve: simpel poppetje als het mooie niet lukt
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
	Models.dress(model, kind, tint)
	return model
end

return Models
