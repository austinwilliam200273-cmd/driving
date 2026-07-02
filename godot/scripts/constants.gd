# Shared constants (geometry, tuning, colours). Access as Consts.NAME.
class_name Consts

# Canvas / road geometry — landscape 16:9, designed for desktop web first.
const GAME_W := 1280.0
const GAME_H := 720.0
const LANES := 4
const LANE_W := 140.0
const ROAD_W := 560.0                       # LANES * LANE_W
const ROAD_X := 360.0                       # (GAME_W - ROAD_W) / 2
const ROAD_RIGHT := 920.0                   # ROAD_X + ROAD_W
const LANE_CENTERS := [430.0, 570.0, 710.0, 850.0]
const PLAYER_Y := 560.0

# Run tuning
const SPEED_BASE := 300.0                   # px/sec at the start of a run
const SPEED_MAX := 980.0                    # px/sec cap late game
const SPEED_ACCEL := 8.0                    # px/sec gained per second

# Scoring
const NEAR_MISS_PTS := 10
const PATCH_PTS := 25                       # base points per patched pothole
const PATCH_COMBO_CAP := 4                  # combo multiplies patch points up to this
const MISSION_PTS := 300

# Flat colour palette
const SKY := Color(0.729, 0.902, 0.992)
const SKY_LOW := Color(0.851, 0.949, 0.973)
const ROAD := Color(0.294, 0.333, 0.388)
const ROAD_LIGHT := Color(0.345, 0.384, 0.439)
const ROAD_DARK := Color(0.247, 0.282, 0.333)
const EDGE := Color(0.898, 0.906, 0.922)
const STRIPE := Color(0.980, 0.800, 0.082)
const PLAYER := Color(0.760, 0.255, 0.047)
const CRATER_DARK := Color(0.067, 0.094, 0.153)
const CRATER_LIGHT := Color(0.216, 0.255, 0.318)
const PATCH := Color(0.180, 0.208, 0.255)
const PATCH_EDGE := Color(0.420, 0.455, 0.510)
const WINDOW := Color(0.06, 0.09, 0.16, 0.85)
const WHEEL := Color(0.07, 0.09, 0.15)
const TEXT_GOOD := Color(0.133, 0.773, 0.369)
const TEXT_GOLD := Color(0.980, 0.800, 0.082)

# Roadside scenery + vehicle lighting
const GRASS := Color(0.36, 0.62, 0.34)
const GRASS_DARK := Color(0.30, 0.55, 0.29)
const SIDEWALK := Color(0.74, 0.76, 0.78)
const SIDEWALK_LINE := Color(0.62, 0.64, 0.67)
const CURB_A := Color(0.82, 0.30, 0.28)
const CURB_B := Color(0.90, 0.90, 0.92)
const HEADLIGHT := Color(1.0, 0.96, 0.65)
const TAILLIGHT := Color(0.90, 0.16, 0.12)
const SHADOW := Color(0, 0, 0, 0.18)
