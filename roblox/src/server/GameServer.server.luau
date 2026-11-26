-- GameServer: het "brein" van het spel. Regelt karakterkeuze, vechten, vijanden en golven.
-- Plek in Roblox Studio: ServerScriptService > GameServer (Script)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local StarterPlayer = game:GetService("StarterPlayer")

local Config = require(ReplicatedStorage:WaitForChild("Config"))
local Models = require(script.Parent:WaitForChild("Models"))
local Map = require(script.Parent:WaitForChild("Map"))

-- Shift is voor rennen, dus "shift lock" uit
StarterPlayer.EnableMouseLockOption = false

---------------------------------------------------------------------
-- Berichten tussen speler (client) en server
---------------------------------------------------------------------
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end
local function remote(name: string): RemoteEvent
	local r = remotes:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = remotes
	end
	return r :: RemoteEvent
end
local ChooseCharacter = remote("ChooseCharacter") -- speler kiest karakter
local AttackRemote = remote("Attack") -- linkermuisknop
local SpecialRemote = remote("Special") -- Q
local GameState = remote("GameState") -- server vertelt: golf, baas, game over

---------------------------------------------------------------------
-- Spelstatus
---------------------------------------------------------------------
Map.build()
print("[Loaden Skibidi] server gestart")

local enemyFolder = Instance.new("Folder")
enemyFolder.Name = "Vijanden"
enemyFolder.Parent = workspace

local chosen: { [Player]: string } = {} -- welk karakter elke speler heeft
local lastAttack: { [Player]: number } = {}
local lastSpecial: { [Player]: number } = {}
local enemies = {} -- lijst van vijanden
local wave = 0
local running = false
local waveQueued = false

local rng = Random.new()

---------------------------------------------------------------------
-- Hulpjes
---------------------------------------------------------------------
local function alivePlayers()
	local list = {}
	for player, kind in chosen do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if hum and root and hum.Health > 0 then
			table.insert(list, { player = player, kind = kind, humanoid = hum, root = root })
		end
	end
	return list
end

local function aliveEnemies()
	local list = {}
	for _, e in enemies do
		if not e.dead then
			table.insert(list, e)
		end
	end
	return list
end

local function flashHit(model: Instance, color: Color3)
	local h = Instance.new("Highlight")
	h.FillColor = color
	h.FillTransparency = 0.3
	h.OutlineTransparency = 1
	h.Parent = model
	Debris:AddItem(h, 0.15)
end

local function effectBall(pos: Vector3, color: Color3, startSize: number, endSize: number, time: number)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Transparency = 0.3
	p.Size = Vector3.one * startSize
	p.Position = pos
	p.Parent = workspace
	TweenService:Create(p, TweenInfo.new(time), { Size = Vector3.one * endSize, Transparency = 1 }):Play()
	Debris:AddItem(p, time)
end

local function effectRing(pos: Vector3, color: Color3, radius: number)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Cylinder
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Size = Vector3.new(0.4, 2, 2)
	p.CFrame = CFrame.new(pos.X, pos.Y - 2.5, pos.Z) * CFrame.Angles(0, 0, math.rad(90))
	p.Parent = workspace
	TweenService:Create(p, TweenInfo.new(0.4), { Size = Vector3.new(0.4, radius * 2, radius * 2), Transparency = 1 }):Play()
	Debris:AddItem(p, 0.4)
end

