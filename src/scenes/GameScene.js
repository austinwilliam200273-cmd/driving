// GameScene: the Endless Mode run. Top-down vertical scroller where the player
// drops craters to slow a chasing rival van.

import {
  GAME_WIDTH, GAME_HEIGHT, ROAD_X, ROAD_WIDTH, ROAD_RIGHT, PLAYER_Y,
  LANE_CENTERS, LANES, SMASH_COST, COLORS,
} from '../constants.js';
import { overlap } from '../util.js';
import PlayerTruck from '../entities/PlayerTruck.js';
import RivalVan from '../entities/RivalVan.js';
import Crater from '../entities/Crater.js';
import TrafficCar from '../entities/TrafficCar.js';
import EnergySystem from '../systems/EnergySystem.js';
import ScoreSystem from '../systems/ScoreSystem.js';
import InputController from '../systems/InputController.js';
import AudioManager from '../systems/AudioManager.js';
import HUD from '../ui/HUD.js';

const MAX_HITS = 3;

export default class GameScene extends Phaser.Scene {
  constructor() {
    super('GameScene');
  }

  create() {
    // --- world / run state ---
    this.scrollSpeed = 340; // base px/sec, grows over time
    this.distance = 0; // metres
    this.hits = 0; // times the rival rammed the player
    this.gameOver = false;
    this.craters = [];
    this.traffic = [];
    this.pickups = [];

    // --- scrolling road (tiled, dashed lane lines sell the motion) ---
    this.road = this.add
      .tileSprite(ROAD_X + ROAD_WIDTH / 2, GAME_HEIGHT / 2, ROAD_WIDTH, GAME_HEIGHT, 'road')
      .setDepth(0);

    // --- entities ---
    this.player = new PlayerTruck(this);
    this.rival = new RivalVan(this);

    // --- systems ---
    this.energy = new EnergySystem();
    this.score = new ScoreSystem();
    this.controls = new InputController(this);
    this.audio = new AudioManager();
    this.hud = new HUD(this, this.controls);

    // Unlock Web Audio on the first user gesture (autoplay policy).
    this.input.once('pointerdown', () => this.audio.unlock());
    this.input.keyboard.once('keydown', () => this.audio.unlock());

    // --- spawn timers ---
    this.trafficTimer = this.time.addEvent({ delay: 1300, loop: true, callback: () => this.spawnTraffic() });
    this.pickupTimer = this.time.addEvent({ delay: 2600, loop: true, callback: () => this.spawnPickup() });
  }

  update(time, delta) {
    if (this.gameOver) return;
    const dt = Math.min(delta / 1000, 0.05); // clamp big frame gaps

    // speed creeps up over time
    this.scrollSpeed = Math.min(this.scrollSpeed + 6 * dt, 760);
    const eff = this.scrollSpeed * this.player.speedMod; // effective road scroll

    // distance / score
    this.distance += eff * dt * 0.08;

    // --- input ---
    this.player.steer(this.controls.steer, dt);
    if (this.controls.consumeSmash()) this.trySmash();

    // --- systems update ---
    this.player.update(dt);
    this.energy.update(dt);

    // --- road scroll ---
    this.road.tilePositionY -= eff * dt;

    // --- entity updates + collisions ---
    this.updateCraters(dt, eff);
    this.updateTraffic(dt, eff);
    this.updatePickups(dt, eff);
    this.updateRival(dt, eff);

    // --- HUD ---
    const gap = this.rival.sprite.y - this.player.sprite.y;
    const proximity = Phaser.Math.Clamp(1 - gap / 400, 0, 1);
    this.hud.update(this.score.total(this.distance), this.distance, this.energy.value, proximity);

    // --- lose conditions ---
    if (this.hits >= MAX_HITS) this.endGame();
    const halfW = this.player.sprite.width / 2;
    if (this.player.sprite.x < ROAD_X + halfW * 0.4 || this.player.sprite.x > ROAD_RIGHT - halfW * 0.4) {
      // knocked off the road edge
      this.endGame();
    }
  }

  // ---- SMASH ----
  trySmash() {
    if (this.player.windingUp) return;
    if (!this.energy.canSpend(SMASH_COST)) return;
    this.energy.spend(SMASH_COST);
    this.audio.smash();
    // ~0.25s wind-up, then drop the crater just behind the truck.
    this.player.windup(() => {
      this.spawnCrater(this.player.sprite.x, this.player.sprite.y + 70);
    });
  }

  spawnCrater(x, y) {
    this.craters.push(new Crater(this, x, y));
    this.burst(x, y, 'spark', 10, null, 220);
    this.cameras.main.shake(90, 0.006);
  }

  // ---- craters ----
  updateCraters(dt, eff) {
    for (let i = this.craters.length - 1; i >= 0; i--) {
      const c = this.craters[i];
      c.update(dt, eff);

      // rival hit
      if (!c.hitRival && this.rival.state !== 'STUNNED' && overlap(c.sprite, this.rival.sprite)) {
        c.hitRival = true;
        this.rival.stun();
        this.audio.boing();
        this.cameras.main.shake(300, 0.025);
        this.cameras.main.flash(120, 255, 255, 255);
        this.burst(this.rival.sprite.x, this.rival.sprite.y, 'box', 7, null, 900);
        const res = this.score.registerRivalHit(this.time.now);
        if (res.multiplier > 1) {
          this.hud.showCombo(res.multiplier, res.combo);
          this.cameras.main.shake(180, 0.012);
        }
        this.floatText(this.rival.sprite.x, this.rival.sprite.y - 70, 'POW! +' + Math.round(50 * res.multiplier), '#f59e0b');
      }

      // self hit (smaller penalty) — guarded so it can only happen once per crater
      if (!c.hitPlayer && overlap(c.sprite, this.player.sprite)) {
        c.hitPlayer = true;
        this.player.applySpeedMod(0.85, 0.6);
        this.player.smallBounce();
        this.cameras.main.shake(80, 0.006);
      }

      if (c.dead) {
        c.destroy();
        this.craters.splice(i, 1);
      }
    }
  }

