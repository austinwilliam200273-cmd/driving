# Game: the endless patrol run. A top-down dodge-and-patch racer — steer to
# survive rising speed, drive over potholes to patch them (combo points), weave
# past traffic for near-miss points, and crash into a car to add it to your
# garage. One simple mission per run. Built entirely in code (no asset files).
extends Node2D
class_name Game

var world: Node2D
var road: Road
var player: PlayerTruck
var hud: Hud
var sfx: Sfx
var flash_rect: ColorRect

var score: ScoreSystem
var scroll_speed := Consts.SPEED_BASE  # px/sec, climbs slowly the whole run
var distance := 0.0
var run_time := 0.0
var game_over := false
var demo := false        # attract-mode auto-drive for promo video recording (env PP_DEMO)
var crashed_id := ""     # car model crashed into (unlocks it)
var crashed_new := false # was that a brand-new unlock?

var mission: Dictionary = {}
var mission_done := false

var traffic: Array = []
var potholes: Array = []
var scenery: Array = []
var traffic_acc := 0.0
var pothole_acc := 0.0
var pothole_next := 1.2
var scenery_acc := 0.0
var exhaust_acc := 0.0
var shake_time := 0.0
var shake_strength := 0.0
var onboarding_time := 0.0
var onboarding_active := false

func _ready() -> void:
	randomize()
	SaveData.apply_mute()

	world = Node2D.new()
	add_child(world)

	var sky := ColorRect.new()
	sky.color = Consts.SKY
	sky.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	sky.z_index = -100
	sky.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(sky)

	road = Road.new()
	road.z_index = -50
	world.add_child(road)

	player = PlayerTruck.new()
	player.position = Vector2(Consts.LANE_CENTERS[1], Consts.PLAYER_Y)
	player.z_index = 20
	world.add_child(player)
	var sel := CarCatalog.get_by_id(SaveData.get_selected())
	if sel.is_empty():
		sel = CarCatalog.get_by_id("repair_truck")
	player.set_model(sel)

	score = ScoreSystem.new()
	mission = Missions.current()
	sfx = Sfx.new()
	add_child(sfx)

	# soft vignette between the world and the HUD
	var vl := CanvasLayer.new()
	vl.layer = 1
	add_child(vl)
	UiKit.vignette(vl, 0.16)

	hud = Hud.new()
	add_child(hud)

	var fl := CanvasLayer.new()
	fl.layer = 5
	add_child(fl)
	flash_rect = ColorRect.new()
	flash_rect.size = Vector2(Consts.GAME_W, Consts.GAME_H)
	flash_rect.color = Color(1, 1, 1, 0)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fl.add_child(flash_rect)

	demo = OS.has_environment("PP_DEMO")
	if not demo and SaveData.get_runs() < 3:
		hud.show_onboarding()
		onboarding_active = true
	SaveData.inc_runs()
	sfx.play_music()
	CrazySDK.gameplay_start()

func _process(delta: float) -> void:
	if game_over:
		return
	var dt: float = min(delta, 0.05)
	run_time += dt

	# slow, continuous acceleration over the whole run
	scroll_speed = min(scroll_speed + Consts.SPEED_ACCEL * dt, Consts.SPEED_MAX)
	var eff := scroll_speed * player.speed_mod
	distance += eff * dt * 0.08

	# input (keyboard + on-screen buttons), or auto-drive in demo mode
	# Q doubles as left so AZERTY (ZQSD) players are covered too.
	var steer := 0
	if demo:
		steer = _demo_steer()
	else:
		if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A) \
				or Input.is_physical_key_pressed(KEY_Q) or hud.btn_left:
			steer -= 1
		if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D) or hud.btn_right:
			steer += 1
	player.steer(steer, dt)
	player.update(dt)

	# first steering input (or 6s) dismisses the onboarding overlay
	if onboarding_active:
		onboarding_time += dt
		if steer != 0 or onboarding_time > 6.0:
			onboarding_active = false
			hud.dismiss_onboarding()

	road.scroll += eff * dt
	road.queue_redraw()

	_update_scenery(dt, eff)
	_update_exhaust(dt)
	_update_potholes(dt, eff)
	_update_traffic(dt, eff)
	_update_mission()

	if shake_time > 0.0:
		shake_time -= dt
		world.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
	else:
		world.position = Vector2.ZERO

	hud.update_hud(score.total(distance), distance, score.patches, score.combo)

