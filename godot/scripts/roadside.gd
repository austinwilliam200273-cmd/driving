# Roadside: decorative scenery that scrolls down the grassy verges with the road.
# Purely cosmetic — no collisions. Trees/bushes are common; houses/signs/fences
# show up occasionally for variety.
extends Node2D
class_name Roadside

var kind := 0  # 0 tree, 1 bush, 2 lamp, 3 house, 4 sign, 5 fence

func _draw() -> void:
	match kind:
		2:  # lamp post with a glowing head
			draw_rect(Rect2(-3, -12, 6, 90), Color(0.30, 0.30, 0.34))
			draw_rect(Rect2(-3, -12, 30, 6), Color(0.30, 0.30, 0.34))
			draw_circle(Vector2(24, -6), 14, Color(1, 0.9, 0.5, 0.22))  # glow
			draw_circle(Vector2(24, -6), 8, Color(1, 0.85, 0.4))
		1:  # bush
			draw_circle(Vector2(-10, 4), 14, Consts.GRASS_DARK)
			draw_circle(Vector2(10, 4), 14, Consts.GRASS_DARK)
			draw_circle(Vector2.ZERO, 18, Color(0.20, 0.58, 0.28))
		3:  # little house
			draw_rect(Rect2(-28, 4, 56, 4), Color(0, 0, 0, 0.18))  # shadow
			draw_rect(Rect2(-26, -10, 52, 46), Color(0.88, 0.82, 0.70))
			draw_colored_polygon(PackedVector2Array([
				Vector2(-32, -10), Vector2(0, -42), Vector2(32, -10)]),
				Color(0.62, 0.30, 0.22))
			draw_rect(Rect2(-6, 14, 12, 22), Color(0.40, 0.26, 0.15))  # door
			draw_rect(Rect2(-20, -2, 12, 12), Color(0.62, 0.82, 0.92))  # windows
			draw_rect(Rect2(8, -2, 12, 12), Color(0.62, 0.82, 0.92))
		4:  # road sign
			draw_rect(Rect2(-2, -6, 4, 52), Color(0.42, 0.32, 0.22))
			draw_rect(Rect2(-19, -32, 38, 28), Color(0.13, 0.45, 0.85))
			draw_rect(Rect2(-13, -25, 26, 5), Color.WHITE)
			draw_rect(Rect2(-13, -16, 18, 5), Color.WHITE)
		5:  # picket fence
			for i in range(-30, 31, 12):
				draw_rect(Rect2(i, -6, 4, 28), Color(0.86, 0.86, 0.88))
			draw_rect(Rect2(-32, 2, 68, 4), Color(0.82, 0.82, 0.85))
		_:  # leafy tree
			draw_rect(Rect2(-5, 8, 10, 28), Color(0.42, 0.28, 0.14))  # trunk
			draw_circle(Vector2.ZERO, 28, Color(0.14, 0.46, 0.22))
			draw_circle(Vector2(-16, 8), 18, Color(0.12, 0.42, 0.20))
			draw_circle(Vector2(16, 8), 18, Color(0.20, 0.58, 0.30))
			draw_circle(Vector2(0, -14), 16, Color(0.22, 0.60, 0.32))

func _ready() -> void:
	queue_redraw()
