// Crater: a road hazard dropped by the player's smash.
// It is fixed to the road, so it scrolls downward with the world and fades
// out after its lifetime. `hitRival` / `hitPlayer` guard against double hits.

import { GAME_HEIGHT } from '../constants.js';

const LIFETIME = 6; // seconds

export default class Crater {
  constructor(scene, x, y) {
    this.scene = scene;
    this.sprite = scene.add.image(x, y, 'crater').setDepth(5);
    this.life = LIFETIME;
    this.hitRival = false;
    this.hitPlayer = false;

    // pop-in
    this.sprite.setScale(0.2);
    scene.tweens.add({
      targets: this.sprite,
      scaleX: 1,
      scaleY: 1,
      duration: 180,
      ease: 'Back.Out',
    });
  }

  update(dt, scrollSpeed) {
    this.sprite.y += scrollSpeed * dt; // fixed to the road
    this.life -= dt;
    if (this.life < 1) this.sprite.setAlpha(Math.max(0, this.life));
  }

  get dead() {
    return this.life <= 0 || this.sprite.y > GAME_HEIGHT + 120;
  }

  destroy() {
    this.sprite.destroy();
  }
}
