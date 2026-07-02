# HUD: on-screen UI on a CanvasLayer (screen-space).
#   top-left  : score / distance / patched panel
#   top-right : current mission panel + sound toggle
#   bottom corners : left/right steer buttons (touch + mouse, optional)
# Also owns the first-runs onboarding overlay (keycaps + goal hints).
extends CanvasLayer
class_name Hud

var btn_left := false
var btn_right := false

var _score_label: Label
var _info_label: Label
var _mission_label: Label
var _mission_panel: Panel
var _sound_btn: Button
var _onboarding: Control
var _mission_done := false

func _ready() -> void:
	layer = 2

	# score panel (top-left)
	var sp := UiKit.panel(self, Vector2(16, 14), Vector2(300, 96), UiKit.PANEL_BG)
	_score_label = UiKit.label(sp, "SCORE 0", Vector2(18, 8), 38, UiKit.INK)
	_info_label = UiKit.label(sp, "0 m", Vector2(18, 58), 22, UiKit.INK_SOFT)

	# mission panel (top-right, left of the sound button)
	_mission_panel = UiKit.panel(self, Vector2(Consts.GAME_W - 486, 14), Vector2(390, 66), UiKit.PANEL_BG)
	UiKit.label(_mission_panel, "MISSION", Vector2(16, 6), 16, Color(0.93, 0.42, 0.10))
	_mission_label = UiKit.label(_mission_panel, "", Vector2(16, 26), 24, UiKit.INK)

	_sound_btn = UiKit.button(self, "", Vector2(Consts.GAME_W - 84, 14), Vector2(68, 66), 20, false)
	_sound_btn.pressed.connect(_toggle_sound)
	_refresh_sound()

	_build_steer_buttons()

func _build_steer_buttons() -> void:
	# On-screen steer arrows — only if enabled in the menu (keyboard always works).
	if not SaveData.get_arrows():
		return
	var left := UiKit.button(self, "<", Vector2(28, Consts.GAME_H - 168), Vector2(140, 140), 56, false)
	left.modulate.a = 0.75
	left.button_down.connect(func() -> void: btn_left = true)
	left.button_up.connect(func() -> void: btn_left = false)
	left.mouse_exited.connect(func() -> void: btn_left = false)

	var right := UiKit.button(self, ">", Vector2(Consts.GAME_W - 168, Consts.GAME_H - 168), Vector2(140, 140), 56, false)
	right.modulate.a = 0.75
	right.button_down.connect(func() -> void: btn_right = true)
	right.button_up.connect(func() -> void: btn_right = false)
	right.mouse_exited.connect(func() -> void: btn_right = false)

func _toggle_sound() -> void:
	SaveData.set_muted(not SaveData.get_muted())
	_refresh_sound()

func _refresh_sound() -> void:
	_sound_btn.text = "OFF" if SaveData.get_muted() else "ON"

func update_hud(score_total: int, dist: float, patches: int, combo: int) -> void:
	_score_label.text = "SCORE %d" % score_total
	var info := "%d m   •   %d patched" % [int(dist), patches]
	if combo >= 2:
		info += "   •   combo x%d" % mini(combo, Consts.PATCH_COMBO_CAP)
	_info_label.text = info

func update_mission(text: String, value: int, goal: int) -> void:
	if _mission_done:
		return
	_mission_label.text = "%s  —  %d/%d" % [text, mini(value, goal), goal]

func mission_complete(text: String) -> void:
	_mission_done = true
	_mission_label.text = "%s  —  DONE!" % text
	_mission_label.add_theme_color_override("font_color", Color(0.10, 0.62, 0.25))
	# celebratory banner in the middle of the screen
	var banner := UiKit.label(self, "MISSION COMPLETE  +%d" % Consts.MISSION_PTS,
		Vector2(0, 190), 52, Consts.TEXT_GOLD, Consts.GAME_W)
	banner.add_theme_color_override("font_outline_color", Color(0.06, 0.09, 0.16))
	banner.add_theme_constant_override("outline_size", 8)
	var t := create_tween()
	t.tween_interval(1.6)
	t.tween_property(banner, "modulate:a", 0.0, 0.6)
	t.finished.connect(banner.queue_free)

# ---- onboarding overlay (first few runs) ----
func show_onboarding() -> void:
	_onboarding = Control.new()
	_onboarding.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_onboarding)

	var p := UiKit.panel(_onboarding, Vector2(Consts.GAME_W / 2 - 290, 130), Vector2(580, 230), UiKit.PANEL_DARK, 22.0)
	UiKit.label(p, "STEER", Vector2(0, 22), 26, Color(0.85, 0.89, 0.95), 290)
	UiKit.keycap(p, "<", Vector2(62, 62))
	UiKit.keycap(p, ">", Vector2(128, 62))
	UiKit.label(p, "or", Vector2(0, 138), 20, Color(0.65, 0.70, 0.78), 290)
	UiKit.keycap(p, "A", Vector2(62, 162), 48)
	UiKit.keycap(p, "D", Vector2(118, 162), 48)

	UiKit.label(p, "PATCH the potholes!", Vector2(300, 40), 28, Color(1.0, 0.84, 0.30))
	UiKit.label(p, "Drive over them for points.", Vector2(300, 76), 20, Color(0.85, 0.89, 0.95))
	UiKit.label(p, "AVOID the traffic!", Vector2(300, 128), 28, Color(0.98, 0.55, 0.45))
	UiKit.label(p, "Crashing ends the run — but", Vector2(300, 164), 20, Color(0.85, 0.89, 0.95))
	UiKit.label(p, "collects that car for your garage.", Vector2(300, 188), 20, Color(0.85, 0.89, 0.95))

func dismiss_onboarding() -> void:
	if not _onboarding or not is_instance_valid(_onboarding):
		return
	var ob := _onboarding
	_onboarding = null
	var t := create_tween()
	t.tween_property(ob, "modulate:a", 0.0, 0.5)
	t.finished.connect(ob.queue_free)
