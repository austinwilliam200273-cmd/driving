# Shared constants (geometry, tuning, colours). Access as Consts.NAME.
class_name Consts

# Canvas / road geometry
const GAME_W := 720.0
const GAME_H := 1280.0
const ROAD_X := 100.0
const ROAD_W := 520.0
const ROAD_RIGHT := 620.0
const LANES := 4
const LANE_W := 130.0
const LANE_CENTERS := [165.0, 295.0, 425.0, 555.0]
const PLAYER_Y := 850.0

# Energy economy
const ENERGY_MAX := 100.0
const ENERGY_REGEN := 4.0
const SMASH_COST := 25.0

# Flat colour palette
const SKY := Color(0.729, 0.902, 0.992)
const ROAD := Color(0.294, 0.333, 0.388)
const EDGE := Color(0.898, 0.906, 0.922)
const STRIPE := Color(0.980, 0.800, 0.082)
const PLAYER := Color(0.760, 0.255, 0.047)
const RIVAL := Color(0.145, 0.388, 0.922)
const CRATER_DARK := Color(0.067, 0.094, 0.153)
const CRATER_LIGHT := Color(0.216, 0.255, 0.318)
const WINDOW := Color(0.06, 0.09, 0.16, 0.85)
const WHEEL := Color(0.07, 0.09, 0.15)
const PICKUP_ENERGY := Color(0.133, 0.773, 0.369)
const PICKUP_BOOST := Color(0.980, 0.800, 0.082)
const BOX := Color(0.573, 0.251, 0.055)

# Roadside scenery + vehicle lighting
const GRASS := Color(0.36, 0.62, 0.34)
const GRASS_DARK := Color(0.30, 0.55, 0.29)
const SIDEWALK := Color(0.74, 0.76, 0.78)
const SIDEWALK_LINE := Color(0.62, 0.64, 0.67)
const HEADLIGHT := Color(1.0, 0.96, 0.65)
const TAILLIGHT := Color(0.90, 0.16, 0.12)
const SHADOW := Color(0, 0, 0, 0.18)
