// Shared game constants. Imported by scenes, entities and systems.

export const GAME_WIDTH = 720;
export const GAME_HEIGHT = 1280;

// Road geometry (centred horizontally with pastel sky on either side).
export const ROAD_X = 100; // left edge of road
export const ROAD_WIDTH = 520; // playable road width
export const ROAD_RIGHT = ROAD_X + ROAD_WIDTH; // 620
export const LANES = 4;
export const LANE_WIDTH = ROAD_WIDTH / LANES; // 130

// X centre of each lane.
export const LANE_CENTERS = Array.from(
  { length: LANES },
  (_, i) => ROAD_X + LANE_WIDTH * (i + 0.5)
);

// The player's truck sits at a fixed Y; the world scrolls past it.
export const PLAYER_Y = 850;

// Energy economy.
export const ENERGY_MAX = 100;
export const ENERGY_REGEN = 4; // per second
export const SMASH_COST = 25;

// Flat colour palette (hex numbers for Phaser).
export const COLORS = {
  sky: 0xbae6fd,
  road: 0x4b5563,
  laneStripe: 0xfacc15,
  player: 0xc2410c,
  rival: 0x2563eb,
  craterDark: 0x111827,
  craterLight: 0x374151,
  pickupEnergy: 0x22c55e,
  pickupBoost: 0xfacc15,
  box: 0x92400e,
};
