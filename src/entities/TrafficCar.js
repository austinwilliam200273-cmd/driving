// TrafficCar: a slow neutral obstacle. Spawns above the view and drifts down.
// Both the player and the rival must steer around it (collision = brief slow).

import { GAME_HEIGHT } from '../constants.js';

// Other cars move forward slowly, so relative to the road they drift downward
// at (1 - FORWARD_FACTOR) of the scroll speed.
const FORWARD_FACTOR = 0.45;

const TINTS = [0xef4444, 0x10b981, 0x8b5cf6, 0xf59e0b, 0xec4899, 0x14b8a6];

export default class TrafficCar {
  constructor(scene, x) {
    this.scene = scene;
    this.sprite = scene.add.image(x, -120, 'traffic').setDepth(15);
    this.sprite.setTint(Phaser.Utils.Array.GetRandom(TINTS));
    this.collided = false; // hit the player
    this.hitRival = false; // hit the rival
    this.counted = false; // near-miss accounted for
  }

  update(dt, scrollSpeed) {
    this.sprite.y += scrollSpeed * (1 - FORWARD_FACTOR) * dt;
  }

  get dead() {
    return this.sprite.y > GAME_HEIGHT + 140;
  }

  destroy() {
    this.sprite.destroy();
  }
}
