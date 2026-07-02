# GameOverScreen: final score, persistent high score, run stats, any car you
# unlocked this run, and buttons to replay or return to the menu.
# Monetisation hooks: an opt-in rewarded ad doubles the run score, and leaving
# the screen (RETRY / MENU) may show a midgame break ad (cooldown-limited).
extends CanvasLayer
class_name GameOverScreen

const CARD_W := 680.0

var _cur_score := 0
var _score_big: Label
var _best_line: Label
var _double_btn: Button
var _busy := false  # an ad is playing — ignore clicks until it resolves

func _ready() -> void:
	layer = 10  # above HUD

func setup(data: Dictionary) -> void:
	_cur_score = data.score

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
	var pw := CARD_W
	var px := (Consts.GAME_W - pw) / 2.0
	var card := UiKit.panel(self, Vector2(px, 30), Vector2(pw, 636), Color(0.10, 0.14, 0.21, 0.94), 26.0)

	_centered(card, "GAME OVER", 22, 54, Color(0.98, 0.45, 0.09), pw)
	_centered(card, "SCORE", 94, 24, Color(0.80, 0.84, 0.90), pw)
	_score_big = _centered(card, str(data.score), 122, 72, Color.WHITE, pw)
	_best_line = _centered(card, ("NEW BEST!  " if new_best else "HIGH SCORE  ") + str(high), 210, 26,
		Consts.TEXT_GOLD if new_best else Color(0.58, 0.64, 0.72), pw)

	# car unlocked / collected this run
	var y := 254.0
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

	# rewarded ad: double this run's score (web only — hidden on desktop)
	if CrazySDK.available and data.score > 0:
		_double_btn = UiKit.button(card, "WATCH AD  —  DOUBLE SCORE", Vector2(pw / 2 - 280, 418), Vector2(560, 62), 26, false)
		_double_btn.pressed.connect(_on_double)

	# buttons side by side
	var again := UiKit.button(card, "RETRY", Vector2(pw / 2 - 300, 500), Vector2(290, 90), 40)
	again.pressed.connect(_play_again)
	var menu := UiKit.button(card, "MENU", Vector2(pw / 2 + 10, 500), Vector2(290, 90), 40, false)
	menu.pressed.connect(_menu)

	_centered(card, "SPACE / ENTER = retry", 600, 20, Color(0.58, 0.64, 0.72), pw)

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

# ---- rewarded ad: double score ----
func _on_double() -> void:
	if _busy:
		return
	_busy = true
	_double_btn.disabled = true
	CrazySDK.rewarded(_after_rewarded)

func _after_rewarded(ok: bool) -> void:
	_busy = false
	if not ok:
		_double_btn.text = "AD NOT AVAILABLE"
		return
	_cur_score *= 2
	_score_big.text = str(_cur_score)
	_double_btn.queue_free()
	_double_btn = null
	if _cur_score > SaveData.get_high():
		SaveData.set_high(_cur_score)
		_best_line.text = "NEW BEST!  %d" % _cur_score
		_best_line.add_theme_color_override("font_color", Consts.TEXT_GOLD)

# ---- leave the screen (with an occasional midgame break ad) ----
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_play_again()

func _play_again() -> void:
	if _busy:
		return
	_busy = true
	CrazySDK.maybe_midgame(func(_shown: bool) -> void:
		get_tree().change_scene_to_file("res://scenes/Game.tscn"))

func _menu() -> void:
	if _busy:
		return
	_busy = true
	CrazySDK.maybe_midgame(func(_shown: bool) -> void:
		get_tree().change_scene_to_file("res://scenes/Menu.tscn"))
