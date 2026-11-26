# Loaden Skibidi voor Roblox

Dit is de Roblox-versie van Loaden Skibidi. De code is in **Luau**, de taal van Roblox.
De eerste versie heeft de basis: karakter kiezen, vechten en golven vijanden met elke 5e golf een baas.

## Wat zit erin?

| Bestand | Wat het doet | Waar in Roblox Studio | Soort script |
|---|---|---|---|
| `src/shared/Config.luau` | Alle instellingen: karakters, leven, snelheid, schade | ReplicatedStorage | ModuleScript, naam `Config` |
| `src/server/GameServer.server.luau` | Het brein: vechten, vijanden, golven, bazen | ServerScriptService | Script, naam `GameServer` |
| `src/server/Models.luau` | Bouwt de kostuums (wc, camera, speaker, tv) uit blokjes | ServerScriptService | ModuleScript, naam `Models` |
| `src/server/Map.luau` | Bouwt de stad Alphahills automatisch | ServerScriptService | ModuleScript, naam `Map` |
| `src/client/GameClient.client.luau` | Menu, scherm (HUD) en toetsen | StarterPlayer > StarterPlayerScripts | LocalScript, naam `GameClient` |

De namen moeten **precies** kloppen (hoofdletters ook), anders vinden de scripts elkaar niet.

## Manier 1: Kopiëren en plakken (makkelijkst)

1. Open **Roblox Studio** en kies **Baseplate** (nieuw spel).
2. Zet de vensters **Explorer** en **Properties** aan via het tabblad **View**.
3. Maak de scripts uit de tabel hierboven:
   - Ga in de Explorer met je muis op bijvoorbeeld **ReplicatedStorage** staan, klik op het **+** en kies **ModuleScript**.
   - Geef het de naam uit de tabel (klik erop, druk F2).
   - Open het script, haal de tekst die er al staat weg, en plak de code uit het bestand hier in de repo.
   - Doe dit voor alle 5 scripts. Let op het soort: **Script**, **ModuleScript** of **LocalScript**.
4. Druk op **Play** (of F5). Je ziet het menu, kiest een karakter en drukt op **SPELEN**.

## Manier 2: Met Rojo (voor later)

[Rojo](https://rojo.space) zet de bestanden uit deze map automatisch in Studio, en houdt ze bij als je ze verandert.

1. Installeer Rojo en de Rojo-plugin in Studio.
2. Open een terminal in de map `roblox/` en typ `rojo serve`.
3. Klik in Studio op de Rojo-plugin en dan op **Connect**.

## Besturing

| Toets | Actie |
|---|---|
| WASD | lopen |
| Shift | rennen |
| Spatie | springen |
| Linkermuisknop | aanval |
| Q | speciale aanval |
| E | dash |

Op telefoon en tablet maakt Roblox zelf knoppen op het scherm voor aanval, speciaal en dash.

## Hoe werkt het?

- **Karakter kiezen:** in het menu kies je Skibidi Toilet, Camera Man, Speaker Man, TV Man, Titan Cameraman of G-Man. Je krijgt dan een kostuum, en je eigen leven en snelheid.
- **Speciale aanvallen:** *Skibidi-straal* schiet een bal, *Flits* verlamt vijanden voor je, *Schokgolf* duwt alles om je heen weg.
- **Golven:** na elke golf komt een sterkere. Elke 5e golf komt een baas: eerst de Titan Cameraman (stampt), dan G-Man (schiet).
- **Score:** staat rechtsboven en in het scorebord (Score en Kills).
- **Game over:** als iedereen dood is. Na een paar seconden zie je het menu weer.
- **Multiplayer:** werkt meteen. Iedereen in de server vecht samen tegen dezelfde golven.

## Zelf aanpassen

- Spel te moeilijk of te makkelijk? Verander de getallen in `Config`.
- Zelf een stad gebouwd? Zet alles in een Model met de naam `Alphahills` in Workspace. Dan bouwt het script geen stad, en gebruikt het spel de jouwe.

## Nog te doen

- Loop-animaties voor de vijanden (ze glijden nu nog).
- Mooiere modellen maken in Studio, in plaats van blokjes.
- Highscore bewaren met DataStore.
- Meer bazen: Titan Speakerman en Titan TV Man.