# Auto-drive for the promo recording: dodge into whichever lane is clear ahead.
func _demo_steer() -> int:
	var pl_lane := clampi(int((player.position.x - Consts.ROAD_X) / Consts.LANE_W), 0, Consts.LANES - 1)
	var blocked := []
	for i in Consts.LANES:
		blocked.append(false)
	for car in traffic:
		var ahead: float = player.position.y - car.position.y  # >0 => car is ahead (above)
		if ahead > -90.0 and ahead < 540.0:
			blocked[car.lane] = true
	var target_lane := pl_lane
	if blocked[pl_lane]:
		var found := false
		for dist in [1, 2, 3]:
			for dir in [-1, 1]:
				var ln: int = pl_lane + dir * dist
				if ln >= 0 and ln < Consts.LANES and not blocked[ln] and not found:
					target_lane = ln
					found = true
	var tx: float = Consts.LANE_CENTERS[target_lane]
	if player.position.x > tx + 6.0:
		return -1
	elif player.position.x < tx - 6.0:
		return 1
	return 0

# ---- missions ----
func _update_mission() -> void:
	if mission.is_empty():
		return
	var value := Missions.progress(mission, score, distance, run_time)
	if not mission_done and value >= int(mission.goal):
		mission_done = true
		score.add_mission_bonus()
		hud.mission_complete(mission.text)
		sfx.mission()
		SaveData.advance_mission()
		CrazySDK.happytime()
	elif not mission_done:
		hud.update_mission(mission.text, value, int(mission.goal))

# ---- potholes ----
func _spawn_pothole() -> void:
	# pick a lane where the new hole won't overlap fresh traffic or another hole
	var lanes := [0, 1, 2, 3]
	lanes.shuffle()
	for lane in lanes:
		var clear := true
		for car in traffic:
			if car.lane == lane and car.position.y < 200:
				clear = false
				break
		for ph in potholes:
			if ph.lane == lane and ph.position.y < 150:
				clear = false
				break
		if clear:
			var p := Pothole.new()
			p.lane = lane
			p.position = Vector2(Consts.LANE_CENTERS[lane], -80)
			p.z_index = -20  # part of the road surface, under every car
			world.add_child(p)
			potholes.append(p)
			return

func _update_potholes(dt: float, eff: float) -> void:
	pothole_acc += dt
	if pothole_acc >= pothole_next:
		pothole_acc = 0.0
		pothole_next = randf_range(1.1, 2.0)
		_spawn_pothole()

	var pl_lane := clampi(int((player.position.x - Consts.ROAD_X) / Consts.LANE_W), 0, Consts.LANES - 1)

	for i in range(potholes.size() - 1, -1, -1):
		var ph: Pothole = potholes[i]
		ph.position.y += eff * dt  # holes are part of the road: full scroll speed

		if not ph.patched and ph.lane == pl_lane and abs(ph.position.y - Consts.PLAYER_Y) < 48.0:
			ph.patch()
			var pts := score.add_patch()
			sfx.patch()
			player.small_bounce()
			burst(ph.position, Consts.CRATER_LIGHT, 7, 10, 0.6)
			var msg := "PATCHED +%d" % pts
			if score.combo >= 2:
				msg += "  x%d" % mini(score.combo, Consts.PATCH_COMBO_CAP)
			float_text(Vector2(ph.position.x, Consts.PLAYER_Y - 90), msg, Consts.TEXT_GOOD)
		elif not ph.patched and not ph.missed and ph.position.y > Consts.PLAYER_Y + 70:
			ph.missed = true
			if score.combo >= 2:
				float_text(Vector2(ph.position.x, Consts.PLAYER_Y + 40), "COMBO LOST", Color(0.95, 0.55, 0.35))
			score.break_combo()

		if ph.position.y > Consts.GAME_H + 90:
			ph.queue_free()
			potholes.remove_at(i)

