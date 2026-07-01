# GameOverScreen: final score, persistent high score, run stats, any car you
# unlocked this run, and buttons to replay or return to the garage.
extends CanvasLayer
class_name GameOverScreen

func _ready() -> void:
	layer = 10  # above HUD

func setup(data: Dictionary) -> void:
	var cx := Consts.GAME_W / 2.0

	# dim background
	var dim := ColorRect.new()
	dim.color = Color(0.06, 0.09, 0.16, 0.80)
	dim.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	add_child(dim)

	# high score
	var high := SaveData.get_high()
	var new_best: bool = data.score > high
	if new_best:
		high = data.score
		SaveData.set_high(high)

	_centered("GAME OVER", 150, 78, Color(0.98, 0.45, 0.09))
	_centered("SCORE", 270, 30, Color(0.80, 0.84, 0.90))
	_centered(str(data.score), 314, 84, Color(1, 1, 1))
	_centered(("NEW BEST  " if new_best else "HIGH SCORE  ") + str(high), 430, 30,
		Color(0.98, 0.80, 0.08) if new_best else Color(0.58, 0.64, 0.72))

	# car unlocked / collected this run
	var cid: String = data.get("crashed_id", "")
	if cid != "":
		var m := CarCatalog.get_by_id(cid)
		if not m.is_empty():
			var header := "★ NEW CAR UNLOCKED ★" if data.get("crashed_new", false) else "Crashed into"
			_centered(header, 500, 30, Color(0.98, 0.80, 0.08) if data.crashed_new else Color(0.7, 0.74, 0.8))
			_centered("%s  —  %s · %s" % [m.name, m.rarity, CarCatalog.chance_text(m)], 540, 30,
				CarCatalog.rarity_color(m.rarity))

	# run stats
	var stats := "Distance: %d m\nNear misses: %d" % [data.distance, data.near_miss]
	var sl := _centered(stats, 630, 30, Color(0.89, 0.91, 0.94))
	sl.size.y = 120

	# buttons
	var again := _button("RETRY", Vector2(cx - 180, 880), Vector2(360, 104), 42)
	again.pressed.connect(_play_again)
	var menu := _button("MENU", Vector2(cx - 180, 1004), Vector2(360, 92), 38)
	menu.pressed.connect(_menu)

	_centered("SPACE / ENTER = retry", 1130, 24, Color(0.58, 0.64, 0.72))

func _centered(text: String, y: float, fsize: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.position = Vector2(0, y)
	l.size = Vector2(Consts.GAME_W, fsize + 8)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
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

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_play_again()

func _play_again() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _menu() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
