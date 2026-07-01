# Pothole Patrol — Godot 4 (GDScript)

A fast, top-down **endless dodge-and-collect racer**. Steer through traffic as
the speed slowly climbs, weave past cars for near-miss points, and **crash into a
car to add it to your garage** — some models are absurdly rare. Everything is
drawn programmatically and all audio is synthesised at runtime, so there are
**no external asset files**.

## Import & run

1. Open **Godot 4.x** (4.2+).
2. Project Manager → **Import** → pick this folder's **`project.godot`**.
3. Press **F5**. It opens on the **Garage** home screen; press **PLAY**.

## Controls

| Action | Keyboard | Touch / Mouse |
| ------ | -------- | ------------- |
| Steer  | `A`/`D` or `←`/`→` | on-screen `<` `>` buttons |
| Browse garage | `←`/`→` | `<` `>` arrows |
| Play / Retry | `Enter` / `Space` | PLAY / RETRY buttons |

## How it plays

- Speed rises continuously (320 → 1150 px/s) — survival gets harder the longer
  you go.
- **Crashing into traffic ends the run, but collects that car** into your garage.
- Each car has a rarity shown as **"1 in N"**; uncollected cars on the road wear
  a **gold star** so you can spot what's worth chasing.
- **Near misses** (squeezing past a car) award bonus points.
- **Score = distance + near_miss × 10.** High score, owned cars, the selected
  car, and the sound setting all persist to `user://pothole_patrol.cfg`.
- 29 cars across 8 tiers: Common → Uncommon → Rare → Epic → Legendary → Mythic →
  Exotic → **Secret** (rarest is ~1 in 90,000).

## Audio

`scripts/sfx.gd` synthesises a looping chiptune track plus all SFX (crash,
near-miss, car-collected jingle, game over, UI) into `AudioStreamWAV` buffers at
runtime — no audio files needed. A **sound toggle** (master-bus mute) is on the
home screen and the in-game HUD and is saved between sessions.

## Publishing to CrazyGames (Web export)

The CrazyGames SDK is wired up via `scripts/crazy_sdk.gd` (the **CrazySDK**
autoload). It no-ops on desktop and, on a Web export, calls
`window.CrazyGames.SDK` through `JavaScriptBridge`:

- `gameplayStart()` when a run begins (`game.gd`)
- `gameplayStop()` on game over
- `happytime()` when you unlock a brand-new car
- `loadingStop()` once the menu is ready

A ready-to-use **`export_presets.cfg`** ("Web" preset) is already included, with:

- **Thread support OFF** — this is the key setting. Godot's default threaded web
  build needs `SharedArrayBuffer`, which requires cross-origin-isolation
  (COOP/COEP) headers the CrazyGames CDN doesn't send — that's why a default
  export shows a black/stuck screen there. The single-threaded build just works.
- The CrazyGames SDK **`<script>`** injected via HTML → Head Include.
- `export_path = build/index.html`.

To produce the build:

1. Install the **Web export templates** (Editor → Manage Export Templates →
   Download and Install) — or they may already be installed.
2. Export (either one):
   - Editor: **Project → Export… → Web → Export Project** to `build/index.html`.
   - CLI: `godot --headless --path . --export-release "Web" build/index.html`
3. **Zip the *contents* of `build/`** (so `index.html` is at the zip root, next to
   the `.wasm`, `.pck`, `.js`) and upload it on the CrazyGames developer portal.

Notes for approval:
- Audio only starts after a user gesture (pressing PLAY), satisfying browser
  autoplay policy.
- The master-bus mute also satisfies CrazyGames' "mute during ads" requirement.
- The SDK calls (`gameplayStart/Stop`, `happytime`, `loadingStop`) fire from
  `crazy_sdk.gd`; test them with the CrazyGames QA tool after upload.
- To add ads later, call the SDK's `ad.requestAd(...)` from `crazy_sdk.gd`
  (mute around the call) — left out for now to keep the build dependency-free.

## File map

```
project.godot              config (main scene = Menu.tscn, CrazySDK autoload)
icon.svg
web/crazygames_head.html   SDK <script> snippet for the Web export
scenes/
  Menu.tscn  Game.tscn
scripts/
  constants.gd             geometry / colours / tuning
  menu.gd                  home screen + garage
  game.gd                  the run: traffic, near-miss, crash-to-collect
  game_over.gd             score, high score, RETRY / CHANGE CAR
  road.gd                  grass verges, sidewalks, scrolling lanes
  roadside.gd              trees / bushes / lamps / houses / signs / fences
  player_truck.gd          steering + squash/stretch (renders selected car)
  traffic_car.gd           obstacle + uncollected-star marker
  car_catalog.gd           32 cars, rarity, shared animated draw_car routine
  car_preview.gd           garage car render (locked = silhouette)
  save_data.gd             persistence (high score, garage, mute)
  score_system.gd          distance + near-miss scoring
  sfx.gd                   runtime music + SFX synthesis
  crazy_sdk.gd             CrazyGames SDK bridge (autoload)
  hud.gd                   score / distance / steer / sound buttons
```