# ---- traffic ----
func spawn_traffic_in_lane(lane: int) -> void:
	var car := TrafficCar.new()
	car.lane = lane
	car.position = Vector2(Consts.LANE_CENTERS[lane], -140)
	car.z_index = 15
	world.add_child(car)
	traffic.append(car)

# Each wave fills 1-2 lanes (occasionally 3 late game) but always leaves a gap.
func _spawn_wave(diff: float) -> void:
	var count := 1
	var roll := randf()
	if roll < diff * 0.5:
		count = 2
	if roll < diff * 0.12:
		count = 3  # never 4 — a gap always remains
	var lanes := [0, 1, 2, 3]
	lanes.shuffle()
	for k in count:
		spawn_traffic_in_lane(lanes[k])

func _update_traffic(dt: float, eff: float) -> void:
	var diff: float = clamp((scroll_speed - Consts.SPEED_BASE) / (Consts.SPEED_MAX - Consts.SPEED_BASE), 0.0, 1.0)
	traffic_acc += dt
	if traffic_acc >= lerp(1.0, 0.55, diff):  # spawns get more frequent over time
		traffic_acc = 0.0
		_spawn_wave(diff)

	# The player always occupies exactly one lane (lanes tile the whole road), so
	# collision is lane-based — you can't hide in the gap between two cars.
	var pl_lane := clampi(int((player.position.x - Consts.ROAD_X) / Consts.LANE_W), 0, Consts.LANES - 1)

	for i in range(traffic.size() - 1, -1, -1):
		var car: TrafficCar = traffic[i]
		car.update(dt, eff)

		var y_hit: bool = abs(car.position.y - player.position.y) < (car.half.y + player.half.y) * 0.78
		if not demo and not car.collided and car.lane == pl_lane and y_hit:
			# Crash = collect that car + end the run.
			car.collided = true
			crashed_id = car.model.id
			crashed_new = SaveData.unlock(crashed_id)
			burst(player.position, Color(0.9, 0.3, 0.1), 12, 18, 0.9)
			_die()
			return

		if not car.counted and car.position.y > Consts.PLAYER_Y + 50:
			car.counted = true
			if abs(car.position.x - player.position.x) < 120:
				score.add_near_miss()
				sfx.near_miss()
				float_text(Vector2(player.position.x, Consts.PLAYER_Y - 90), "NEAR MISS +10", Consts.TEXT_GOLD)

		if car.dead():
			car.queue_free()
			traffic.remove_at(i)

# ---- roadside scenery ----
func spawn_scenery() -> void:
	var r := Roadside.new()
	r.kind = [0, 0, 0, 1, 1, 2, 3, 4, 5, 6, 7, 7].pick_random()
	var x: float
	if randf() < 0.5:
		x = randf_range(30, Consts.ROAD_X - 60)
	else:
		x = randf_range(Consts.ROAD_RIGHT + 60, Consts.GAME_W - 30)
	r.position = Vector2(x, -90)
	r.scale = Vector2.ONE * randf_range(0.9, 1.35)
	r.z_index = -10
	world.add_child(r)
	scenery.append(r)

func _update_scenery(dt: float, eff: float) -> void:
	scenery_acc += dt
	if scenery_acc >= 0.34:  # wide verges in landscape need denser dressing
		scenery_acc = 0.0
		spawn_scenery()
	for i in range(scenery.size() - 1, -1, -1):
		var s: Roadside = scenery[i]
		s.position.y += eff * dt
		if s.position.y > Consts.GAME_H + 100:
			s.queue_free()
			scenery.remove_at(i)

