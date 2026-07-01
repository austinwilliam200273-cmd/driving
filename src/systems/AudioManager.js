// AudioManager: placeholder SFX synthesised with the Web Audio API
// (simple oscillator beeps — no audio files needed).
//
// IMPORTANT: browsers block audio until a user gesture, so the AudioContext is
// created/resumed on the first pointer/key interaction via unlock(). The same
// "start audio after user interaction" rule applies to the CrazyGames SDK
// integration later (and to its own audio handling).

export default class AudioManager {
  constructor() {
    this.ctx = null;
    this.enabled = true;
  }

  _ensure() {
    if (!this.ctx) {
      const AC = window.AudioContext || window.webkitAudioContext;
      if (!AC) { this.enabled = false; return; }
      this.ctx = new AC();
    }
    if (this.ctx.state === 'suspended') this.ctx.resume();
  }

  // Call from a user-gesture handler to satisfy autoplay policies.
  unlock() {
    this._ensure();
  }

  tone(freq, dur, type = 'square', vol = 0.15, slideTo = null) {
    if (!this.enabled) return;
    this._ensure();
    if (!this.ctx) return;
    const t = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    osc.type = type;
    osc.frequency.setValueAtTime(freq, t);
    if (slideTo) osc.frequency.exponentialRampToValueAtTime(slideTo, t + dur);
    gain.gain.setValueAtTime(vol, t);
    gain.gain.exponentialRampToValueAtTime(0.0001, t + dur);
    osc.connect(gain);
    gain.connect(this.ctx.destination);
    osc.start(t);
    osc.stop(t + dur);
  }

  smash() { this.tone(220, 0.18, 'sawtooth', 0.12, 120); }
  impact() { this.tone(90, 0.25, 'square', 0.18, 50); }
  boing() { this.tone(300, 0.32, 'sine', 0.2, 900); }
  pickup() { this.tone(660, 0.12, 'triangle', 0.16, 990); }
  gameover() { this.tone(420, 0.6, 'sawtooth', 0.16, 80); }
}