-- Zwevend schade-getal boven een vijand
local function damageNumber(pos: Vector3, amount: number)
	local anchor = Instance.new("Part")
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.one * 0.2
	anchor.Position = pos + Vector3.new(rng:NextNumber(-1.5, 1.5), 4, rng:NextNumber(-1.5, 1.5))
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(90, 40)
	bb.AlwaysOnTop = true
	bb.Parent = anchor
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = tostring(math.floor(amount + 0.5))
	t.TextScaled = true
	t.Font = Enum.Font.GothamBlack
	t.TextColor3 = if amount >= 25 then Color3.fromRGB(255, 120, 40) else Color3.fromRGB(255, 230, 80)
	t.TextStrokeTransparency = 0
	t.Parent = bb
	anchor.Parent = workspace
	TweenService:Create(anchor, TweenInfo.new(0.8), { Position = anchor.Position + Vector3.new(0, 5, 0) }):Play()
	TweenService:Create(t, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(anchor, 0.8)
end

-- Hartje: geeft leven terug als je erdoorheen loopt
local function dropHeart(pos: Vector3)
	local heart = Instance.new("Part")
	heart.Name = "Hartje"
	heart.Shape = Enum.PartType.Ball
	heart.Size = Vector3.one * 2.2
	heart.Color = Color3.fromRGB(80, 255, 120)
	heart.Material = Enum.Material.Neon
	heart.Anchored = true
	heart.CanCollide = false
	heart.Position = Vector3.new(pos.X, 2.5, pos.Z)
	local light = Instance.new("PointLight")
	light.Color = heart.Color
	light.Range = 10
	light.Parent = heart
	heart.Parent = workspace
	TweenService:Create(heart, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Position = heart.Position + Vector3.new(0, 1.2, 0) }):Play()
	local used = false
	heart.Touched:Connect(function(hit)
		if used then
			return
		end
		local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		local plr = hit.Parent and Players:GetPlayerFromCharacter(hit.Parent)
		if hum and plr and hum.Health > 0 then
			used = true
			hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * 0.3)
			effectBall(heart.Position, heart.Color, 2, 8, 0.3)
			heart:Destroy()
		end
	end)
	Debris:AddItem(heart, 20)
end

local function addScore(player: Player?, points: number, kill: boolean)
	if not player then
		return
	end
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		return
	end
	local score = stats:FindFirstChild("Score") :: IntValue
	score.Value += points
	if kill then
		local kills = stats:FindFirstChild("Kills") :: IntValue
		kills.Value += 1
	end
end

local function push(root: BasePart, dir: Vector3, force: number)
	local flat = Vector3.new(dir.X, 0, dir.Z)
	if flat.Magnitude > 0.01 then
		flat = flat.Unit
	end
	root:ApplyImpulse((flat * force + Vector3.new(0, force * 0.4, 0)) * root.AssemblyMass)
end

---------------------------------------------------------------------
-- Schade aan vijanden
---------------------------------------------------------------------
local function damageEnemy(e, amount: number, attacker: Player?, fromPos: Vector3, knock: number, stun: number)
	if e.dead then
		return
	end
	e.lastAttacker = attacker
	e.humanoid:TakeDamage(amount)
	damageNumber(e.root.Position, amount)
	flashHit(e.model, Color3.new(1, 1, 1))
	if stun > 0 then
		e.stunUntil = math.max(e.stunUntil, os.clock() + stun)
	end
	if knock > 0 and not e.boss then
		push(e.root, e.root.Position - fromPos, knock)
	end
end

-- Een vliegende bal (skibidi-straal). Raakt het eerste doel uit getTargets().
local function projectile(origin: Vector3, dir: Vector3, color: Color3, getTargets, onHit)
	local ball = Instance.new("Part")
	ball.Shape = Enum.PartType.Ball
	ball.Size = Vector3.one * 2.4
	ball.Anchored = true
	ball.CanCollide = false
	ball.CanQuery = false
	ball.CanTouch = false
	ball.Material = Enum.Material.Neon
	ball.Color = color
	ball.Position = origin
	ball.Parent = workspace
	task.spawn(function()
		local t = 0
		while t < 1.3 and ball.Parent do
			local dt = RunService.Heartbeat:Wait()
			t += dt
			ball.Position += dir * 110 * dt
			for _, target in getTargets() do
				if (target.root.Position - ball.Position).Magnitude < 4 then
					onHit(target)
					effectBall(ball.Position, color, 2, 10, 0.25)
					ball:Destroy()
					return
				end
			end
		end
		ball:Destroy()
	end)
end

---------------------------------------------------------------------
-- Aanvallen van spelers
---------------------------------------------------------------------
local function playerInfo(player: Player)
	local kind = chosen[player]
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local root = char and char:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not kind or not hum or not root or hum.Health <= 0 or not running then
		return nil
	end
	return kind, Config.Characters[kind], root
end

