# TrafficCar: a slow neutral obstacle. Spawns above the view and drifts down.
# Both the player and the rival must steer around it.
extends Node2D
class_name TrafficCar

const W := 60.0
const H := 100.0
const FORWARD_FACTOR := 0.45  # other cars move forward, so drift down slower

var half := Vector2(W / 2.0, H / 2.0)
var lane := 0           # which lane this car occupies (for collision)
var model: Dictionary = {}  # which car model this is (drives rarity + look)
var show_star := false  # true if the player hasn't collected this model yet
var anim := false       # animated paint
var t := 0.0
var collided := false   # hit the player
var counted := false    # near-miss accounted for

func _ready() -> void:
	if model.is_empty():
		model = CarCatalog.weighted_random()
	show_star = not SaveData.is_owned(model.id)
	anim = CarCatalog.is_animated(model.get("special", ""))
	queue_redraw()

func _draw() -> void:
	CarCatalog.draw_car(self, model, W, H, false, t)
	# little star above cars you haven't collected yet
	if show_star:
		var c := Vector2(0, -H / 2.0 - 17)
		CarCatalog.draw_star(self, c + Vector2(1, 2), 12, Color(0, 0, 0, 0.35))
		CarCatalog.draw_star(self, c, 12, Color(1, 0.84, 0.12))
		CarCatalog.draw_star(self, c, 6, Color(1, 1, 0.78))

func update(dt: float, scroll: float) -> void:
	position.y += scroll * (1.0 - FORWARD_FACTOR) * dt
	if anim:
		t += dt
		queue_redraw()

func dead() -> bool:
	return position.y > Consts.GAME_H + 140.0