  // ---- traffic ----
  spawnTraffic() {
    if (this.gameOver) return;
    const lane = Phaser.Math.Between(0, LANES - 1);
    this.traffic.push(new TrafficCar(this, LANE_CENTERS[lane]));
  }

  updateTraffic(dt, eff) {
    for (let i = this.traffic.length - 1; i >= 0; i--) {
      const car = this.traffic[i];
      car.update(dt, eff);

      // player collision -> brief slowdown
      if (!car.collided && overlap(car.sprite, this.player.sprite)) {
        car.collided = true;
        this.player.applySpeedMod(0.6, 0.5);
        this.player.smallBounce();
        this.cameras.main.shake(120, 0.008);
        this.audio.impact();
      }

      // rival collision -> brief bump
      if (!car.hitRival && overlap(car.sprite, this.rival.sprite)) {
        car.hitRival = true;
        this.rival.bump();
      }

      // near-miss bonus when the car passes the player closely without a hit
      if (!car.counted && car.sprite.y > PLAYER_Y + 50) {
        car.counted = true;
        if (!car.collided && Math.abs(car.sprite.x - this.player.sprite.x) < 110) {
          this.score.addNearMiss();
          this.floatText(this.player.sprite.x, PLAYER_Y - 90, 'NEAR MISS +10', '#22c55e');
        }
      }

      if (car.dead) {
        car.destroy();
        this.traffic.splice(i, 1);
      }
    }
  }

  // ---- pickups ----
  spawnPickup() {
    if (this.gameOver) return;
    const lane = Phaser.Math.Between(0, LANES - 1);
    const boost = Math.random() < 0.4;
    const key = boost ? 'pickup_boost' : 'pickup_energy';
    const sprite = this.add.image(LANE_CENTERS[lane], -60, key).setDepth(12);
    this.tweens.add({ targets: sprite, scale: { from: 0.85, to: 1.1 }, duration: 500, yoyo: true, repeat: -1 });
    this.pickups.push({ sprite, boost });
  }

  updatePickups(dt, eff) {
    for (let i = this.pickups.length - 1; i >= 0; i--) {
      const p = this.pickups[i];
      p.sprite.y += eff * dt;

      if (overlap(p.sprite, this.player.sprite, 0.9)) {
        if (p.boost) {
          this.energy.add(10);
          this.player.applySpeedMod(1.25, 1.5); // brief speed boost
          this.floatText(p.sprite.x, p.sprite.y, 'BOOST!', '#facc15');
        } else {
          this.energy.add(20);
          this.floatText(p.sprite.x, p.sprite.y, '+20', '#22c55e');
        }
        this.audio.pickup();
        p.sprite.destroy();
        this.pickups.splice(i, 1);
        continue;
      }

      if (p.sprite.y > GAME_HEIGHT + 80) {
        p.sprite.destroy();
        this.pickups.splice(i, 1);
      }
    }
  }

  // ---- rival ----
  updateRival(dt, eff) {
    this.rival.update(dt, this.scrollSpeed, this.player);
    // relative screen movement: faster-than-road => climbs toward the player
    this.rival.sprite.y += (eff - this.rival.forwardSpeed) * dt;
    this.rival.sprite.y = Phaser.Math.Clamp(this.rival.sprite.y, 560, 1240);

    // ram the player
    if (this.rival.state !== 'STUNNED' && this.rival.hitCooldown <= 0 &&
        overlap(this.rival.sprite, this.player.sprite)) {
      this.hits++;
      this.rival.hitCooldown = 1.2;
      this.player.bounce();
      this.audio.impact();
      this.cameras.main.shake(260, 0.02);
      this.cameras.main.flash(120, 255, 80, 80);
      // knock both apart for readability
      this.rival.sprite.y += 130;
      this.floatText(this.player.sprite.x, PLAYER_Y, `RAMMED! ${this.hits}/${MAX_HITS}`, '#ef4444');
    }
  }

  // ---- fx helpers ----
  burst(x, y, texture, count, tint, lifespan) {
    const em = this.add.particles(x, y, texture, {
      speed: { min: 120, max: 320 },
      angle: { min: 0, max: 360 },
      lifespan,
      gravityY: 500,
      scale: { start: 1, end: 0.2 },
      rotate: { min: 0, max: 360 },
      quantity: count,
      emitting: false,
    }).setDepth(30);
    if (tint != null) em.setParticleTint(tint);
    em.explode(count);
    this.time.delayedCall(lifespan + 100, () => em.destroy());
  }

  floatText(x, y, msg, color) {
    const t = this.add.text(x, y, msg, {
      fontFamily: 'Arial, sans-serif', fontSize: '30px', color, fontStyle: 'bold',
      stroke: '#0f172a', strokeThickness: 5,
    }).setOrigin(0.5).setDepth(40);
    this.tweens.add({ targets: t, y: y - 70, alpha: 0, duration: 800, onComplete: () => t.destroy() });
  }

  // ---- game over ----
  endGame() {
    if (this.gameOver) return;
    this.gameOver = true;
    this.trafficTimer.remove();
    this.pickupTimer.remove();
    this.audio.gameover();
    this.cameras.main.shake(400, 0.03);
    this.time.delayedCall(450, () => {
      this.scene.start('GameOverScene', {
        score: this.score.total(this.distance),
        distance: Math.floor(this.distance),
        rivalHits: this.score.rivalHits,
        rams: this.hits,
        nearMiss: this.score.nearMiss,
      });
    });
  }
}
