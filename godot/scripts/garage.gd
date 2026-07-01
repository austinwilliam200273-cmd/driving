# Garage: browse cars, see how rare each one is, and select an owned car.
# Locked cars show a silhouette + drop rate so you know what to chase.
# Reached from the main menu's CHANGE CAR button; BACK returns to the menu.
extends Node2D
class_name Garage

var index := 0
var preview: CarPreview
var _name_label: Label
var _rarity_label: Label
var _status_label: Label
var _count_label: Label

func _ready() -> void:
	index = max(0, CarCatalog.index_of(SaveData.get_selected()))
	SaveData.apply_mute()

	var bg := ColorRect.new()
	bg.color = Consts.SKY
	bg.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	add_child(bg)

	var strip := ColorRect.new()
	strip.color = Consts.ROAD
	strip.position = Vector2(Consts.GAME_W / 2 - 150, 340)
	strip.size = Vector2(300, 360)
	add_child(strip)

	_title("GARAGE", 120, 60, Color(0.20, 0.30, 0.45))
	_count_label = _label("", Vector2(0, 210), 28, Color(0.30, 0.40, 0.52), true)

	preview = CarPreview.new()
	preview.position = Vector2(Consts.GAME_W / 2, 520)
	preview.scale = Vector2(2.4, 2.4)
	add_child(preview)

	var prev := _button("<", Vector2(40, 460), Vector2(110, 120), 50)
	prev.pressed.connect(func() -> void: _move(-1))
	var nxt := _button(">", Vector2(Consts.GAME_W - 150, 460), Vector2(110, 120), 50)
	nxt.pressed.connect(func() -> void: _move(1))

	_name_label = _label("", Vector2(0, 730), 44, Color(0.10, 0.13, 0.18), true)
	_rarity_label = _label("", Vector2(0, 786), 30, Color(0.5, 0.5, 0.5), true)
	_status_label = _label("", Vector2(0, 828), 26, Color(0.30, 0.40, 0.52), true)

	var select_hint := _button("SELECT", Vector2(Consts.GAME_W / 2 - 180, 900), Vector2(360, 96), 38)
	select_hint.pressed.connect(_on_select)
	_select_btn = select_hint

	var back := _button("BACK", Vector2(Consts.GAME_W / 2 - 180, 1020), Vector2(360, 100), 44)
	back.pressed.connect(_on_back)

	_refresh()

var _select_btn: Button

func _title(text: String, y: float, fsize: int, color: Color) -> void:
	var l := _label(text, Vector2(0, y), fsize, color, true)
	l.add_theme_color_override("font_outline_color", Color(1, 1, 1, 0.6))
	l.add_theme_constant_override("outline_size", 4)

func _label(text: String, pos: Vector2, fsize: int, color: Color, centered: bool) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", color)
	if centered:
		l.size = Vector2(Consts.GAME_W, fsize + 10)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
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
			KEY_LEFT, KEY_A: _move(-1)
			KEY_RIGHT, KEY_D: _move(1)
			KEY_ENTER, KEY_SPACE: _on_select()
			KEY_ESCAPE: _on_back()

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
