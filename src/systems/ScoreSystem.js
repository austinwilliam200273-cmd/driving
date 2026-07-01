// ScoreSystem: tracks bonuses and the combo multiplier.
//
//   score = floor(distance_m) + bonus + nearMiss * 10
//
// `bonus` accumulates from rival pothole hits (50 each, scaled by the combo
// multiplier). Two or more rival hits within COMBO_WINDOW ms raise the tier.

const COMBO_WINDOW = 5000; // ms

export default class ScoreSystem {
  constructor() {
    this.bonus = 0;
    this.nearMiss = 0;
    this.rivalHits = 0;
    this.comboCount = 0;
    this.lastHit = -Infinity;
  }

  // Returns { multiplier, combo } so the HUD can show a popup.
  registerRivalHit(now) {
    this.rivalHits++;
    if (now - this.lastHit < COMBO_WINDOW) this.comboCount++;
    else this.comboCount = 1;
    this.lastHit = now;

    let m = 1;
    if (this.comboCount >= 4) m = 2;
    else if (this.comboCount === 3) m = 1.5;
    else if (this.comboCount === 2) m = 1.2;

    this.bonus += Math.round(50 * m);
    return { multiplier: m, combo: this.comboCount };
  }

  addNearMiss() {
    this.nearMiss++;
  }

  total(distanceMeters) {
    return Math.floor(distanceMeters) + this.bonus + this.nearMiss * 10;
  }
}
