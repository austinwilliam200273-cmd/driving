# GameOverScreen: final score, persistent high score, run stats, any car you
# unlocked this run, and buttons to replay or return to the menu.
extends CanvasLayer
class_name GameOverScreen

func _ready() -> void:
	layer = 10  # above HUD

func setup(data: Dictionary) -> void:
	# dim background
	var dim := ColorRect.new()
	dim.color = Color(0.06, 0.09, 0.16, 0.78)
	dim.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	add_child(dim)

	# high score
	var high := SaveData.get_high()
	var new_best: bool = data.score > high
	if new_best:
		high = data.score
		SaveData.set_high(high)

	# centered card
	var pw := 680.0
	var px := (Consts.GAME_W - pw) / 2.0
	var card := UiKit.panel(self, Vector2(px, 46), Vector2(pw, 560), Color(0.10, 0.14, 0.21, 0.94), 26.0)

	_centered(card, "GAME OVER", 24, 56, Color(0.98, 0.45, 0.09), pw)
	_centered(card, "SCORE", 100, 24, Color(0.80, 0.84, 0.90), pw)
	_centered(card, str(data.score), 128, 72, Color.WHITE, pw)
	_centered(card, ("NEW BEST!  " if new_best else "HIGH SCORE  ") + str(high), 216, 26,
		Consts.TEXT_GOLD if new_best else Color(0.58, 0.64, 0.72), pw)

	# car unlocked / collected this run
	var y := 262.0
	var cid: String = data.get("crashed_id", "")
	if cid != "":
		var m := CarCatalog.get_by_id(cid)
		if not m.is_empty():
			var header := "★ NEW CAR UNLOCKED ★" if data.get("crashed_new", false) else "Crashed into"
			_centered(card, header, y, 26, Consts.TEXT_GOLD if data.crashed_new else Color(0.7, 0.74, 0.8), pw)
			_centered(card, "%s  —  %s · %s" % [m.name, m.rarity, CarCatalog.chance_text(m)], y + 34, 26,
				CarCatalog.rarity_color(m.rarity), pw)
			y += 78.0

	# run stats
	var stats := "%d m   •   %d potholes patched   •   %d near misses" % [
		data.distance, data.get("patches", 0), data.get("near_miss", 0)]
	_centered(card, stats, y, 24, Color(0.89, 0.91, 0.94), pw)
	var extra := ""
	if int(data.get("best_combo", 0)) >= 2:
		extra = "Best combo  x%d" % mini(int(data.best_combo), Consts.PATCH_COMBO_CAP)
	if data.get("mission_done", false):
		extra += ("      " if extra != "" else "") + "Mission complete  +%d" % Consts.MISSION_PTS
	if extra != "":
		_centered(card, extra, y + 34, 22, Color(0.55, 0.85, 0.60), pw)

	# buttons side by side
	var again := UiKit.button(card, "RETRY", Vector2(pw / 2 - 300, 428), Vector2(290, 92), 40)
	again.pressed.connect(_play_again)
	var menu := UiKit.button(card, "MENU", Vector2(pw / 2 + 10, 428), Vector2(290, 92), 40, false)
	menu.pressed.connect(_menu)

	_centered(card, "SPACE / ENTER = retry", 528, 20, Color(0.58, 0.64, 0.72), pw)

func _centered(parent: Node, text: String, y: float, fsize: int, color: Color, w: float) -> Label:
	var l := Label.new()
	l.text = text
	l.position = Vector2(0, y)
	l.size = Vector2(w, fsize + 8)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", fsize)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_play_again()

func _play_again() -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _menu() -> void:
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
