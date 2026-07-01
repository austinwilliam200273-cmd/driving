// HUD: all on-screen UI built from Phaser Text/Graphics (no images/fonts).
//   Top-left : score + distance
//   Top-right: Asphalt Energy bar
//   Top-centre: rival proximity indicator
//   Bottom-left : left/right steer buttons (touch + mouse)
//   Bottom-right: large SMASH button (touch + mouse + Spacebar)
//
// All elements use setScrollFactor(0) so camera shake doesn't move them.

import { GAME_WIDTH, GAME_HEIGHT, ENERGY_MAX, SMASH_COST } from '../constants.js';

const FONT = 'Arial, "Segoe UI", sans-serif';
const UI_DEPTH = 1000;

export default class HUD {
  constructor(scene, input) {
    this.scene = scene;
    this.input = input;

    // --- score / distance (top-left) ---
    this.scoreText = scene.add
      .text(24, 22, 'SCORE 0', { fontFamily: FONT, fontSize: '40px', color: '#0f172a', fontStyle: 'bold' })
      .setScrollFactor(0)
      .setDepth(UI_DEPTH);
    this.distText = scene.add
      .text(24, 70, '0 m', { fontFamily: FONT, fontSize: '26px', color: '#1e3a8a' })
      .setScrollFactor(0)
      .setDepth(UI_DEPTH);

    // --- energy bar (top-right) ---
    this.energyLabel = scene.add
      .text(GAME_WIDTH - 24, 22, 'ASPHALT', { fontFamily: FONT, fontSize: '22px', color: '#166534', fontStyle: 'bold' })
      .setOrigin(1, 0)
      .setScrollFactor(0)
      .setDepth(UI_DEPTH);
    this.energyGfx = scene.add.graphics().setScrollFactor(0).setDepth(UI_DEPTH);
    this._energyBox = { x: GAME_WIDTH - 264, y: 54, w: 240, h: 30 };

    // --- proximity indicator (top-centre) ---
    this.proxLabel = scene.add
      .text(GAME_WIDTH / 2, 24, 'RIVAL', { fontFamily: FONT, fontSize: '20px', color: '#7f1d1d', fontStyle: 'bold' })
      .setOrigin(0.5, 0)
      .setScrollFactor(0)
      .setDepth(UI_DEPTH);
    this.proxGfx = scene.add.graphics().setScrollFactor(0).setDepth(UI_DEPTH);
    this._proxBox = { x: GAME_WIDTH / 2 - 110, y: 52, w: 220, h: 18 };

    this._buildButtons();
  }

  _buildButtons() {
    const s = this.scene;

    // SMASH button (bottom-right).
    this.smashCircle = s.add.circle(GAME_WIDTH - 120, GAME_HEIGHT - 150, 92, 0xc2410c, 0.92)
      .setScrollFactor(0).setDepth(UI_DEPTH).setInteractive({ useHandCursor: true });
    s.add.circle(GAME_WIDTH - 120, GAME_HEIGHT - 150, 92).setStrokeStyle(5, 0x7c2d12)
      .setScrollFactor(0).setDepth(UI_DEPTH);
    this.smashLabel = s.add
      .text(GAME_WIDTH - 120, GAME_HEIGHT - 150, 'SMASH', { fontFamily: FONT, fontSize: '30px', color: '#ffffff', fontStyle: 'bold' })
      .setOrigin(0.5).setScrollFactor(0).setDepth(UI_DEPTH + 1);
    this.smashCircle.on('pointerdown', () => this.input.queueSmash());

    // Steer buttons (bottom-left).
    this.leftBtn = this._steerButton(120, GAME_HEIGHT - 150, '◀', 'Left');
    this.rightBtn = this._steerButton(280, GAME_HEIGHT - 150, '▶', 'Right');
  }

  _steerButton(x, y, glyph, dir) {
    const s = this.scene;
    const c = s.add.circle(x, y, 70, 0x1e3a8a, 0.82)
      .setScrollFactor(0).setDepth(UI_DEPTH).setInteractive({ useHandCursor: true });
    s.add.circle(x, y, 70).setStrokeStyle(5, 0x1e293b).setScrollFactor(0).setDepth(UI_DEPTH);
    s.add.text(x, y, glyph, { fontFamily: FONT, fontSize: '46px', color: '#ffffff' })
      .setOrigin(0.5).setScrollFactor(0).setDepth(UI_DEPTH + 1);

    const set = (v) => (dir === 'Left' ? this.input.setLeft(v) : this.input.setRight(v));
    c.on('pointerdown', () => set(true));
    c.on('pointerup', () => set(false));
    c.on('pointerout', () => set(false));
    return c;
  }

  // Per-frame refresh.
  update(scoreTotal, distance, energy, proximity) {
    this.scoreText.setText('SCORE ' + scoreTotal);
    this.distText.setText(Math.floor(distance) + ' m');

    // energy bar
    const b = this._energyBox;
    const pct = Phaser.Math.Clamp(energy / ENERGY_MAX, 0, 1);
    const ready = energy >= SMASH_COST;
    this.energyGfx.clear();
    this.energyGfx.fillStyle(0x0f172a, 0.25).fillRoundedRect(b.x, b.y, b.w, b.h, 8);
    this.energyGfx.fillStyle(ready ? 0x22c55e : 0x9ca3af, 1)
      .fillRoundedRect(b.x + 3, b.y + 3, (b.w - 6) * pct, b.h - 6, 6);
    this.energyGfx.lineStyle(3, 0x0f172a, 0.6).strokeRoundedRect(b.x, b.y, b.w, b.h, 8);

    // proximity bar (red grows as the rival closes in)
    const p = this._proxBox;
    const c = Phaser.Math.Clamp(proximity, 0, 1);
    this.proxGfx.clear();
    this.proxGfx.fillStyle(0x0f172a, 0.25).fillRoundedRect(p.x, p.y, p.w, p.h, 6);
    const col = Phaser.Display.Color.Interpolate.ColorWithColor(
      new Phaser.Display.Color(34, 197, 94), new Phaser.Display.Color(220, 38, 38), 100, c * 100);
    this.proxGfx.fillStyle(Phaser.Display.Color.GetColor(col.r, col.g, col.b), 1)
      .fillRoundedRect(p.x + 2, p.y + 2, (p.w - 4) * c, p.h - 4, 5);

    // smash button enabled/disabled tint
    this.smashCircle.setFillStyle(ready ? 0xc2410c : 0x9ca3af, ready ? 0.92 : 0.6);
    this.smashLabel.setAlpha(ready ? 1 : 0.6);
  }

  // Combo multiplier popup.
  showCombo(mult, combo) {
    const t = this.scene.add
      .text(GAME_WIDTH / 2, GAME_HEIGHT / 2 - 80, `x${mult}  COMBO ${combo}!`, {
        fontFamily: FONT, fontSize: '64px', color: '#f59e0b', fontStyle: 'bold',
        stroke: '#7c2d12', strokeThickness: 8,
      })
      .setOrigin(0.5).setScrollFactor(0).setDepth(UI_DEPTH + 5).setScale(0.4);
    this.scene.tweens.add({
      targets: t, scale: 1, duration: 220, ease: 'Back.Out',
      onComplete: () => this.scene.tweens.add({
        targets: t, alpha: 0, y: t.y - 60, delay: 350, duration: 450,
        onComplete: () => t.destroy(),
      }),
    });
  }
}
