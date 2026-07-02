# Menu: the main landing screen (landscape). Selected car on a road strip at
# the left, actions on the right: PLAY, GARAGE, sound / touch-arrow toggles.
extends Node2D
class_name Menu

const CAR_X := 400.0

var preview: CarPreview
var _sound_btn: Button
var _arrows_btn: Button

func _ready() -> void:
	SaveData.apply_mute()
	CrazySDK.loading_stop()

	UiKit.sky_background(self)

	# grass field with a vertical road strip the car sits on
	var grass := ColorRect.new()
	grass.color = Consts.GRASS
	grass.position = Vector2(0, 330)
	grass.size = Vector2(Consts.GAME_W, Consts.GAME_H - 330)
	grass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grass)

	_road_strip(CAR_X - 110, 190, 220)

	# decorative scenery on the grass
	for cfg in [[0, 130, 470, 1.5], [1, 250, 620, 1.2], [7, 175, 660, 1.3],
			[0, 1180, 500, 1.4], [1, 1090, 660, 1.2], [6, 1210, 665, 1.1]]:
		var r := Roadside.new()
		r.kind = cfg[0]
		r.position = Vector2(cfg[1], cfg[2])
		r.scale = Vector2.ONE * cfg[3]
		add_child(r)

	UiKit.title(self, "POTHOLE PATROL", Vector2(0, 26), 76, Color(0.76, 0.25, 0.05), Consts.GAME_W)
	UiKit.label(self, "Patch potholes  •  Dodge traffic  •  Collect all %d cars" % CarCatalog.cars().size(),
		Vector2(0, 118), 24, Color(0.24, 0.34, 0.48), Consts.GAME_W)

	# selected car on show (animated if it's an animated model)
	preview = CarPreview.new()
	preview.position = Vector2(CAR_X, 430)
	preview.scale = Vector2(2.6, 2.6)
	add_child(preview)
	var sel := CarCatalog.get_by_id(SaveData.get_selected())
	if sel.is_empty():
		sel = CarCatalog.get_by_id("repair_truck")
	preview.set_car(sel, false)
	var name_l := UiKit.label(self, sel.name, Vector2(CAR_X - 220, 600), 32, Color.WHITE, 440)
	name_l.add_theme_color_override("font_outline_color", Color(0.06, 0.09, 0.16, 0.7))
	name_l.add_theme_constant_override("outline_size", 5)

	# right column: best score + actions
	var bs := UiKit.panel(self, Vector2(740, 168), Vector2(430, 66), UiKit.PANEL_BG)
	UiKit.label(bs, "BEST SCORE   %d" % SaveData.get_high(), Vector2(0, 14), 30, UiKit.INK, 430)

	var play := UiKit.button(self, "PLAY", Vector2(740, 262), Vector2(430, 112), 52)
	play.pressed.connect(_on_play)

	var change := UiKit.button(self, "GARAGE", Vector2(740, 398), Vector2(430, 88), 38, false)
	change.pressed.connect(_on_change)

	_sound_btn = UiKit.button(self, "", Vector2(740, 512), Vector2(205, 64), 22, false)
	_sound_btn.pressed.connect(_toggle_sound)
	_refresh_sound()

	# toggle the on-screen steer arrows
	_arrows_btn = UiKit.button(self, "", Vector2(965, 512), Vector2(205, 64), 22, false)
	_arrows_btn.pressed.connect(_toggle_arrows)
	_refresh_arrows()

	UiKit.label(self, "ENTER = play      C = garage", Vector2(740, 600), 20, Color(0.30, 0.40, 0.52), 430)

	UiKit.vignette(self, 0.14)

func _road_strip(x: float, y: float, w: float) -> void:
	var strip := ColorRect.new()
	strip.color = Consts.ROAD
	strip.position = Vector2(x, y)
	strip.size = Vector2(w, Consts.GAME_H - y)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(strip)
	for ex in [x + 4.0, x + w - 10.0]:
		var e := ColorRect.new()
		e.color = Consts.EDGE
		e.position = Vector2(ex, y)
		e.size = Vector2(6, Consts.GAME_H - y)
		e.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(e)
	var dy := y + 20.0
	while dy < Consts.GAME_H:
		var d := ColorRect.new()
		d.color = Consts.STRIPE
		d.position = Vector2(x + w / 2 - 4, dy)
		d.size = Vector2(8, 38)
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(d)
		dy += 72.0

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
	_sound_btn.text = "SOUND: OFF" if SaveData.get_muted() else "SOUND: ON"

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			_on_play()
		elif event.keycode == KEY_C:
			_on_change()
