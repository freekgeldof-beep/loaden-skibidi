-- Map: bouwt de stad Alphahills automatisch: wegen met strepen, gebouwen met ramen,
-- winkels, parken met bomen, lantaarnpalen, auto's en een plein met een gouden standbeeld.
-- Plek in Roblox Studio: ServerScriptService > Map (ModuleScript)
-- Heb je zelf een stad gebouwd? Noem je eigen model "Alphahills" in Workspace,
-- dan bouwt dit script niets en gebruikt het spel jouw stad.

local Lighting = game:GetService("Lighting")

local Map = {}

Map.CELL = 70 -- grootte van één huizenblok + weg
Map.ROAD = 20 -- breedte van de weg
Map.HALF = 4 -- aantal blokken vanaf het midden naar de rand
Map.LIMIT = Map.CELL * Map.HALF + Map.CELL / 2 -- rand van de stad

local rng = Random.new()

local BUILDING_COLORS = {
	Color3.fromRGB(235, 225, 205), Color3.fromRGB(200, 120, 100), Color3.fromRGB(120, 150, 190),
	Color3.fromRGB(230, 190, 120), Color3.fromRGB(160, 170, 180), Color3.fromRGB(190, 140, 190),
	Color3.fromRGB(110, 120, 140),
}
local NEON_COLORS = {
	Color3.fromRGB(255, 210, 63), Color3.fromRGB(77, 210, 255), Color3.fromRGB(255, 77, 160), Color3.fromRGB(150, 255, 120),
}
local SHOP_NAMES = { "SKIBIDI SHOP", "PIZZA", "TOILET STORE", "CAMERA'S", "FRIET", "GAME ZONE", "IJSJES", "SPEAKERS" }
local CAR_COLORS = {
	Color3.fromRGB(220, 40, 40), Color3.fromRGB(40, 110, 220), Color3.fromRGB(250, 250, 250),
	Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 200, 0), Color3.fromRGB(60, 180, 90),
}

local function block(parent: Instance, name: string, size: Vector3, cf: CFrame | Vector3, color: Color3, material: Enum.Material?, shape: Enum.PartType?)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	if typeof(cf) == "Vector3" then
		p.Position = cf
	else
		p.CFrame = cf
	end
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	if shape then
		p.Shape = shape
	end
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function sign(part: BasePart, face: Enum.NormalId, text: string, color: Color3)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.PixelsPerStud = 20
	gui.LightInfluence = 0
	gui.Parent = part
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.Font = Enum.Font.GothamBlack
	t.TextColor3 = color
	t.Parent = gui
end

