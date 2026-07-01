// GameOverScene: final score, persistent high score (localStorage), run stats,
// and a Play Again button that restarts GameScene instantly (no page reload).

import { GAME_WIDTH, GAME_HEIGHT } from '../constants.js';

const FONT = 'Arial, "Segoe UI", sans-serif';
const HS_KEY = 'pp_highscore';

export default class GameOverScene extends Phaser.Scene {
  constructor() {
    super('GameOverScene');
  }

  create(data) {
    const cx = GAME_WIDTH / 2;

    // persist high score
    let high = 0;
    try { high = parseInt(localStorage.getItem(HS_KEY) || '0', 10) || 0; } catch (e) { /* storage blocked */ }
    const isNewBest = data.score > high;
    if (isNewBest) {
      high = data.score;
      try { localStorage.setItem(HS_KEY, String(high)); } catch (e) { /* ignore */ }
    }

    // dim background
    this.add.rectangle(cx, GAME_HEIGHT / 2, GAME_WIDTH, GAME_HEIGHT, 0x0f172a, 0.78);

    this.add.text(cx, 240, 'GAME OVER', {
      fontFamily: FONT, fontSize: '88px', color: '#f97316', fontStyle: 'bold',
      stroke: '#7c2d12', strokeThickness: 10,
    }).setOrigin(0.5);

    this.add.text(cx, 380, 'SCORE', { fontFamily: FONT, fontSize: '34px', color: '#cbd5e1' }).setOrigin(0.5);
    this.add.text(cx, 440, String(data.score), {
      fontFamily: FONT, fontSize: '96px', color: '#ffffff', fontStyle: 'bold',
    }).setOrigin(0.5);

    this.add.text(cx, 540, (isNewBest ? '★ NEW BEST ★  ' : 'HIGH SCORE  ') + high, {
      fontFamily: FONT, fontSize: '34px', color: isNewBest ? '#facc15' : '#94a3b8', fontStyle: 'bold',
    }).setOrigin(0.5);

    // run stats
    const stats = [
      `Distance: ${data.distance} m`,
      `Rival potholes landed: ${data.rivalHits}`,
      `Near misses: ${data.nearMiss}`,
      `Times rammed: ${data.rams}/3`,
    ];
    this.add.text(cx, 700, stats.join('\n'), {
      fontFamily: FONT, fontSize: '32px', color: '#e2e8f0', align: 'center', lineSpacing: 14,
    }).setOrigin(0.5);

    // Play Again button
    const btn = this.add.rectangle(cx, 980, 380, 110, 0xc2410c).setStrokeStyle(5, 0x7c2d12)
      .setInteractive({ useHandCursor: true });
    this.add.text(cx, 980, 'PLAY AGAIN', {
      fontFamily: FONT, fontSize: '44px', color: '#ffffff', fontStyle: 'bold',
    }).setOrigin(0.5);

    const restart = () => this.scene.start('GameScene');
    btn.on('pointerover', () => btn.setFillStyle(0xea580c));
    btn.on('pointerout', () => btn.setFillStyle(0xc2410c));
    btn.on('pointerdown', restart);

    this.add.text(cx, 1080, 'or press SPACE / ENTER', {
      fontFamily: FONT, fontSize: '26px', color: '#94a3b8',
    }).setOrigin(0.5);
    this.input.keyboard.once('keydown-SPACE', restart);
    this.input.keyboard.once('keydown-ENTER', restart);
  }
}
