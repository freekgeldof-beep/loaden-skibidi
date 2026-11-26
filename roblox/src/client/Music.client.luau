-- Music: een simpel vrolijk muziekje, gemaakt met piepjes uit Roblox zelf.
-- Plek in Roblox Studio: StarterPlayer > StarterPlayerScripts > Music (LocalScript)
-- Druk op M om de muziek aan of uit te zetten.
-- Eigen liedje? Zet een audio-ID bij Config.MusicId.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local on = true
local volume = Config.MusicVolume or 0.35

-- Eigen liedje (als er een ID in Config staat)
local song: Sound? = nil
if Config.MusicId and Config.MusicId ~= "" then
	song = Instance.new("Sound")
	song.SoundId = Config.MusicId
	song.Looped = true
	song.Volume = volume
	song.Parent = SoundService
	song:Play()
end

UserInputService.InputBegan:Connect(function(input, typing)
	if typing then
		return
	end
	if input.KeyCode == Enum.KeyCode.M then
		on = not on
		if song then
			song.Volume = if on then volume else 0
		end
	end
end)

if song then
	return -- eigen liedje speelt, klaar
end

---------------------------------------------------------------------
-- Zelfgemaakt muziekje
---------------------------------------------------------------------
local BLIP = "rbxasset://sounds/electronicpingshort.wav"
local CLICK = "rbxasset://sounds/clickfast.wav"

-- Een toon spelen: hoger of lager door PlaybackSpeed te veranderen.
-- semitone 0 = basistoon, 12 = een octaaf hoger, -12 = een octaaf lager
local function note(id: string, semitone: number, vol: number, length: number?)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.PlaybackSpeed = 2 ^ (semitone / 12)
	s.Volume = vol * volume
	s.Parent = SoundService
	s:Play()
	Debris:AddItem(s, length or 1.5)
end

local BPM = 124
local STEP = 60 / BPM / 2 -- achtste noten

-- Melodie: 32 stapjes, false = stilte. Getallen zijn halve tonen.
local MELODY = {
	0, false, 3, false, 5, 7, false, 5, 3, false, 0, false, -2, false, 0, false,
	0, false, 3, false, 5, 7, false, 10, 12, false, 10, 7, 5, false, 7, false,
}
-- Bas: één toon per maat (8 stapjes), twee octaven lager
local BASS = { -24, -21, -19, -17 }

task.wait(1)
local step = 0
while true do
	if on then
		local i = step % #MELODY + 1
		local m = MELODY[i]
		if m then
			note(BLIP, m, 0.35)
		end
		if step % 4 == 0 then
			local bar = math.floor(step / 8) % #BASS + 1
			note(BLIP, BASS[bar], 0.8)
		end
		if step % 2 == 1 then
			note(CLICK, 0, 0.25, 0.5)
		end
	end
	step += 1
	task.wait(STEP)
end