AttackRemote.OnServerEvent:Connect(function(player)
	local kind, T, root = playerInfo(player)
	if not kind then
		return
	end
	local now = os.clock()
	if now - (lastAttack[player] or 0) < Config.AttackCooldown * 0.9 then
		return -- te snel (valsspeel-bescherming)
	end
	lastAttack[player] = now

	local scale = T.scale or 1
	local range = Config.AttackRange * scale
	local look = root.CFrame.LookVector
	effectBall(root.Position + look * 3 * scale, Color3.fromRGB(255, 210, 63), 1, 4 * scale, 0.15)
	for _, e in aliveEnemies() do
		local offset = e.root.Position - root.Position
		local dist = offset.Magnitude
		if dist < range + 2 and (dist < 2 or look:Dot(offset.Unit) > 0.3) then
			damageEnemy(e, T.dmg, player, root.Position, 35, 0.2)
		end
	end
end)

SpecialRemote.OnServerEvent:Connect(function(player)
	local kind, T, root = playerInfo(player)
	if not kind then
		return
	end
	local now = os.clock()
	if now - (lastSpecial[player] or -100) < Config.SpecialCooldown * 0.9 then
		return
	end
	lastSpecial[player] = now

	local scale = T.scale or 1
	local look = root.CFrame.LookVector
	if T.special == "blast" then
		projectile(root.Position + look * 4, look, Color3.fromRGB(120, 220, 255), aliveEnemies, function(e)
			damageEnemy(e, T.dmg * 2.2, player, root.Position, 60, 0.5)
		end)
	elseif T.special == "flash" then
		effectBall(root.Position + look * 3, Color3.new(1, 1, 1), 2, 30, 0.3)
		for _, e in aliveEnemies() do
			local offset = e.root.Position - root.Position
			if offset.Magnitude < 40 and look:Dot(offset.Unit) > 0.4 then
				damageEnemy(e, T.dmg * 0.6, player, root.Position, 0, 2.5)
			end
		end
	elseif T.special == "shockwave" then
		local radius = 18 * scale
		effectRing(root.Position, Color3.fromRGB(179, 107, 255), radius)
		for _, e in aliveEnemies() do
			if (e.root.Position - root.Position).Magnitude < radius then
				damageEnemy(e, T.dmg * 1.5, player, root.Position, 70, 0.8)
			end
		end
	end
end)

---------------------------------------------------------------------
-- Vijanden
---------------------------------------------------------------------
local checkWaveDone -- wordt hieronder ingevuld
local gameOver -- wordt hieronder ingevuld

