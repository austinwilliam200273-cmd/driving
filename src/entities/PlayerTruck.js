// PlayerTruck: lateral steering + squash/stretch animations.
// The truck holds a `speedMod` that the GameScene multiplies into the world
// scroll speed (penalties slow the road, the boost pickup speeds it up).

import { ROAD_X, ROAD_RIGHT, PLAYER_Y, LANE_CENTERS } from '../constants.js';

export default class PlayerTruck {
  constructor(scene) {
    this.scene = scene;
    this.sprite = scene.add.image(LANE_CENTERS[1], PLAYER_Y, 'truck').setDepth(20);
    this.lateralSpeed = 560; // px/sec sideways
    this.speedMod = 1; // multiplier applied to world scroll speed
    this._modTimer = 0;
    this.windingUp = false;
  }

  // dir: -1 left, +1 right, 0 none. Clamped to the road edges.
  steer(dir, dt) {
    if (!dir) return;
    const halfW = this.sprite.width / 2;
    let x = this.sprite.x + dir * this.lateralSpeed * dt;
    x = Phaser.Math.Clamp(x, ROAD_X + halfW, ROAD_RIGHT - halfW);
    this.sprite.x = x;
    // subtle lean into the turn
    this.sprite.angle = Phaser.Math.Linear(this.sprite.angle, dir * 8, 0.2);
  }

  // 0.25s smash wind-up (squash), then run the callback to drop the crater.
  windup(cb) {
    if (this.windingUp) return;
    this.windingUp = true;
    this.scene.tweens.add({
      targets: this.sprite,
      scaleX: 1.3,
      scaleY: 0.7,
      duration: 120,
      yoyo: true,
      onComplete: () => {
        this.windingUp = false;
        this.sprite.setScale(1);
        if (cb) cb();
      },
    });
  }

  bounce() {
    this.scene.tweens.add({
      targets: this.sprite,
      scaleX: 0.7,
      scaleY: 1.3,
      duration: 110,
      yoyo: true,
    });
  }

  smallBounce() {
    this.scene.tweens.add({
      targets: this.sprite,
      scaleX: 1.2,
      scaleY: 0.85,
      duration: 90,
      yoyo: true,
    });
  }

  // Temporary speed change (penalty < 1, boost > 1).
  applySpeedMod(factor, duration) {
    this.speedMod = factor;
    this._modTimer = duration;
  }

  update(dt) {
    // ease the turn-lean back to centre
    this.sprite.angle = Phaser.Math.Linear(this.sprite.angle, 0, 0.15);
    if (this._modTimer > 0) {
      this._modTimer -= dt;
      if (this._modTimer <= 0) this.speedMod = 1;
    }
  }
}
