# Pothole Patrol

A top-down, vertically-scrolling arcade chase racer built with **Phaser 3**. You
drive a repair truck and **SMASH** the road to create potholes that bounce and
slow a rival delivery van chasing you. Offense, not defense — survive, rack up
distance, and land crater combos.

All art is drawn programmatically with Phaser Graphics (colored rectangles /
circles) and all SFX are synthesised with the Web Audio API, so there are **no
external asset files** — the game is fully playable as-is.

## Run it locally

ES modules require the page to be *served over http://* (opening `index.html`
directly via `file://` will be blocked by the browser's module CORS policy), so
use any static server:

```bash
# from the project folder
npx serve .
# then open the printed URL (e.g. http://localhost:3000)
```

Alternatives: `python -m http.server 8000`, or the VS Code "Live Server"
extension. Phaser itself loads from a CDN, so no `npm install` is needed.

The game **boots straight into Endless Mode** — no menu, no required clicks.

## Controls

| Action | Desktop | Touch / Mouse |
| ------ | ------- | ------------- |
| Steer  | `A`/`D` or `←`/`→` | on-screen ◀ ▶ buttons (bottom-left) |
| Smash  | `Spacebar` | large SMASH button (bottom-right) |
| Restart (game over) | `Space` / `Enter` | PLAY AGAIN button |

## How it plays

- **Smash** costs 25 Asphalt Energy (bar regenerates at 4/sec; button greys out
  below 25). A ~0.25s wind-up squashes the truck, then drops a crater that lasts
  6s before fading.
- A crater that catches the **rival van** stuns it (~40% slower for 1.2s) with a
  bounce, particle pop, camera shake and screen flash.
- The rival uses a small FSM: `CRUISING` → `AGGRESSIVE` (closes in to ram) →
  `STUNNED` (after a crater) → `CATCHING_UP` (rubber-bands if it falls behind).
- Dodge neutral **traffic cars** (collision = brief slowdown; a close pass
  scores a near-miss bonus).
- Grab **pickups**: green = +20 energy, yellow = +10 energy + brief speed boost.
- **Game over** after 3 rams or being knocked off the road edge.
- **Scoring:** `distance_m + rivalHits*50 (×combo) + nearMiss*10`. Combo tiers
  (1.2× / 1.5× / 2×) fire on rapid rival hits. High score persists via
  `localStorage`.

## Project structure

```
index.html
src/
  main.js                 Phaser config + scene list
  constants.js            shared geometry / colours / tuning
  util.js                 overlap helper
  scenes/
    BootScene.js          generates all textures, then starts the game
    GameScene.js          the Endless Mode run + collisions + FX
    GameOverScene.js      score, high score, Play Again
  entities/
    PlayerTruck.js
    RivalVan.js
    Crater.js
    TrafficCar.js
  systems/
    EnergySystem.js
    ScoreSystem.js
    InputController.js     keyboard + on-screen buttons
    AudioManager.js        Web Audio placeholder SFX
  ui/
    HUD.js                 score, energy bar, proximity, touch buttons
```

## Next steps

**Real art** — replace the `generateTexture(...)` calls in `BootScene.js` with
`this.load.image(...)` / spritesheets in a `preload()`; the entities already
reference textures by key, so no other code changes are needed.

**Real audio** — swap `AudioManager` for `this.load.audio(...)` + `this.sound`.
Keep the "start on first user gesture" unlock — required by browser autoplay
policy.

**CrazyGames SDK** — load the SDK script, then wire:

```js
// loading
window.CrazyGames?.SDK.game.loadingStart();   // in BootScene.preload
window.CrazyGames?.SDK.game.loadingStop();     // when assets are ready
// per run
window.CrazyGames?.SDK.game.gameplayStart();   // GameScene.create
window.CrazyGames?.SDK.game.gameplayStop();    // GameScene.endGame
```

Audio must only start after a user interaction for the SDK too (already handled
by the `unlock()` gesture hook).
