# HUD: on-screen UI on a CanvasLayer (screen-space).
#   top-left  : score + distance
#   bottom-left : left/right steer buttons (touch + mouse)
#   bottom-right: sound toggle
extends CanvasLayer
class_name Hud

var btn_left := false
var btn_right := false

var _score_label: Label
var _dist_label: Label
var _sound_btn: Button

func _ready() -> void:
	_score_label = _label("SCORE 0", Vector2(24, 18), 40, Color(0.06, 0.09, 0.16))
	_dist_label = _label("0 m", Vector2(24, 70), 26, Color(0.12, 0.23, 0.54))
	_build_buttons()

func _label(text: String, pos: Vector2, fsize: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	return l

func _build_buttons() -> void:
	# On-screen steer arrows — only shown if enabled in the menu (keyboard always works).
	if SaveData.get_arrows():
		var left := _make_button("<", Vector2(40, 1080), Vector2(150, 150), 56)
		left.button_down.connect(func() -> void: btn_left = true)
		left.button_up.connect(func() -> void: btn_left = false)
		left.mouse_exited.connect(func() -> void: btn_left = false)

		var right := _make_button(">", Vector2(210, 1080), Vector2(150, 150), 56)
		right.button_down.connect(func() -> void: btn_right = true)
		right.button_up.connect(func() -> void: btn_right = false)
		right.mouse_exited.connect(func() -> void: btn_right = false)

	_sound_btn = _make_button("", Vector2(Consts.GAME_W - 130, 1100), Vector2(110, 110), 30)
	_sound_btn.pressed.connect(_toggle_sound)
	_refresh_sound()

func _make_button(text: String, pos: Vector2, size: Vector2, fsize: int) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.custom_minimum_size = size
	b.add_theme_font_size_override("font_size", fsize)
	add_child(b)
	return b

func _toggle_sound() -> void:
	SaveData.set_muted(not SaveData.get_muted())
	_refresh_sound()

func _refresh_sound() -> void:
	_sound_btn.text = "OFF" if SaveData.get_muted() else "ON"

func update_hud(score_total: int, dist: float) -> void:
	_score_label.text = "SCORE %d" % score_total
	_dist_label.text = "%d m" % int(dist)
