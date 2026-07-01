// Phaser configuration + scene list. Boots straight into gameplay.

import { GAME_WIDTH, GAME_HEIGHT, COLORS } from './constants.js';
import BootScene from './scenes/BootScene.js';
import GameScene from './scenes/GameScene.js';
import GameOverScene from './scenes/GameOverScene.js';

const config = {
  type: Phaser.AUTO,
  width: GAME_WIDTH,
  height: GAME_HEIGHT,
  backgroundColor: COLORS.sky, // pastel sky shows either side of the road
  parent: 'game',
  // FIT keeps the 720x1280 portrait canvas correctly proportioned on any screen.
  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
    width: GAME_WIDTH,
    height: GAME_HEIGHT,
  },
  render: { pixelArt: false, antialias: true },
  // BootScene generates all textures, then hands straight to GameScene (Endless Mode).
  scene: [BootScene, GameScene, GameOverScene],
};

// eslint-disable-next-line no-new
new Phaser.Game(config);
