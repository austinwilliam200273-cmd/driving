// BootScene generates every texture programmatically (no external art files),
// then immediately launches GameScene so the player lands in gameplay on load.

import { ROAD_WIDTH, COLORS } from '../constants.js';

export default class BootScene extends Phaser.Scene {
  constructor() {
    super('BootScene');
  }

  create() {
    this.makeVehicle('truck', COLORS.player);
    this.makeVehicle('van', COLORS.rival);
    this.makeVehicle('traffic', 0x9ca3af); // tinted per-instance
    this.makeRoad();
    this.makeCrater();
    this.makePickup('pickup_energy', COLORS.pickupEnergy);
    this.makePickup('pickup_boost', COLORS.pickupBoost);
    this.makeBox();
    this.makeSpark();

    // Straight into Endless Mode — no mandatory menu.
    this.scene.start('GameScene');
  }

  // A blank graphics object that is NOT added to the display list.
  gfx() {
    return this.make.graphics({ x: 0, y: 0, add: false });
  }

  // Top-down vehicle: rounded body, two tinted windows, four dark wheels.
  makeVehicle(key, color, w = 64, h = 104) {
    const g = this.gfx();
    g.fillStyle(color, 1);
    g.fillRoundedRect(4, 4, w - 8, h - 8, 14);
    // darker roof outline accent
    g.lineStyle(3, 0x000000, 0.25);
    g.strokeRoundedRect(4, 4, w - 8, h - 8, 14);
    // windows
    g.fillStyle(0x0f172a, 0.85);
    g.fillRoundedRect(12, 16, w - 24, 22, 6); // front windshield
    g.fillRoundedRect(12, h - 40, w - 24, 20, 6); // rear window
    // wheels
    g.fillStyle(0x111827, 1);
    g.fillRect(0, 22, 7, 26);
    g.fillRect(w - 7, 22, 7, 26);
    g.fillRect(0, h - 48, 7, 26);
    g.fillRect(w - 7, h - 48, 7, 26);
    g.generateTexture(key, w, h);
    g.destroy();
  }

  // Tileable road slice: dark asphalt, light edges, dashed yellow lane dividers.
  makeRoad() {
    const w = ROAD_WIDTH;
    const h = 256; // tiles cleanly (256 / 64 = 4)
    const g = this.gfx();
    g.fillStyle(COLORS.road, 1);
    g.fillRect(0, 0, w, h);
    // solid light edge lines
    g.fillStyle(0xe5e7eb, 1);
    g.fillRect(0, 0, 6, h);
    g.fillRect(w - 6, 0, 6, h);
    // dashed lane dividers
    g.fillStyle(COLORS.laneStripe, 1);
    for (const lx of [w / 4, w / 2, (3 * w) / 4]) {
      for (let y = 0; y < h; y += 64) {
        g.fillRect(lx - 4, y, 8, 36);
      }
    }
    g.generateTexture('road', w, h);
    g.destroy();
  }

  // Crater: dark circle, lighter inner ring, a few cracks.
  makeCrater() {
    const r = 46;
    const s = r * 2;
    const g = this.gfx();
    g.fillStyle(COLORS.craterDark, 1);
    g.fillCircle(r, r, r);
    g.fillStyle(COLORS.craterLight, 1);
    g.fillCircle(r, r, r - 9);
    g.lineStyle(3, 0x6b7280, 1);
    for (let i = 0; i < 6; i++) {
      const a = (Math.PI * 2 * i) / 6;
      g.lineBetween(r, r, r + Math.cos(a) * (r - 6), r + Math.sin(a) * (r - 6));
    }
    g.generateTexture('crater', s, s);
    g.destroy();
  }

  // Pickup: filled circle with a white ring.
  makePickup(key, color, r = 18) {
    const s = r * 2 + 4;
    const c = s / 2;
    const g = this.gfx();
    g.fillStyle(0xffffff, 1);
    g.fillCircle(c, c, r + 2);
    g.fillStyle(color, 1);
    g.fillCircle(c, c, r);
    g.generateTexture(key, s, s);
    g.destroy();
  }

  // Small "flying box" debris particle.
  makeBox() {
    const g = this.gfx();
    g.fillStyle(COLORS.box, 1);
    g.fillRoundedRect(0, 0, 18, 18, 3);
    g.lineStyle(2, 0x000000, 0.3);
    g.strokeRoundedRect(0, 0, 18, 18, 3);
    g.generateTexture('box', 18, 18);
    g.destroy();
  }

  // Tiny dust spark particle.
  makeSpark() {
    const g = this.gfx();
    g.fillStyle(0xfde68a, 1);
    g.fillRect(0, 0, 8, 8);
    g.generateTexture('spark', 8, 8);
    g.destroy();
  }
}
