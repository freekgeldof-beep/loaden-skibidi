-- Map: bouwt de stad Alphahills automatisch (wegen, stoepen, gebouwen en het plein).
-- Plek in Roblox Studio: ServerScriptService > Map (ModuleScript)
-- Heb je zelf een stad gebouwd? Noem je eigen model "Alphahills" in Workspace,
-- dan bouwt dit script niets en gebruikt het spel jouw stad.

local Lighting = game:GetService("Lighting")

local Map = {}

Map.CELL = 70 -- grootte van één huizenblok + weg
Map.ROAD = 20 -- breedte van de weg
Map.HALF = 5 -- aantal blokken vanaf het midden naar de rand
Map.LIMIT = Map.CELL * Map.HALF + Map.CELL / 2 -- rand van de stad

local rng = Random.new()

local BUILDING_COLORS = {
	Color3.fromRGB(43, 39, 72),
	Color3.fromRGB(60, 52, 96),
	Color3.fromRGB(35, 50, 80),
	Color3.fromRGB(80, 60, 90),
	Color3.fromRGB(50, 50, 60),
}
local NEON_COLORS = {
	Color3.fromRGB(255, 210, 63),
	Color3.fromRGB(77, 210, 255),
	Color3.fromRGB(255, 77, 160),
	Color3.fromRGB(150, 255, 120),
}

local function block(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material?)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addBuilding(parent: Instance, x: number, z: number, w: number, d: number)
	local h = rng:NextNumber(30, 140)
	local color = BUILDING_COLORS[rng:NextInteger(1, #BUILDING_COLORS)]
	block(parent, "Gebouw", Vector3.new(w, h, d), Vector3.new(x, 0.6 + h / 2, z), color, Enum.Material.Concrete)
	-- gloeiende rand bovenop, zoals de lichtjes in de stad
	local neon = NEON_COLORS[rng:NextInteger(1, #NEON_COLORS)]
	block(parent, "Lichtrand", Vector3.new(w + 0.4, 1.2, d + 0.4), Vector3.new(x, 0.6 + h - 3, z), neon, Enum.Material.Neon)
end

local function buildPlaza(parent: Instance)
	local size = Map.CELL - Map.ROAD
	block(parent, "Plein", Vector3.new(size, 0.6, size), Vector3.new(0, 0.3, 0), Color3.fromRGB(200, 195, 185), Enum.Material.Slate)
	block(parent, "Sokkel", Vector3.new(10, 3, 10), Vector3.new(0, 2.1, 0), Color3.fromRGB(120, 115, 110), Enum.Material.Marble)
	block(parent, "Beeld", Vector3.new(4, 8, 4), Vector3.new(0, 7.6, 0), Color3.fromRGB(255, 210, 63), Enum.Material.Neon)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.Position = Vector3.new(0, 0.6, 18)
	spawn.Neutral = true
	spawn.Duration = 2
	spawn.Color = Color3.fromRGB(255, 210, 63)
	spawn.Parent = parent
end

function Map.build()
	if workspace:FindFirstChild("Alphahills") then
		return
	end
	local city = Instance.new("Model")
	city.Name = "Alphahills"

	local full = Map.LIMIT * 2
	block(city, "Asfalt", Vector3.new(full, 2, full), Vector3.new(0, -0.9, 0), Color3.fromRGB(40, 40, 45), Enum.Material.Asphalt)

	local inner = Map.CELL - Map.ROAD
	for i = -Map.HALF, Map.HALF do
		for j = -Map.HALF, Map.HALF do
			local cx, cz = i * Map.CELL, j * Map.CELL
			if i == 0 and j == 0 then
				buildPlaza(city)
			else
				block(city, "Stoep", Vector3.new(inner, 0.6, inner), Vector3.new(cx, 0.3, cz), Color3.fromRGB(130, 130, 135), Enum.Material.Pavement)
				if rng:NextNumber() < 0.5 then
					addBuilding(city, cx, cz, inner - 8, inner - 8)
				else
					local w = (inner - 10) / 2
					addBuilding(city, cx - w / 2 - 2, cz, w, inner - 8)
					addBuilding(city, cx + w / 2 + 2, cz, w, inner - 8)
				end
			end
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

	-- Avondsfeer
	Lighting.ClockTime = 18.6
	Lighting.Brightness = 2
	Lighting.OutdoorAmbient = Color3.fromRGB(110, 100, 140)
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