local function spawnEnemy(kind: string, tint: Color3, bossKind: string?)
	local players = alivePlayers()
	if #players == 0 then
		return
	end
	local T = Config.Characters[kind]
	local model = Models.makeEnemy(kind, tint)
	local hum = model:FindFirstChildOfClass("Humanoid") :: Humanoid
	local root = model:FindFirstChild("HumanoidRootPart") :: BasePart

	local e = {
		model = model, humanoid = hum, root = root, kind = kind,
		boss = bossKind, dead = false, stunUntil = 0, lastHit = 0, lastSkill = os.clock(),
		lastAttacker = nil :: Player?,
	}
	if bossKind then
		local hp = Config.BossHp[bossKind] * (1 + wave * 0.07)
		hum.MaxHealth = hp
		hum.Health = hp
		hum.WalkSpeed = T.speed * 0.85
		e.dmg = (if bossKind == "titan" then 18 else 10) + wave
		hum.DisplayName = "BAAS: " .. T.name
	else
		local hp = T.hp * (1 + wave * 0.12)
		hum.MaxHealth = hp
		hum.Health = hp
		hum.WalkSpeed = math.min(Config.EnemySpeedCap, T.speed * 0.7 + wave * 0.3)
		e.dmg = 6 + wave * 0.8
		hum.DisplayName = T.name
	end
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
	hum.BreakJointsOnDeath = false

	local target = players[rng:NextInteger(1, #players)]
	local pos = Map.spawnPoint(target.root.Position, if bossKind then 45 else 60, if bossKind then 50 else 120)
	model:PivotTo(CFrame.new(pos + Vector3.new(0, 3 * (T.scale or 1), 0)))
	model.Parent = enemyFolder
	pcall(function()
		root:SetNetworkOwner(nil) -- de server bestuurt de vijand
	end)
	Models.animate(hum)

	hum.Died:Connect(function()
		if e.dead then
			return
		end
		e.dead = true
		addScore(e.lastAttacker, if bossKind then 500 + wave * 20 else 100 + wave * 10, true)
		effectBall(root.Position, tint, 2, 12, 0.4)
		if bossKind or rng:NextNumber() < 0.2 then
			dropHeart(root.Position)
		end
		Debris:AddItem(model, 1.5)
		local i = table.find(enemies, e)
		if i then
			table.remove(enemies, i)
		end
		if bossKind then
			GameState:FireAllClients({ type = "boss", hp = 0, max = 1 })
		end
		GameState:FireAllClients({ type = "left", left = #enemies })
		checkWaveDone()
	end)
	if bossKind then
		hum.HealthChanged:Connect(function(h)
			GameState:FireAllClients({ type = "boss", name = T.name, hp = h, max = hum.MaxHealth })
		end)
	end

	table.insert(enemies, e)
	return e
end

local function clearEnemies()
	for _, e in enemies do
		e.dead = true
		e.model:Destroy()
	end
	table.clear(enemies)
end

---------------------------------------------------------------------
-- Golven
---------------------------------------------------------------------
local function nextWave()
	-- wacht tot er minstens één speler leeft (bijv. net gespawnd)
	local waited = 0
	while running and #alivePlayers() == 0 and waited < 15 do
		waited += task.wait(0.25)
	end
	if not running then
		return
	end
	if #alivePlayers() == 0 then
		gameOver()
		return
	end
	wave += 1
	local isBoss = wave % Config.BossEvery == 0
	local n = if isBoss then math.max(2, math.floor(wave / 2)) else 2 + wave * 2
	n = math.min(n, Config.MaxEnemies)

	local bossKind = nil
	if isBoss then
		bossKind = if (wave / Config.BossEvery) % 2 == 1 then "titan" else "gman"
		GameState:FireAllClients({ type = "wave", wave = wave, boss = Config.Characters[bossKind].name })
	else
		GameState:FireAllClients({ type = "wave", wave = wave })
	end

	for _ = 1, n do
		if not running then
			return
		end
		local kind = Config.EnemyKinds[rng:NextInteger(1, #Config.EnemyKinds)]
		local tint = Config.EnemyTints[rng:NextInteger(1, #Config.EnemyTints)]
		spawnEnemy(kind, tint, nil)
		task.wait(0.15)
	end
	if bossKind and running then
		local boss = spawnEnemy(bossKind, Color3.fromRGB(255, 34, 34), bossKind)
		if boss then
			GameState:FireAllClients({ type = "boss", name = Config.Characters[bossKind].name, hp = boss.humanoid.Health, max = boss.humanoid.MaxHealth })
		end
	end
	GameState:FireAllClients({ type = "left", left = #enemies })
end

checkWaveDone = function()
	if not running or waveQueued or #enemies > 0 then
		return
	end
	waveQueued = true
	task.delay(Config.WavePause, function()
		waveQueued = false
		nextWave()
	end)
end

local function startGame()
	if running then
		return
	end
	clearEnemies()
	wave = 0
	running = true
	for _, player in Players:GetPlayers() do
		local stats = player:FindFirstChild("leaderstats")
		if stats then
			local score = stats:FindFirstChild("Score") :: IntValue
			local kills = stats:FindFirstChild("Kills") :: IntValue
			score.Value = 0
			kills.Value = 0
		end
	end
	task.delay(2, nextWave)
end

gameOver = function()
	if not running then
		return
	end
	running = false
	GameState:FireAllClients({ type = "gameover", wave = wave })
	clearEnemies()
	table.clear(chosen)
end

local function checkGameOver()
	if running and #alivePlayers() == 0 then
		gameOver()
	end
end

---------------------------------------------------------------------
-- Vijand-AI: lopen naar de dichtstbijzijnde speler en aanvallen
---------------------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(0.15)
		if running then
			local players = alivePlayers()
			local now = os.clock()
			for _, e in aliveEnemies() do
				if now < e.stunUntil or #players == 0 then
					e.humanoid:Move(Vector3.zero)
					continue
				end
				-- dichtstbijzijnde speler zoeken
				local best, bestDist = nil, math.huge
				for _, p in players do
					local d = (p.root.Position - e.root.Position).Magnitude
					if d < bestDist then
						best, bestDist = p, d
					end
				end
				local T = Config.Characters[e.kind]
				local reach = 5 * (T.scale or 1)
				if bestDist > reach then
					e.humanoid:MoveTo(best.root.Position)
				else
					e.humanoid:Move(Vector3.zero)
					if now - e.lastHit > (if e.boss then 1.4 else 1.0) then
						e.lastHit = now
						best.humanoid:TakeDamage(e.dmg)
						flashHit(best.root.Parent, Color3.fromRGB(255, 60, 60))
						push(best.root, best.root.Position - e.root.Position, 25)
					end
				end
				-- Baas-krachten
				if e.boss and now - e.lastSkill > 6 and bestDist < 60 then
					e.lastSkill = now
					if e.boss == "titan" then
						-- Titan stampt: schokgolf
						effectRing(e.root.Position, Color3.fromRGB(255, 80, 80), 24)
						for _, p in players do
							if (p.root.Position - e.root.Position).Magnitude < 24 then
								p.humanoid:TakeDamage(e.dmg)
								push(p.root, p.root.Position - e.root.Position, 70)
							end
						end
					else
						-- G-Man schiet een straal
						local dir = (best.root.Position - e.root.Position).Unit
						projectile(e.root.Position + dir * 5, dir, Color3.fromRGB(255, 60, 60), alivePlayers, function(p)
							p.humanoid:TakeDamage(e.dmg * 1.5)
							push(p.root, dir, 60)
						end)
					end
				end
			end
		end
	end
end)

---------------------------------------------------------------------
-- Spelers
---------------------------------------------------------------------
local function applyCharacter(player: Player, character: Model)
	local kind = chosen[player]
	if not kind then
		return
	end
	local T = Config.Characters[kind]
	local hum = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not hum then
		return
	end
	character:WaitForChild("Head", 10)
	character:WaitForChild("HumanoidRootPart", 10)
	-- Wacht tot de avatar helemaal geladen is. Anders vervangt Roblox het hoofd
	-- daarna nog, en valt het kostuum eraf (daardoor was het eerst onzichtbaar).
	local waited = 0
	while not player:HasAppearanceLoaded() and waited < 8 do
		waited += task.wait(0.1)
	end
	task.wait(0.2)
	if player.Character ~= character or chosen[player] ~= kind then
		return
	end
	Models.dress(character, kind, Color3.fromRGB(255, 210, 63))
	-- Extra check: is het hoofd toch nog vervangen? Dan opnieuw aankleden.
	local headAtDress = character:FindFirstChild("Head")
	task.delay(1.5, function()
		if player.Character == character and character:FindFirstChild("Head") ~= headAtDress then
			Models.dress(character, kind, Color3.fromRGB(255, 210, 63))
		end
	end)
	hum.MaxHealth = T.hp
	hum.Health = T.hp
	hum.WalkSpeed = T.speed
	character:SetAttribute("Kind", kind)
end

local function onPlayerAdded(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local score = Instance.new("IntValue")
	score.Name = "Score"
	score.Parent = stats
	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Parent = stats
	stats.Parent = player

	player.CharacterAdded:Connect(function(character)
		task.spawn(applyCharacter, player, character)
		local hum = character:WaitForChild("Humanoid", 10) :: Humanoid?
		if hum then
			hum.Died:Connect(function()
				task.wait(0.2)
				checkGameOver()
			end)
		end
	end)
end

for _, p in Players:GetPlayers() do
	onPlayerAdded(p)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(player)
	chosen[player] = nil
	lastAttack[player] = nil
	lastSpecial[player] = nil
	task.defer(checkGameOver)
end)

ChooseCharacter.OnServerEvent:Connect(function(player, kind)
	if typeof(kind) ~= "string" or not Config.Characters[kind] then
		return
	end
	chosen[player] = kind
	player:LoadCharacter() -- nieuw poppetje met het gekozen kostuum
	if not running then
		startGame()
	else
		GameState:FireClient(player, { type = "wave", wave = wave })
	end
end)