-- Hoog gebouw met rijen ramen (een glazen band per verdieping)
local function addTower(parent: Instance, x: number, z: number, w: number, d: number)
	local floors = rng:NextInteger(4, 14)
	local h = floors * 9 + 4
	local color = BUILDING_COLORS[rng:NextInteger(1, #BUILDING_COLORS)]
	block(parent, "Gebouw", Vector3.new(w, h, d), Vector3.new(x, 0.6 + h / 2, z), color, Enum.Material.Concrete)
	local glass = if rng:NextNumber() < 0.5 then Color3.fromRGB(150, 200, 255) else Color3.fromRGB(255, 230, 160)
	for f = 1, floors do
		local y = 0.6 + f * 9 - 3
		local band = block(parent, "Ramen", Vector3.new(w + 0.3, 3.2, d + 0.3), Vector3.new(x, y, z), glass, Enum.Material.Glass)
		band.Reflectance = 0.15
		band.Transparency = 0.1
	end
	-- dakrand en antenne
	block(parent, "Dak", Vector3.new(w + 1, 1.5, d + 1), Vector3.new(x, 0.6 + h + 0.75, z), Color3.fromRGB(60, 60, 70), Enum.Material.Metal)
	if rng:NextNumber() < 0.4 then
		block(parent, "Antenne", Vector3.new(0.6, 14, 0.6), Vector3.new(x, 0.6 + h + 8, z), Color3.fromRGB(180, 180, 190), Enum.Material.Metal)
		local lamp = block(parent, "Lampje", Vector3.one * 1.4, Vector3.new(x, 0.6 + h + 15.5, z), Color3.fromRGB(255, 40, 40), Enum.Material.Neon, Enum.PartType.Ball)
		lamp.CanCollide = false
	end
	if rng:NextNumber() < 0.5 then
		local neon = NEON_COLORS[rng:NextInteger(1, #NEON_COLORS)]
		block(parent, "Lichtrand", Vector3.new(w + 1.2, 0.8, d + 1.2), Vector3.new(x, 0.6 + h - 0.2, z), neon, Enum.Material.Neon)
	end
end

-- Laag winkeltje met een gekleurde luifel en een naambord
local function addShop(parent: Instance, x: number, z: number, w: number, d: number, faceDir: number)
	local h = 14
	local color = BUILDING_COLORS[rng:NextInteger(1, #BUILDING_COLORS)]
	block(parent, "Winkel", Vector3.new(w, h, d), Vector3.new(x, 0.6 + h / 2, z), color, Enum.Material.Brick)
	local neon = NEON_COLORS[rng:NextInteger(1, #NEON_COLORS)]
	local front = z + faceDir * (d / 2)
	-- etalage, luifel en bord aan de straatkant
	local win = block(parent, "Etalage", Vector3.new(w - 4, 6, 0.4), Vector3.new(x, 4.5, front + faceDir * 0.1), Color3.fromRGB(170, 220, 255), Enum.Material.Glass)
	win.Transparency = 0.3
	block(parent, "Luifel", Vector3.new(w - 2, 0.6, 4), CFrame.new(x, 9, front + faceDir * 2) * CFrame.Angles(math.rad(faceDir * 12), 0, 0), neon, Enum.Material.Fabric)
	local board = block(parent, "Bord", Vector3.new(w - 6, 3, 0.4), Vector3.new(x, 12, front + faceDir * 0.3), Color3.fromRGB(25, 25, 35))
	sign(board, if faceDir < 0 then Enum.NormalId.Front else Enum.NormalId.Back, SHOP_NAMES[rng:NextInteger(1, #SHOP_NAMES)], neon)
end

-- Park met gras, bomen, bankjes en een vijver
local function addPark(parent: Instance, cx: number, cz: number, size: number)
	block(parent, "Gras", Vector3.new(size, 0.8, size), Vector3.new(cx, 0.4, cz), Color3.fromRGB(90, 170, 80), Enum.Material.Grass)
	local pond = block(parent, "Vijver", Vector3.new(1, 14, 14), CFrame.new(cx, 0.85, cz) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(60, 140, 200), Enum.Material.Glass, Enum.PartType.Cylinder)
	pond.Transparency = 0.2
	pond.Size = Vector3.new(0.2, 14, 14)
	for _ = 1, 7 do
		local a = rng:NextNumber(0, math.pi * 2)
		local r = rng:NextNumber(10, size / 2 - 4)
		local x, z = cx + math.cos(a) * r, cz + math.sin(a) * r
		local th = rng:NextNumber(6, 10)
		block(parent, "Stam", Vector3.new(th, 1.4, 1.4), CFrame.new(x, 0.8 + th / 2, z) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(110, 75, 45), Enum.Material.Wood, Enum.PartType.Cylinder)
		local green = Color3.fromRGB(rng:NextInteger(40, 80), rng:NextInteger(140, 190), rng:NextInteger(50, 80))
		local leaves = block(parent, "Blad", Vector3.one * rng:NextNumber(6, 9), Vector3.new(x, 0.8 + th + 1.5, z), green, Enum.Material.Grass, Enum.PartType.Ball)
		leaves.CanCollide = false
		local top = block(parent, "Blad", Vector3.one * 4.5, Vector3.new(x + 1, 0.8 + th + 4.5, z - 0.5), green, Enum.Material.Grass, Enum.PartType.Ball)
		top.CanCollide = false
	end
	for _, s in { -1, 1 } do
		local bx = cx + s * (size / 2 - 5)
		block(parent, "Bankje", Vector3.new(1.6, 0.5, 6), Vector3.new(bx, 2, cz), Color3.fromRGB(140, 90, 50), Enum.Material.WoodPlanks)
		block(parent, "Leuning", Vector3.new(0.4, 1.6, 6), Vector3.new(bx + s * 0.8, 3, cz), Color3.fromRGB(140, 90, 50), Enum.Material.WoodPlanks)
	end
end

local function addStreetLight(parent: Instance, x: number, z: number)
	block(parent, "Paal", Vector3.new(0.8, 16, 0.8), Vector3.new(x, 8.6, z), Color3.fromRGB(50, 50, 55), Enum.Material.Metal)
	local lamp = block(parent, "Lamp", Vector3.new(2.4, 0.8, 2.4), Vector3.new(x, 16.8, z), Color3.fromRGB(255, 235, 180), Enum.Material.Neon)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 220, 160)
	light.Range = 30
	light.Brightness = 1.5
	light.Shadows = false
	light.Parent = lamp
end

local function addCar(parent: Instance, x: number, z: number, alongX: boolean)
	local car = Instance.new("Model")
	car.Name = "Auto"
	local rot = if alongX then CFrame.Angles(0, math.rad(90), 0) else CFrame.new()
	local base = CFrame.new(x, 0, z) * rot
	local color = CAR_COLORS[rng:NextInteger(1, #CAR_COLORS)]
	block(car, "Body", Vector3.new(5, 2, 10), base * CFrame.new(0, 1.9, 0), color, Enum.Material.SmoothPlastic)
	block(car, "Cabine", Vector3.new(4.6, 1.8, 5), base * CFrame.new(0, 3.8, 0.5), color, Enum.Material.SmoothPlastic)
	local glass = block(car, "Ruit", Vector3.new(4.7, 1.4, 5.1), base * CFrame.new(0, 3.8, 0.5), Color3.fromRGB(40, 60, 90), Enum.Material.Glass)
	glass.Transparency = 0.2
	for _, wx in { -2.5, 2.5 } do
		for _, wz in { -3.2, 3.2 } do
			block(car, "Wiel", Vector3.new(0.8, 2, 2), base * CFrame.new(wx, 1, wz), Color3.fromRGB(20, 20, 20), Enum.Material.Rubber, Enum.PartType.Cylinder)
		end
	end
	block(car, "Lamp", Vector3.new(1, 0.5, 0.2), base * CFrame.new(-1.6, 2.2, -5.05), Color3.fromRGB(255, 250, 220), Enum.Material.Neon)
	block(car, "Lamp", Vector3.new(1, 0.5, 0.2), base * CFrame.new(1.6, 2.2, -5.05), Color3.fromRGB(255, 250, 220), Enum.Material.Neon)
	car.Parent = parent
end

local function buildPlaza(parent: Instance)
	local size = Map.CELL - Map.ROAD
	block(parent, "Plein", Vector3.new(size, 0.6, size), Vector3.new(0, 0.3, 0), Color3.fromRGB(215, 205, 190), Enum.Material.Slate)
	-- fontein
	block(parent, "Fontein", Vector3.new(2, 20, 20), CFrame.new(0, 1.6, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(200, 200, 205), Enum.Material.Marble, Enum.PartType.Cylinder)
	local water = block(parent, "Water", Vector3.new(0.4, 18, 18), CFrame.new(0, 2.5, 0) * CFrame.Angles(0, 0, math.rad(90)), Color3.fromRGB(70, 160, 230), Enum.Material.Glass, Enum.PartType.Cylinder)
	water.Transparency = 0.25
	block(parent, "Sokkel", Vector3.new(6, 3, 6), Vector3.new(0, 4, 0), Color3.fromRGB(160, 155, 150), Enum.Material.Marble)

	-- gouden skibidi-standbeeld
	local ok, err = pcall(function()
		local Models = require(script.Parent:WaitForChild("Models"))
		local statue = Models.statue(CFrame.new(0, 11.5, 0) * CFrame.Angles(0, math.rad(180), 0), 2)
		statue.Parent = parent
	end)
	if not ok then
		warn("[Loaden Skibidi] standbeeld lukte niet:", err)
	end

	-- groot bord met de naam van de stad
	local board = block(parent, "Naambord", Vector3.new(30, 8, 1), Vector3.new(0, 12, size / 2 - 2), Color3.fromRGB(25, 20, 45))
	block(parent, "Paal", Vector3.new(1, 8, 1), Vector3.new(-12, 4.6, size / 2 - 2), Color3.fromRGB(60, 60, 70), Enum.Material.Metal)
	block(parent, "Paal", Vector3.new(1, 8, 1), Vector3.new(12, 4.6, size / 2 - 2), Color3.fromRGB(60, 60, 70), Enum.Material.Metal)
	sign(board, Enum.NormalId.Front, "ALPHAHILLS", Color3.fromRGB(255, 210, 63))
	sign(board, Enum.NormalId.Back, "ALPHAHILLS", Color3.fromRGB(255, 210, 63))

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 0.6, 16)
	spawn.Neutral = true
	spawn.Duration = 2
	spawn.Color = Color3.fromRGB(255, 210, 63)
	spawn.Material = Enum.Material.Neon
	spawn.Parent = parent
end

local function setupLighting()
	Lighting.ClockTime = 17.2 -- gouden zonsondergang
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(70, 60, 80)
	Lighting.OutdoorAmbient = Color3.fromRGB(140, 120, 150)
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.5

	local function ensure(className: string)
		local obj = Lighting:FindFirstChildOfClass(className)
		if not obj then
			obj = Instance.new(className)
			obj.Parent = Lighting
		end
		return obj :: any
	end
	local atmo = ensure("Atmosphere")
	atmo.Density = 0.32
	atmo.Haze = 1.5
	atmo.Color = Color3.fromRGB(255, 200, 170)
	atmo.Decay = Color3.fromRGB(120, 90, 140)
	local bloom = ensure("BloomEffect")
	bloom.Intensity = 0.6
	bloom.Size = 30
	bloom.Threshold = 1.6
	local rays = ensure("SunRaysEffect")
	rays.Intensity = 0.06
	local cc = ensure("ColorCorrectionEffect")
	cc.Saturation = 0.15
	cc.Contrast = 0.08
end

function Map.build()
	local ok, err = pcall(setupLighting)
	if not ok then
		warn("[Loaden Skibidi] licht instellen lukte niet:", err)
	end
	if workspace:FindFirstChild("Alphahills") then
		return
	end
	local city = Instance.new("Model")
	city.Name = "Alphahills"

	local full = Map.LIMIT * 2
	block(city, "Asfalt", Vector3.new(full, 2, full), Vector3.new(0, -0.9, 0), Color3.fromRGB(55, 55, 60), Enum.Material.Asphalt)
	-- gras rondom de stad
	block(city, "Gras", Vector3.new(full + 400, 2, full + 400), Vector3.new(0, -1.0, 0), Color3.fromRGB(80, 150, 70), Enum.Material.Grass)

	-- witte strepen in het midden van elke weg
	for k = -Map.HALF, Map.HALF - 1 do
		local r = (k + 0.5) * Map.CELL
		for i = -Map.HALF, Map.HALF do
			local c = i * Map.CELL
			block(city, "Streep", Vector3.new(0.6, 0.12, 16), Vector3.new(r, 0.1, c), Color3.fromRGB(245, 245, 245))
			block(city, "Streep", Vector3.new(16, 0.12, 0.6), Vector3.new(c, 0.1, r), Color3.fromRGB(245, 245, 245))
		end
	end

	local inner = Map.CELL - Map.ROAD
	for i = -Map.HALF, Map.HALF do
		for j = -Map.HALF, Map.HALF do
			local cx, cz = i * Map.CELL, j * Map.CELL
			local dist = math.max(math.abs(i), math.abs(j))
			if i == 0 and j == 0 then
				buildPlaza(city)
			else
				block(city, "Stoep", Vector3.new(inner, 0.6, inner), Vector3.new(cx, 0.3, cz), Color3.fromRGB(170, 170, 175), Enum.Material.Pavement)
				local roll = rng:NextNumber()
				if dist == 1 and roll < 0.35 or roll < 0.15 then
					addPark(city, cx, cz, inner - 4)
				elseif dist == 1 then
					-- winkelstraat rond het plein
					local w = (inner - 8) / 2
					addShop(city, cx - w / 2 - 2, cz - 10, w, 22, -1)
					addShop(city, cx + w / 2 + 2, cz - 10, w, 22, -1)
					addShop(city, cx, cz + 12, inner - 8, 18, 1)
				elseif roll < 0.6 then
					addTower(city, cx, cz, inner - 10, inner - 10)
				else
					local w = (inner - 10) / 2
					addTower(city, cx - w / 2 - 2, cz, w, inner - 10)
					addTower(city, cx + w / 2 + 2, cz, w, inner - 10)
				end
			end
		end
	end

	-- lantaarnpalen op de kruispunten
	for k = -Map.HALF, Map.HALF - 1 do
		for l = -Map.HALF, Map.HALF - 1 do
			if (k + l) % 2 == 0 then
				local x, z = (k + 0.5) * Map.CELL, (l + 0.5) * Map.CELL
				addStreetLight(city, x + Map.ROAD / 2 - 1, z + Map.ROAD / 2 - 1)
			end
		end
	end

	-- geparkeerde auto's langs de weg
	for _ = 1, 22 do
		local alongX = rng:NextNumber() < 0.5
		local road = (rng:NextInteger(-Map.HALF, Map.HALF - 1) + 0.5) * Map.CELL
		local along = rng:NextInteger(-Map.HALF, Map.HALF) * Map.CELL + rng:NextNumber(-15, 15)
		local side = road + (if rng:NextNumber() < 0.5 then -6.5 else 6.5)
		if alongX then
			addCar(city, along, side, true)
		else
			addCar(city, side, along, false)
		end
	end

	-- onzichtbare muren aan de rand, zodat niemand van de wereld valt
	local wallH = 200
	for _, s in { -1, 1 } do
		local a = block(city, "Muur", Vector3.new(4, wallH, full), Vector3.new(s * Map.LIMIT, wallH / 2, 0), Color3.new(), nil)
		local b = block(city, "Muur", Vector3.new(full, wallH, 4), Vector3.new(0, wallH / 2, s * Map.LIMIT), Color3.new(), nil)
		a.Transparency = 1
		b.Transparency = 1
	end

	city.Parent = workspace
end

-- Kies een plek op de weg in de buurt van "near" (zodat vijanden niet in een gebouw verschijnen)
function Map.spawnPoint(near: Vector3, minDist: number, maxDist: number): Vector3
	local a = rng:NextNumber(0, math.pi * 2)
	local r = rng:NextNumber(minDist, maxDist)
	local x = near.X + math.cos(a) * r
	local z = near.Z + math.sin(a) * r
	-- wegen liggen tussen de blokken: op (k + 0.5) * CELL
	local function snap(v: number): number
		return (math.floor(v / Map.CELL) + 0.5) * Map.CELL
	end
	if rng:NextNumber() < 0.5 then
		x = snap(x)
	else
		z = snap(z)
	end
	local lim = (Map.HALF - 0.5) * Map.CELL -- buitenste weg
	return Vector3.new(math.clamp(x, -lim, lim), 4, math.clamp(z, -lim, lim))
end

return Map
