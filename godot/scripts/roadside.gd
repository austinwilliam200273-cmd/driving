# Roadside: decorative scenery that scrolls down the grassy verges with the road.
# Purely cosmetic — no collisions. Trees/bushes are common; houses/signs/fences/
# rocks/flowerbeds show up occasionally for variety.
extends Node2D
class_name Roadside

var kind := 0  # 0 tree, 1 bush, 2 lamp, 3 house, 4 sign, 5 fence, 6 rock, 7 flowers

func _ellipse(center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 18:
		var a := TAU * i / 18.0
		pts.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(pts, col)

func _draw() -> void:
	match kind:
		2:  # lamp post with a glowing head
			_ellipse(Vector2(4, 76), 18, 6, Consts.SHADOW)
			draw_rect(Rect2(-3, -12, 6, 90), Color(0.30, 0.30, 0.34))
			draw_rect(Rect2(-1, -12, 2, 90), Color(0.45, 0.45, 0.50))
			draw_rect(Rect2(-3, -12, 30, 6), Color(0.30, 0.30, 0.34))
			draw_circle(Vector2(24, -6), 16, Color(1, 0.9, 0.5, 0.20))
			draw_circle(Vector2(24, -6), 8, Color(1, 0.85, 0.4))
		1:  # bush with berries
			_ellipse(Vector2(2, 16), 24, 8, Consts.SHADOW)
			draw_circle(Vector2(-11, 4), 14, Color(0.16, 0.50, 0.24))
			draw_circle(Vector2(11, 4), 14, Color(0.16, 0.50, 0.24))
			draw_circle(Vector2.ZERO, 18, Color(0.22, 0.60, 0.30))
			draw_circle(Vector2(-6, -8), 9, Color(0.30, 0.68, 0.36))
			draw_circle(Vector2(6, -3), 2.4, Color(0.85, 0.25, 0.30))
			draw_circle(Vector2(-9, 3), 2.4, Color(0.85, 0.25, 0.30))
		3:  # little house
			_ellipse(Vector2(2, 44), 36, 8, Consts.SHADOW)
			draw_rect(Rect2(-26, -10, 52, 46), Color(0.88, 0.82, 0.70))
			draw_rect(Rect2(-26, 26, 52, 10), Color(0.80, 0.73, 0.60))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-32, -10), Vector2(0, -42), Vector2(32, -10)]),
				Color(0.62, 0.30, 0.22))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-32, -10), Vector2(0, -42), Vector2(0, -36), Vector2(-27, -10)]),
				Color(0.72, 0.38, 0.28))
			draw_rect(Rect2(-6, 14, 12, 22), Color(0.40, 0.26, 0.15))
			draw_circle(Vector2(3, 26), 1.6, Color(0.85, 0.75, 0.35))
			for wx in [-20.0, 8.0]:
				draw_rect(Rect2(wx, -2, 12, 12), Color(0.52, 0.42, 0.30))
				draw_rect(Rect2(wx + 1, -1, 10, 10), Color(0.62, 0.82, 0.92))
				draw_rect(Rect2(wx + 1, -1, 10, 4), Color(0.80, 0.92, 0.98))
		4:  # road sign
			_ellipse(Vector2(2, 50), 14, 5, Consts.SHADOW)
			draw_rect(Rect2(-2, -6, 4, 52), Color(0.42, 0.32, 0.22))
			draw_rect(Rect2(-19, -32, 38, 28), Color(0.13, 0.45, 0.85))
			draw_rect(Rect2(-17, -30, 34, 24), Color(0.18, 0.52, 0.92))
			draw_rect(Rect2(-13, -25, 26, 5), Color.WHITE)
			draw_rect(Rect2(-13, -16, 18, 5), Color.WHITE)
		5:  # picket fence
			draw_rect(Rect2(-32, 22, 68, 5), Consts.SHADOW)
			for i in range(-30, 31, 12):
				draw_rect(Rect2(i, -6, 4, 28), Color(0.86, 0.86, 0.88))
				draw_colored_polygon(PackedVector2Array([
					Vector2(i, -6), Vector2(i + 2, -11), Vector2(i + 4, -6)]),
					Color(0.86, 0.86, 0.88))
			draw_rect(Rect2(-32, 2, 68, 4), Color(0.78, 0.78, 0.82))
		6:  # mossy rock
			_ellipse(Vector2(2, 12), 22, 7, Consts.SHADOW)
			draw_colored_polygon(PackedVector2Array([
				Vector2(-20, 10), Vector2(-14, -8), Vector2(-2, -14),
				Vector2(12, -9), Vector2(19, 4), Vector2(12, 11)]),
				Color(0.58, 0.58, 0.62))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-14, -8), Vector2(-2, -14), Vector2(4, -6), Vector2(-8, -1)]),
				Color(0.70, 0.70, 0.74))
			draw_circle(Vector2(8, 6), 5, Color(0.30, 0.55, 0.29))
		7:  # flowerbed
			_ellipse(Vector2(0, 4), 26, 12, Color(0.24, 0.48, 0.24))
			for i in 5:
				var a := TAU * i / 5.0
				var p := Vector2(cos(a) * 15, sin(a) * 7)
				var col: Color = [Color(0.95, 0.55, 0.20), Color(0.92, 0.30, 0.45),
					Color(0.95, 0.85, 0.25)][i % 3]
				draw_circle(p, 4.5, col)
				draw_circle(p, 1.8, Color(0.98, 0.95, 0.75))
		_:  # leafy tree
			_ellipse(Vector2(3, 30), 30, 10, Consts.SHADOW)
			draw_rect(Rect2(-5, 8, 10, 28), Color(0.42, 0.28, 0.14))
			draw_rect(Rect2(-5, 8, 4, 28), Color(0.52, 0.36, 0.20))
			draw_circle(Vector2.ZERO, 28, Color(0.14, 0.46, 0.22))
			draw_circle(Vector2(-16, 8), 18, Color(0.12, 0.42, 0.20))
			draw_circle(Vector2(16, 8), 18, Color(0.20, 0.58, 0.30))
			draw_circle(Vector2(0, -14), 16, Color(0.22, 0.60, 0.32))
			draw_circle(Vector2(-8, -12), 8, Color(0.30, 0.68, 0.38))
			draw_circle(Vector2(10, -4), 6, Color(0.30, 0.68, 0.38))

func _ready() -> void:
	queue_redraw()
