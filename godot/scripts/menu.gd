# Menu: the main landing screen. Shows the currently selected car and offers
# PLAY (start a run) or CHANGE CAR (open the Garage).
extends Node2D
class_name Menu

var preview: CarPreview
var _sound_btn: Button
var _arrows_btn: Button

func _ready() -> void:
	SaveData.apply_mute()
	CrazySDK.loading_stop()

	var bg := ColorRect.new()
	bg.color = Consts.SKY
	bg.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	add_child(bg)

	# road strip behind the car
	var strip := ColorRect.new()
	strip.color = Consts.ROAD
	strip.position = Vector2(Consts.GAME_W / 2 - 150, 360)
	strip.size = Vector2(300, 380)
	add_child(strip)

	_title("POTHOLE", 120, 84, Color(0.76, 0.25, 0.05))
	_title("PATROL", 208, 84, Color(0.76, 0.25, 0.05))

	_label("Best Score: %d" % SaveData.get_high(), Vector2(0, 315), 28, Color(0.20, 0.30, 0.45))

	# selected car on show (animated if it's an animated model)
	preview = CarPreview.new()
	preview.position = Vector2(Consts.GAME_W / 2, 560)
	preview.scale = Vector2(2.6, 2.6)
	add_child(preview)
	var sel := CarCatalog.get_by_id(SaveData.get_selected())
	if sel.is_empty():
		sel = CarCatalog.get_by_id("repair_truck")
	preview.set_car(sel, false)
	_label(sel.name, Vector2(0, 740), 34, Color(0.10, 0.13, 0.18))

	var play := _button("PLAY", Vector2(Consts.GAME_W / 2 - 200, 840), Vector2(400, 130), 56)
	play.pressed.connect(_on_play)

	var change := _button("CHANGE CAR", Vector2(Consts.GAME_W / 2 - 200, 1000), Vector2(400, 100), 42)
	change.pressed.connect(_on_change)

	_sound_btn = _button("", Vector2(Consts.GAME_W - 200, 28), Vector2(180, 60), 26)
	_sound_btn.pressed.connect(_toggle_sound)
	_refresh_sound()

	# toggle the on-screen steer arrows (top-left)
	_arrows_btn = _button("", Vector2(20, 28), Vector2(250, 60), 24)
	_arrows_btn.pressed.connect(_toggle_arrows)
	_refresh_arrows()

func _toggle_arrows() -> void:
	SaveData.set_arrows(not SaveData.get_arrows())
	_refresh_arrows()

func _refresh_arrows() -> void:
	_arrows_btn.text = "ARROWS: ON" if SaveData.get_arrows() else "ARROWS: OFF"

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_change() -> void:
	get_tree().change_scene_to_file("res://scenes/Garage.tscn")

func _toggle_sound() -> void:
	SaveData.set_muted(not SaveData.get_muted())
	_refresh_sound()

func _refresh_sound() -> void:
	_sound_btn.text = "SOUND OFF" if SaveData.get_muted() else "SOUND ON"

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_on_play()
		elif event.keycode == KEY_C:
			_on_change()

func _title(text: String, y: float, fsize: int, color: Color) -> void:
	var l := _label(text, Vector2(0, y), fsize, color)
	l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.6))
	l.add_theme_constant_override("outline_size", 5)

func _label(text: String, pos: Vector2, fsize: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = Vector2(Consts.GAME_W, fsize + 12)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", color)
	add_child(l)
	return l

func _button(text: String, pos: Vector2, size: Vector2, fsize: int) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.custom_minimum_size = size
	b.add_theme_font_size_override("font_size", fsize)
	add_child(b)
	return b
