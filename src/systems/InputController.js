// InputController: unifies keyboard and on-screen-button input.
//
// Steering:  A / D or Left / Right arrows, or the HUD steer buttons.
// Smash:     Spacebar, or the HUD smash button.
//
// The HUD buttons call setLeft/setRight/queueSmash on this object, so the
// GameScene only ever reads `steer` and `consumeSmash()`.

export default class InputController {
  constructor(scene) {
    this.scene = scene;
    const kb = scene.input.keyboard;
    this.cursors = kb.createCursorKeys();
    this.keyA = kb.addKey(Phaser.Input.Keyboard.KeyCodes.A);
    this.keyD = kb.addKey(Phaser.Input.Keyboard.KeyCodes.D);
    this.keySpace = kb.addKey(Phaser.Input.Keyboard.KeyCodes.SPACE);

    this.btnLeft = false;
    this.btnRight = false;
    this._smashQueued = false;

    // Spacebar edge -> queue a smash.
    this.keySpace.on('down', () => { this._smashQueued = true; });
  }

  // -1, 0 or +1.
  get steer() {
    let d = 0;
    if (this.cursors.left.isDown || this.keyA.isDown || this.btnLeft) d -= 1;
    if (this.cursors.right.isDown || this.keyD.isDown || this.btnRight) d += 1;
    return d;
  }

  setLeft(v) { this.btnLeft = v; }
  setRight(v) { this.btnRight = v; }
  queueSmash() { this._smashQueued = true; }

  // Returns true once per queued smash.
  consumeSmash() {
    if (this._smashQueued) {
      this._smashQueued = false;
      return true;
    }
    return false;
  }
}
