# Road: dark asphalt with light edges and dashed yellow lane dividers that
# scroll downward (driven by `scroll`) to sell forward motion.
extends Node2D
class_name Road

var scroll := 0.0

func _draw() -> void:
	# grassy verges
	draw_rect(Rect2(0, 0, Consts.ROAD_X, Consts.GAME_H), Consts.GRASS)
	draw_rect(Rect2(Consts.ROAD_RIGHT, 0, Consts.GAME_W - Consts.ROAD_RIGHT, Consts.GAME_H), Consts.GRASS)

	# scrolling grass texture bands (alternating shade) to sell motion on the verges
	var gperiod := 120.0
	var goff := fmod(scroll, gperiod)
	var gy := -gperiod + goff
	while gy < Consts.GAME_H:
		draw_rect(Rect2(0, gy, Consts.ROAD_X, 60), Consts.GRASS_DARK)
		draw_rect(Rect2(Consts.ROAD_RIGHT, gy, Consts.GAME_W - Consts.ROAD_RIGHT, 60), Consts.GRASS_DARK)
		gy += gperiod

	# sidewalks between grass and road
	draw_rect(Rect2(Consts.ROAD_X - 18, 0, 18, Consts.GAME_H), Consts.SIDEWALK)
	draw_rect(Rect2(Consts.ROAD_RIGHT, 0, 18, Consts.GAME_H), Consts.SIDEWALK)
	# scrolling sidewalk seams
	var speriod := 80.0
	var soff := fmod(scroll, speriod)
	var sy := -speriod + soff
	while sy < Consts.GAME_H:
		draw_rect(Rect2(Consts.ROAD_X - 18, sy, 18, 4), Consts.SIDEWALK_LINE)
		draw_rect(Rect2(Consts.ROAD_RIGHT, sy, 18, 4), Consts.SIDEWALK_LINE)
		sy += speriod

	# road surface + bright edge lines
	draw_rect(Rect2(Consts.ROAD_X, 0, Consts.ROAD_W, Consts.GAME_H), Consts.ROAD)
	draw_rect(Rect2(Consts.ROAD_X, 0, 6, Consts.GAME_H), Consts.EDGE)
	draw_rect(Rect2(Consts.ROAD_RIGHT - 6, 0, 6, Consts.GAME_H), Consts.EDGE)

	# dashed lane dividers
	var period := 64.0
	var off := fmod(scroll, period)
	for lx in [Consts.ROAD_X + Consts.ROAD_W * 0.25,
			Consts.ROAD_X + Consts.ROAD_W * 0.5,
			Consts.ROAD_X + Consts.ROAD_W * 0.75]:
		var y := -period + off
		while y < Consts.GAME_H:
			draw_rect(Rect2(lx - 4, y, 8, 36), Consts.STRIPE)
			y += period
