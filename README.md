# Loaden Skibidi

> **Roblox-versie:** het spel wordt omgezet naar Roblox. Kijk in de map [`roblox/`](roblox/README.md) voor de Luau-scripts en de stappen in Roblox Studio.

3D third-person skibidi-vechtspel in de stad **Alphahills**, gebouwd met [three.js](https://threejs.org).
Kies een karakter en versla golven vijanden, inclusief baas-gevechten.

## Starten

```bash
npm start        # http://localhost:8080
```

Open `index.html` niet direct via `file://`: ES-modules vereisen een webserver (of gebruik GitHub Pages).

## Besturing

| Toets | Actie |
|---|---|
| WASD | lopen |
| Shift | rennen |
| Spatie | springen |
| Muis | camera |
| Linkermuisknop | aanval |
| Q / rechtermuisknop | speciale aanval |
| E | dash |

## Karakters

Skibidi Toilet, Camera Man, Speaker Man, TV Man, Titan Cameraman, G-Man.
Elke 5e golf komt er een baas (Titan of G-Man).

## Structuur

```
index.html        pagina en HUD
src/style.css     styling
src/main.js       spel: karakters, stad, gevecht, AI, minimap
vendor/           three.js (lokaal, geen CDN nodig)
roblox/           Roblox-versie (Luau-scripts, Rojo-project)
```

## Ideeën

Titan Speakerman / Titan TV Man als extra baas, mobiele besturing, meer kaarten, multiplayer.
