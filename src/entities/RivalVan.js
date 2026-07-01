// RivalVan: a chasing delivery van driven by a small finite-state machine.
// It never creates hazards — only the player smashes craters.
//
// States:
//   CRUISING    – default, drifts lazily between lanes at ~92% road speed
//   AGGRESSIVE  – close to the player: 115% speed, steers to match player lane
//   STUNNED     – just hit a crater: ~60% speed + wobble for ~1.2s
//   CATCHING_UP – fell too far behind: rubber-bands up to 128% to keep tension
//
// The van sits BELOW the player on screen (forward = up). Craters the player
// drops scroll downward into the chasing van.

import { ROAD_X, ROAD_RIGHT, PLAYER_Y, LANE_CENTERS } from '../constants.js';

export default class RivalVan {
  constructor(scene) {
    this.scene = scene;
    this.sprite = scene.add.image(LANE_CENTERS[2], PLAYER_Y + 300, 'van').setDepth(19);
    this.state = 'CRUISING';
    this.stateTimer = 0;
    this.speedFactor = 0.92; // relative to world scroll speed
    this.forwardSpeed = 0; // absolute px/sec (set each update by GameScene)
    this.laneSpeed = 360; // px/sec sideways
    this.hitCooldown = 0; // ram cooldown
    this.bumpTimer = 0; // brief slow after hitting traffic
    this.driftTimer = 0;
    this.driftTarget = this.sprite.x;
  }

  // Called when the van runs over a crater.
  stun() {
    this.state = 'STUNNED';
    this.stateTimer = 1.2;
    this.speedFactor = 0.6; // ~40% speed loss
    this.scene.tweens.add({
      targets: this.sprite,
      angle: { from: -14, to: 14 },
      duration: 80,
      yoyo: true,
      repeat: 7,
      onComplete: () => { this.sprite.angle = 0; },
    });
    this.scene.tweens.add({
      targets: this.sprite,
      scaleX: 1.35,
      scaleY: 0.65,
      duration: 130,
      yoyo: true,
    });
  }

  // Brief slow after clipping a traffic car.
  bump() {
    this.bumpTimer = 0.5;
    this.scene.tweens.add({
      targets: this.sprite,
      scaleX: 0.85,
      scaleY: 1.2,
      duration: 90,
      yoyo: true,
    });
  }

  update(dt, scrollSpeed, player) {
    this.hitCooldown = Math.max(0, this.hitCooldown - dt);
    this.bumpTimer = Math.max(0, this.bumpTimer - dt);

    const gap = this.sprite.y - player.sprite.y; // positive => behind/below

    // --- state transitions ---
    if (this.state === 'STUNNED') {
      this.stateTimer -= dt;
      if (this.stateTimer <= 0) this.state = 'CRUISING';
    } else if (gap > 360) {
      this.state = 'CATCHING_UP';
    } else if (gap < 280) {
      this.state = 'AGGRESSIVE';
    } else {
      this.state = 'CRUISING';
    }

    // --- per-state behaviour ---
    let targetX = this.sprite.x;
    if (this.state !== 'STUNNED') {
      switch (this.state) {
        case 'AGGRESSIVE':
          this.speedFactor = 1.15;
          targetX = player.sprite.x; // try to line up for a ram
          break;
        case 'CATCHING_UP':
          this.speedFactor = 1.28; // rubber-band
          targetX = player.sprite.x;
          break;
        default: // CRUISING — lazy lane drifting
          this.speedFactor = 0.92;
          this.driftTimer -= dt;
          if (this.driftTimer <= 0) {
            this.driftTimer = Phaser.Math.FloatBetween(1.2, 2.6);
            this.driftTarget = Phaser.Utils.Array.GetRandom(LANE_CENTERS);
          }
          targetX = this.driftTarget;
          break;
      }
    }

    // traffic bump damps speed regardless of state
    let factor = this.speedFactor;
    if (this.bumpTimer > 0) factor *= 0.6;

    // steer toward the lateral target
    const halfW = this.sprite.width / 2;
    this.sprite.x = Phaser.Math.Clamp(
      Phaser.Math.Approach(this.sprite.x, targetX, this.laneSpeed * dt),
      ROAD_X + halfW,
      ROAD_RIGHT - halfW
    );

    this.forwardSpeed = scrollSpeed * factor;
  }
}
