# Pothole: the job! Potholes scroll down the road in lanes; driving the repair
# truck over one patches it (points + combo). Letting one slip past unpatched
# breaks the combo. Patched holes stay behind as fresh asphalt squares.
extends Node2D
class_name Pothole

var lane := 0
var patched := false
var missed := false   # scrolled past the player unpatched (combo already reset)
var _seed := 0

func _ready() -> void:
	_seed = randi() % 997
	queue_redraw()

func _h(k: int) -> float:
	return fposmod(sin(float(_seed + k) * 91.7 + 13.3) * 4375.85, 1.0)

func patch() -> void:
	patched = true
	queue_redraw()

func _draw() -> void:
	if patched:
		# fresh square of tamped asphalt with a lighter tar edge
		var s := 62.0
		draw_rect(Rect2(-s / 2 - 3, -s / 2 - 3, s + 6, s + 6), Consts.PATCH_EDGE)
		draw_rect(Rect2(-s / 2, -s / 2, s, s), Consts.PATCH)
		# tamper lines
		for i in 3:
			draw_rect(Rect2(-s / 2 + 8, -s / 2 + 12 + i * 16, s - 16, 3), Color(1, 1, 1, 0.08))
		return

	# broken rim (light) around an irregular dark crater
	var pts := PackedVector2Array()
	var n := 10
	for i in n:
		var a := TAU * i / n
		var r := 30.0 + _h(i) * 10.0
		pts.append(Vector2(cos(a), sin(a) * 0.86) * r)
	# rim highlight (offset up-left so it reads as depth)
	var rim := PackedVector2Array()
	for p in pts:
		rim.append(p * 1.16 + Vector2(0, -2))
	draw_colored_polygon(rim, Consts.CRATER_LIGHT)
	draw_colored_polygon(pts, Consts.CRATER_DARK)
	# inner shadow blob
	var inner := PackedVector2Array()
	for p in pts:
		inner.append(p * 0.55 + Vector2(2, 3))
	draw_colored_polygon(inner, Color(0.03, 0.05, 0.09))
	# cracks radiating out
	for i in 3:
		var a := TAU * (_h(20 + i) + i / 3.0)
		var from := Vector2(cos(a), sin(a) * 0.86) * 30.0
		var to := from * (1.45 + _h(30 + i) * 0.4)
		draw_line(from, to, Consts.CRATER_DARK, 3.0)
		draw_line(to, to + Vector2(cos(a + 0.7), sin(a + 0.7)) * 9.0, Consts.CRATER_DARK, 2.0)
	# small loose chunks
	for i in 4:
		var a := TAU * _h(40 + i)
		var d := 38.0 + _h(50 + i) * 14.0
		draw_circle(Vector2(cos(a), sin(a) * 0.86) * d, 2.5 + _h(60 + i) * 2.0, Consts.CRATER_LIGHT)
