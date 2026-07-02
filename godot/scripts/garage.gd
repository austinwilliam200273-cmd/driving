# Garage (landscape): browse cars on the left, details + SELECT on the right.
# Locked cars show a silhouette + drop rate so you know what to chase.
extends Node2D
class_name Garage

const CAR_X := 380.0

var index := 0
var preview: CarPreview
var _name_label: Label
var _rarity_label: Label
var _status_label: Label
var _count_label: Label
var _select_btn: Button

func _ready() -> void:
	index = max(0, CarCatalog.index_of(SaveData.get_selected()))
	SaveData.apply_mute()

	UiKit.sky_background(self)

	var grass := ColorRect.new()
	grass.color = Consts.GRASS
	grass.position = Vector2(0, 250)
	grass.size = Vector2(Consts.GAME_W, Consts.GAME_H - 250)
	grass.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(grass)

	var strip := ColorRect.new()
	strip.color = Consts.ROAD
	strip.position = Vector2(CAR_X - 130, 150)
	strip.size = Vector2(260, Consts.GAME_H - 150)
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(strip)

	UiKit.title(self, "GARAGE", Vector2(0, 22), 60, Color(0.20, 0.30, 0.45), Consts.GAME_W)
	_count_label = UiKit.label(self, "", Vector2(0, 100), 26, Color(0.26, 0.36, 0.50), Consts.GAME_W)

	preview = CarPreview.new()
	preview.position = Vector2(CAR_X, 420)
	preview.scale = Vector2(2.8, 2.8)
	add_child(preview)

	var prev := UiKit.button(self, "<", Vector2(90, 360), Vector2(100, 120), 48, false)
	prev.pressed.connect(func() -> void: _move(-1))
	var nxt := UiKit.button(self, ">", Vector2(570, 360), Vector2(100, 120), 48, false)
	nxt.pressed.connect(func() -> void: _move(1))

	# details panel on the right
	var panel := UiKit.panel(self, Vector2(730, 160), Vector2(470, 300), UiKit.PANEL_BG)
	_name_label = UiKit.label(panel, "", Vector2(0, 26), 44, UiKit.INK, 470)
	_rarity_label = UiKit.label(panel, "", Vector2(0, 96), 28, Color(0.5, 0.5, 0.5), 470)
	_status_label = UiKit.label(panel, "", Vector2(0, 150), 24, Color(0.30, 0.40, 0.52), 470)
	UiKit.label(panel, "Crash into a car on the road", Vector2(0, 212), 20, Color(0.48, 0.55, 0.64), 470)
	UiKit.label(panel, "to add it to your garage.", Vector2(0, 238), 20, Color(0.48, 0.55, 0.64), 470)

	_select_btn = UiKit.button(self, "SELECT", Vector2(780, 490), Vector2(370, 88), 38)
	_select_btn.pressed.connect(_on_select)

	var back := UiKit.button(self, "BACK", Vector2(780, 598), Vector2(370, 76), 32, false)
	back.pressed.connect(_on_back)

	UiKit.label(self, "< >  browse      ENTER  select", Vector2(0, 688), 18, Color(0.32, 0.42, 0.54), Consts.GAME_W)

	UiKit.vignette(self, 0.14)
	_refresh()

func _move(dir: int) -> void:
	var n := CarCatalog.cars().size()
	index = (index + dir + n) % n
	_refresh()

func _on_select() -> void:
	var m: Dictionary = CarCatalog.cars()[index]
	if SaveData.is_owned(m.id):
		SaveData.set_selected(m.id)
		_refresh()

func _on_back() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT, KEY_A, KEY_Q: _move(-1)
			KEY_RIGHT, KEY_D: _move(1)
			KEY_ENTER, KEY_SPACE: _on_select()
			KEY_B, KEY_BACKSPACE: _on_back()

func _refresh() -> void:
	var cars := CarCatalog.cars()
	var m: Dictionary = cars[index]
	var owned := SaveData.is_owned(m.id)
	var selected := SaveData.get_selected()

	preview.set_car(m, not owned)
	_name_label.text = m.name if owned else "???"

	if m.chance <= 0.0:
		_rarity_label.text = m.rarity
	else:
		_rarity_label.text = "%s  ·  %s" % [m.rarity, CarCatalog.chance_text(m)]
	_rarity_label.add_theme_color_override("font_color", CarCatalog.rarity_color(m.rarity))

	if not owned:
		_status_label.text = "LOCKED — crash into one to unlock it"
	elif m.id == selected:
		_status_label.text = "✓ SELECTED"
	else:
		_status_label.text = "Owned"

	_select_btn.disabled = (not owned) or (m.id == selected)
	_count_label.text = "Collected  %d / %d" % [SaveData.get_owned().size(), cars.size()]
