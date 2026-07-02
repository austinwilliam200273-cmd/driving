# Player repair truck: lateral steering + squash/stretch animations.
# `speed_mod` is multiplied into the world scroll speed by the Game script
# (penalties slow the road, the boost pickup speeds it up).
extends Node2D
class_name PlayerTruck

const W := 64.0
const H := 104.0

var half := Vector2(W / 2.0, H / 2.0)
var lateral_speed := 620.0
var speed_mod := 1.0
var _mod_timer := 0.0
var model: Dictionary = {}  # which car the player drives
var anim := false           # animated paint (color cycle / moving decals)
var t := 0.0

func set_model(m: Dictionary) -> void:
	model = m
	anim = CarCatalog.is_animated(m.get("special", ""))
	queue_redraw()

func _draw() -> void:
	# Render whichever car model is selected (forward = up).
	var m := model if not model.is_empty() else CarCatalog.get_by_id("repair_truck")
	CarCatalog.draw_car(self, m, W, H, true, t)

# dir: -1 left, +1 right, 0 none. Clamped to road edges.
func steer(dir: int, dt: float) -> void:
	if dir == 0:
		return
	position.x = clamp(position.x + dir * lateral_speed * dt,
		Consts.ROAD_X + half.x, Consts.ROAD_RIGHT - half.x)
	rotation = lerp_angle(rotation, deg_to_rad(dir * 8), 0.2)

func bounce() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(0.7, 1.3), 0.11)
	t.tween_property(self, "scale", Vector2(1, 1), 0.11)

func small_bounce() -> void:
	var t := create_tween()
	t.tween_property(self, "scale", Vector2(1.2, 0.85), 0.09)
	t.tween_property(self, "scale", Vector2(1, 1), 0.09)

# Temporary speed change (penalty < 1, boost > 1).
func apply_speed_mod(factor: float, duration: float) -> void:
	speed_mod = factor
	_mod_timer = duration

func update(dt: float) -> void:
	rotation = lerp_angle(rotation, 0.0, 0.15)
	if _mod_timer > 0.0:
		_mod_timer -= dt
		if _mod_timer <= 0.0:
			speed_mod = 1.0
	if anim:
		t += dt
		queue_redraw()
