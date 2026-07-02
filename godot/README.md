# Pothole Patrol — Godot 4 (GDScript)

A fast, top-down **patch-and-dodge endless racer** in landscape 16:9 (desktop
web first). You're the road repair crew: **drive over potholes to patch them**
(combo points), weave past traffic for near-miss bonuses, complete a simple
mission each run, and **crash into a car to add it to your garage** — some
models are seriously rare. Everything is drawn programmatically and all audio
is synthesised at runtime, so there are **no external asset files**.

## Import & run

1. Open **Godot 4.x** (4.2+).
2. Project Manager → **Import** → pick this folder's **`project.godot`**.
3. Press **F5**. It opens on the menu; press **PLAY**.

## Controls

| Action | Keyboard | Touch / Mouse |
| ------ | -------- | ------------- |
| Steer  | `A`/`D`, `←`/`→` (also `Q` = left for AZERTY) | on-screen `<` `>` buttons |
| Browse garage | `←`/`→` | `<` `>` arrows |
| Play / Retry | `Enter` / `Space` | PLAY / RETRY buttons |

A skippable in-gameplay onboarding overlay (keycaps + goals) shows on the
first three runs and fades on the first steering input.

## How it plays

- Speed rises continuously (300 → 980 px/s) — survival gets harder the longer
  you go.
- **Potholes** scroll down the lanes. Drive over one to **patch it** (+25 ×
  combo, capped at ×4). Letting one slip past breaks the combo.
- **Near misses** (squeezing past a car) award bonus points.
- **One mission per run** ("Patch 12 potholes", "Survive 45 s", …) shown on the
  HUD; completing it awards +300 and advances a persistent mission list.
- **Crashing into traffic ends the run, but collects that car** into your
  garage. Uncollected cars wear a **gold star** on the road.
- **Score = distance + near_miss×10 + patch points + mission bonus.** High
  score, owned cars, selection, mission progress and settings persist to
  `user://pothole_patrol.cfg`.
- 43 cars across 9 tiers: Common → Secret → **Ultimate**. Secrets sit around
  1 in 3,000–3,500 (a chase, but reachable); the four Ultimates run from
  ≈ 1 in 9,000 up to ≈ 1 in 36,000 (The Void) — the long-term hunt that keeps
  collectors coming back. Uncollected cars wear a gold star on the road, so an
  Ultimate spawn is a visible event.

## Audio

`scripts/sfx.gd` synthesises a looping track (detuned triangle lead, sine
bass, drums, gentle low-pass) plus all SFX (patch thump, crash, near-miss,
mission jingle, unlock jingle, UI) into `AudioStreamWAV` buffers at runtime —
no audio files needed. A **sound toggle** is on the menu and the in-game HUD
and is saved between sessions.

## Publishing to CrazyGames (Web export)

The CrazyGames SDK is wired up via `scripts/crazy_sdk.gd` (the **CrazySDK**
autoload). It no-ops on desktop and, on a Web export, calls
`window.CrazyGames.SDK` through `JavaScriptBridge`:

- `gameplayStart()` when a run begins (`game.gd`)
- `gameplayStop()` on game over
- `happytime()` on new car unlocks and mission completions
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
   `pothole-patrol-crazygames.zip` in this folder is that zip, pre-built.

Store covers (regenerated from real gameplay frames) are in `covers/`.

Notes for approval:
- Landscape 1280×720 design — fills a desktop browser viewport properly.
- Audio only starts after a user gesture (pressing PLAY), satisfying browser
  autoplay policy.
- The master-bus mute also satisfies CrazyGames' "mute during ads" requirement.
- `Q` steers left so AZERTY (ZQSD) keyboards work without rebinding; Escape is
  never used in-game (it exits fullscreen on web).
- The SDK calls fire from `crazy_sdk.gd`; test them with the CrazyGames QA tool
  after upload.
- To add ads later, call the SDK's `ad.requestAd(...)` from `crazy_sdk.gd`
  (mute around the call) — left out for now to keep the build dependency-free.

## File map

```
project.godot              config (main scene = Menu.tscn, CrazySDK autoload)
icon.svg
web/crazygames_head.html   SDK <script> snippet for the Web export
covers/                    store covers (1920x1080, 800x1200, 800x800)
scenes/
  Menu.tscn  Garage.tscn  Game.tscn
scripts/
  constants.gd             geometry / colours / tuning (1280x720 landscape)
  ui_kit.gd                shared styled UI (buttons, panels, vignette, keycaps)
  menu.gd                  landing screen (landscape two-column layout)
  garage.gd                browse / select collected cars
  game.gd                  the run: potholes, traffic, missions, near-miss
  game_over.gd             score card, high score, RETRY / MENU
  road.gd                  asphalt texture, curbs, tire wear, lane dashes
  roadside.gd              trees / bushes / lamps / houses / rocks / flowers
  pothole.gd               crater rendering + patched state
  missions.gd              per-run session goals (persistent progression)
  player_truck.gd          steering + squash/stretch (renders selected car)
  traffic_car.gd           obstacle + uncollected-star marker
  car_catalog.gd           43 cars, rarity, shared animated draw_car routine
  car_preview.gd           garage car render (locked = silhouette)
  save_data.gd             persistence (score, garage, missions, settings)
  score_system.gd          distance + near-miss + patch combo + missions
  sfx.gd                   runtime music + SFX synthesis
  crazy_sdk.gd             CrazyGames SDK bridge (autoload)
  hud.gd                   score/mission panels, steer buttons, onboarding
```
