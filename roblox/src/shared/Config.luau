-- Config: alle instellingen van het spel op één plek.
-- Plek in Roblox Studio: ReplicatedStorage > Config (ModuleScript)
-- Tip: verander hier getallen om het spel makkelijker of moeilijker te maken.

local Config = {}

-- Volgorde van de karakters in het menu
Config.Order = { "toilet", "camera", "speaker", "tv", "titan", "gman" }

-- hp = leven, speed = loopsnelheid (Roblox-standaard is 16), dmg = schade per klap
-- special = soort speciale aanval: "blast", "flash" of "shockwave"
-- costume = hoe het karakter eruitziet, scale = hoe groot
-- stats = balkjes in het menu: { kracht, snelheid, leven } van 0 tot 1
Config.Characters = {
	toilet = {
		name = "Skibidi Toilet", hp = 110, speed = 15, dmg = 16, special = "blast",
		desc = "Gebalanceerd. Speciaal: skibidi-straal.",
		costume = "toilet", color = Color3.fromRGB(245, 245, 245), scale = 1,
		stats = { 0.6, 0.6, 0.7 },
	},
	camera = {
		name = "Camera Man", hp = 85, speed = 19, dmg = 12, special = "flash",
		desc = "Snel. Speciaal: flits die vijanden verlamt.",
		costume = "camera", color = Color3.fromRGB(60, 60, 70), scale = 1,
		stats = { 0.4, 0.95, 0.5 },
	},
	speaker = {
		name = "Speaker Man", hp = 100, speed = 14, dmg = 14, special = "shockwave",
		desc = "Speciaal: bass-schokgolf om je heen.",
		costume = "speaker", color = Color3.fromRGB(35, 35, 40), scale = 1,
		stats = { 0.55, 0.55, 0.6 },
	},
	tv = {
		name = "TV Man", hp = 160, speed = 12, dmg = 22, special = "blast",
		desc = "Zware tank. Langzaam maar sterk.",
		costume = "tv", color = Color3.fromRGB(90, 90, 100), scale = 1,
		stats = { 1, 0.35, 1 },
	},
	titan = {
		name = "Titan Cameraman", hp = 240, speed = 11, dmg = 28, special = "shockwave",
		desc = "Gigantische reus. Stampt de grond kapot.",
		costume = "camera", color = Color3.fromRGB(70, 70, 80), scale = 2.2,
		stats = { 1, 0.3, 1 },
	},
	gman = {
		name = "G-Man", hp = 105, speed = 17, dmg = 16, special = "blast",
		desc = "Gevaarlijke toilet-baas. Snel en dodelijk.",
		costume = "toilet", color = Color3.fromRGB(150, 150, 160), scale = 1.5,
		stats = { 0.65, 0.9, 0.55 },
	},
}

-- Namen van de speciale aanvallen (voor het scherm)
Config.SpecialNames = { blast = "Skibidi-straal", flash = "Flits", shockwave = "Schokgolf" }

-- Gevecht
Config.AttackCooldown = 0.45 -- seconden tussen gewone aanvallen
Config.SpecialCooldown = 4 -- seconden tussen speciale aanvallen
Config.DashCooldown = 1.2
Config.DashSpeed = 85
Config.SprintMultiplier = 1.5 -- Shift = 1.5x zo snel
Config.AttackRange = 8 -- hoe ver je klap reikt (studs)

-- Golven
Config.BossEvery = 5 -- elke 5e golf een baas
Config.MaxEnemies = 30 -- nooit meer vijanden tegelijk (anders wordt het traag)
Config.WavePause = 3 -- seconden pauze tussen golven
Config.EnemyKinds = { "toilet", "camera", "speaker", "tv" }
Config.EnemyTints = {
	Color3.fromRGB(255, 77, 109),
	Color3.fromRGB(77, 210, 255),
	Color3.fromRGB(179, 107, 255),
	Color3.fromRGB(77, 255, 154),
}
Config.EnemySpeedCap = 17
Config.BossHp = { titan = 650, gman = 480 }

return Config
