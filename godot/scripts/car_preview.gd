# CarPreview: draws a single car for the garage. Locked cars show as a dark
# silhouette with a "?". Animated cars (color cycling / moving decals) play live.
extends Node2D
class_name CarPreview

var model: Dictionary = {}
var locked := false
var _anim := false
var t := 0.0

func set_car(m: Dictionary, lk: bool) -> void:
	model = m
	locked = lk
	_anim = (not lk) and CarCatalog.is_animated(m.get("special", ""))
	queue_redraw()

func _process(delta: float) -> void:
	if _anim:
		t += delta
		queue_redraw()

func _draw() -> void:
	if model.is_empty():
		return
	if locked:
		var sil := model.duplicate()
		sil.color = Color(0.22, 0.24, 0.28)
		sil["accent"] = Color(0.16, 0.18, 0.21)
		sil["special"] = ""  # hide identifying flair
		CarCatalog.draw_car(self, sil, 64, 104, false)
		var f := ThemeDB.fallback_font
		draw_string(f, Vector2(-16, 18), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 56,
			Color(0.78, 0.80, 0.85))
	else:
		CarCatalog.draw_car(self, model, 64, 104, model.get("special", "") == "truck", t)