# ---- exhaust puffs ----
func _update_exhaust(dt: float) -> void:
	exhaust_acc += dt
	if exhaust_acc < 0.1:
		return
	exhaust_acc = 0.0
	var puff := ExhaustPuff.new()
	puff.radius = randf_range(6, 9)
	puff.position = player.position + Vector2(randf_range(-14, 14), player.half.y + 4)
	puff.z_index = 6
	world.add_child(puff)
	var t := create_tween().set_parallel(true)
	t.tween_property(puff, "position:y", puff.position.y + 90, 0.5)
	t.tween_property(puff, "scale", Vector2(2.0, 2.0), 0.5)
	t.tween_property(puff, "modulate:a", 0.0, 0.5)
	t.finished.connect(puff.queue_free)

# ---- helpers ----
func shake(duration: float, strength: float) -> void:
	shake_time = max(shake_time, duration)
	shake_strength = strength

func flash(color: Color, dur: float) -> void:
	flash_rect.color = Color(color.r, color.g, color.b, 0.6)
	var t := create_tween()
	t.tween_property(flash_rect, "color:a", 0.0, dur)

func burst(pos: Vector2, color: Color, count: int, sz: float, dur: float) -> void:
	for i in count:
		var r := ExhaustPuff.new()
		r.color = color
		r.radius = sz * 0.5
		r.position = pos
		r.z_index = 30
		world.add_child(r)
		var ang := randf() * TAU
		var dist := randf_range(40, 160)
		var target := r.position + Vector2(cos(ang), sin(ang)) * dist + Vector2(0, 120)
		var t := create_tween().set_parallel(true)
		t.tween_property(r, "position", target, dur).set_ease(Tween.EASE_OUT)
		t.tween_property(r, "modulate:a", 0.0, dur)
		t.finished.connect(r.queue_free)

func float_text(pos: Vector2, msg: String, color: Color) -> void:
	var l := Label.new()
	l.text = msg
	l.position = pos - Vector2(140, 0)
	l.size = Vector2(280, 40)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.06, 0.09, 0.16))
	l.add_theme_constant_override("outline_size", 5)
	l.z_index = 40
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(l)
	var t := create_tween().set_parallel(true)
	t.tween_property(l, "position:y", l.position.y - 70, 0.8)
	t.tween_property(l, "modulate:a", 0.0, 0.8)
	t.finished.connect(l.queue_free)

# ---- game over ----
func _die() -> void:
	if game_over:
		return
	game_over = true
	player.bounce()
	sfx.crash()
	if crashed_new:
		sfx.collect()
	sfx.stop_music()
	flash(Color(1, 0.3, 0.2), 0.2)
	shake(0.45, 14)
	CrazySDK.gameplay_stop()
	if crashed_new:
		CrazySDK.happytime()
	await get_tree().create_timer(0.5).timeout
	sfx.game_over()
	var go := GameOverScreen.new()
	add_child(go)
	go.setup({
		"score": score.total(distance),
		"distance": int(distance),
		"near_miss": score.near_miss,
		"patches": score.patches,
		"best_combo": score.best_combo,
		"mission_done": mission_done,
		"crashed_id": crashed_id,
		"crashed_new": crashed_new,
	})

# Small round smoke/debris puff drawn as a soft circle (nicer than a square).
class ExhaustPuff extends Node2D:
	var radius := 8.0
	var color := Color(0.85, 0.85, 0.88, 0.5)

	func _ready() -> void:
		queue_redraw()

	func _draw() -> void:
		draw_circle(Vector2.ZERO, radius, Color(color.r, color.g, color.b, color.a * 0.5))
		draw_circle(Vector2.ZERO, radius * 0.65, color)
