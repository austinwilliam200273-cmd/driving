# Road: asphalt with speckle texture, tire-wear strips, red/white curbs and
# dashed lane dividers, all scrolling downward (driven by `scroll`) to sell
# forward motion. Grass verges get mow-band shading on both sides.
extends Node2D
class_name Road

const CURB_W := 8.0
const WALK_W := 20.0

var scroll := 0.0

# Deterministic pseudo-random in [0,1) from an integer key (stable per road row).
static func _hash01(k: int) -> float:
	return fposmod(sin(float(k) * 127.1 + 311.7) * 43758.5453, 1.0)

func _draw() -> void:
	# grassy verges
	draw_rect(Rect2(0, 0, Consts.ROAD_X, Consts.GAME_H), Consts.GRASS)
	draw_rect(Rect2(Consts.ROAD_RIGHT, 0, Consts.GAME_W - Consts.ROAD_RIGHT, Consts.GAME_H), Consts.GRASS)

	# scrolling grass shade bands to sell motion on the verges
	var gperiod := 120.0
	var goff := fmod(scroll, gperiod)
	var gy := -gperiod + goff
	while gy < Consts.GAME_H:
		draw_rect(Rect2(0, gy, Consts.ROAD_X, 60), Consts.GRASS_DARK)
		draw_rect(Rect2(Consts.ROAD_RIGHT, gy, Consts.GAME_W - Consts.ROAD_RIGHT, 60), Consts.GRASS_DARK)
		gy += gperiod

	# sidewalks between grass and curb
	draw_rect(Rect2(Consts.ROAD_X - CURB_W - WALK_W, 0, WALK_W, Consts.GAME_H), Consts.SIDEWALK)
	draw_rect(Rect2(Consts.ROAD_RIGHT + CURB_W, 0, WALK_W, Consts.GAME_H), Consts.SIDEWALK)
	var speriod := 80.0
	var soff := fmod(scroll, speriod)
	var sy := -speriod + soff
	while sy < Consts.GAME_H:
		draw_rect(Rect2(Consts.ROAD_X - CURB_W - WALK_W, sy, WALK_W, 4), Consts.SIDEWALK_LINE)
		draw_rect(Rect2(Consts.ROAD_RIGHT + CURB_W, sy, WALK_W, 4), Consts.SIDEWALK_LINE)
		sy += speriod

	# red/white curbs hugging the road edges
	var cperiod := 88.0
	var coff := fmod(scroll, cperiod)
	var cy := -cperiod + coff
	var ci := int(floor(scroll / cperiod))
	var block := 0
	while cy < Consts.GAME_H:
		var col := Consts.CURB_A if (block + ci) % 2 == 0 else Consts.CURB_B
		draw_rect(Rect2(Consts.ROAD_X - CURB_W, cy, CURB_W, cperiod / 2.0), col)
		draw_rect(Rect2(Consts.ROAD_RIGHT, cy, CURB_W, cperiod / 2.0), col)
		var col2 := Consts.CURB_B if (block + ci) % 2 == 0 else Consts.CURB_A
		draw_rect(Rect2(Consts.ROAD_X - CURB_W, cy + cperiod / 2.0, CURB_W, cperiod / 2.0), col2)
		draw_rect(Rect2(Consts.ROAD_RIGHT, cy + cperiod / 2.0, CURB_W, cperiod / 2.0), col2)
		cy += cperiod
		block += 1

	# road surface + solid white edge lines
	draw_rect(Rect2(Consts.ROAD_X, 0, Consts.ROAD_W, Consts.GAME_H), Consts.ROAD)
	draw_rect(Rect2(Consts.ROAD_X + 4, 0, 6, Consts.GAME_H), Consts.EDGE)
	draw_rect(Rect2(Consts.ROAD_RIGHT - 10, 0, 6, Consts.GAME_H), Consts.EDGE)

	# darker tire-wear strips where wheels run in each lane
	for lc in Consts.LANE_CENTERS:
		draw_rect(Rect2(lc - 38, 0, 20, Consts.GAME_H), Color(0, 0, 0, 0.09))
		draw_rect(Rect2(lc + 18, 0, 20, Consts.GAME_H), Color(0, 0, 0, 0.09))

	# asphalt speckle texture — deterministic dots per physical road row so the
	# pattern scrolls with the road instead of shimmering
	var rperiod := 26.0
	var roff := fmod(scroll, rperiod)
	var base_row := int(floor(scroll / rperiod))
	var i := -1
	while i * rperiod + roff - rperiod < Consts.GAME_H:
		var y := i * rperiod + roff - rperiod
		var row := i - base_row
		for j in 4:
			var h1 := _hash01(row * 7 + j * 131)
			var h2 := _hash01(row * 13 + j * 197 + 57)
			var x := Consts.ROAD_X + 14 + h1 * (Consts.ROAD_W - 28)
			var sz := 2.0 + h2 * 3.0
			var col := Consts.ROAD_LIGHT if h2 > 0.5 else Consts.ROAD_DARK
			draw_rect(Rect2(x, y + h2 * rperiod, sz, sz), Color(col.r, col.g, col.b, 0.55))
		i += 1

	# dashed yellow lane dividers
	var period := 72.0
	var off := fmod(scroll, period)
	for k in range(1, Consts.LANES):
		var lx: float = Consts.ROAD_X + Consts.LANE_W * k
		var y := -period + off
		while y < Consts.GAME_H:
			draw_rect(Rect2(lx - 4, y, 8, 40), Consts.STRIPE)
			y += period
