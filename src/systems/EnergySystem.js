// EnergySystem: the 0..100 "Asphalt Energy" resource that powers the smash.

import { ENERGY_MAX, ENERGY_REGEN } from '../constants.js';

export default class EnergySystem {
  constructor(max = ENERGY_MAX, regen = ENERGY_REGEN) {
    this.max = max;
    this.regen = regen;
    this.value = max; // starts full
  }

  canSpend(amount) {
    return this.value >= amount;
  }

  spend(amount) {
    this.value = Math.max(0, this.value - amount);
  }

  add(amount) {
    this.value = Math.min(this.max, this.value + amount);
  }

  // Passive regeneration.
  update(dt) {
    this.add(this.regen * dt);
  }
}
