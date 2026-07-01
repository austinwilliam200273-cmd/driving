# Game: the Endless run. A top-down dodge-and-collect racer — steer to survive
# rising speed, weave past traffic for near-miss points, and crash into a car to
# add it to your garage. Built entirely in code (no asset files).
extends Node2D
class_name Game

var world: Node2D
var road: Road
var player: PlayerTruck
var hud: Hud
var sfx: Sfx
var flash_rect: ColorRect

var score: ScoreSystem
var scroll_speed := 320.0  # base px/sec, climbs slowly the whole run
var distance := 0.0
var game_over := false
var crashed_id := ""     # car model crashed into (unlocks it)
var crashed_new := false # was that a brand-new unlock?

var traffic: Array = []
var scenery: Array = []
var traffic_acc := 0.0
var scenery_acc := 0.0
var exhaust_acc := 0.0
var shake_time := 0.0
var shake_strength := 0.0

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
	sfx = Sfx.new()
	add_child(sfx)
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

	sfx.play_music()
	CrazySDK.gameplay_start()

func _process(delta: float) -> void:
	if game_over:
		return
	var dt: float = min(delta, 0.05)

	# slow, continuous acceleration over the whole run
	scroll_speed = min(scroll_speed + 9.0 * dt, 1150.0)
	var eff := scroll_speed * player.speed_mod
	distance += eff * dt * 0.08

	# input (keyboard + on-screen buttons)
	var steer := 0
	if Input.is_physical_key_pressed(KEY_LEFT) or Input.is_physical_key_pressed(KEY_A) or hud.btn_left:
		steer -= 1
	if Input.is_physical_key_pressed(KEY_RIGHT) or Input.is_physical_key_pressed(KEY_D) or hud.btn_right:
		steer += 1
	player.steer(steer, dt)
	player.update(dt)

	road.scroll += eff * dt
	road.queue_redraw()

	_update_scenery(dt, eff)
	_update_exhaust(dt)
	_update_traffic(dt, eff)

	if shake_time > 0.0:
		shake_time -= dt
		world.position = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_strength
	else:
		world.position = Vector2.ZERO

	hud.update_hud(score.total(distance), distance)

	# off the road edge = crash
	var hw := player.half.x
	if player.position.x < Consts.ROAD_X + hw * 0.4 or player.position.x > Consts.ROAD_RIGHT - hw * 0.4:
		_die()

# ---- traffic ----
func spawn_traffic_in_lane(lane: int) -> void:
	var car := TrafficCar.new()
	car.lane = lane
	car.position = Vector2(Consts.LANE_CENTERS[lane], -120)
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
	var diff: float = clamp((scroll_speed - 320.0) / (1150.0 - 320.0), 0.0, 1.0)
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
		if not car.collided and car.lane == pl_lane and y_hit:
			# Crash = collect that car + end the run.
			car.collided = true
			crashed_id = car.model.id
			crashed_new = SaveData.unlock(crashed_id)
			burst(player.position, Color(0.9, 0.3, 0.1), 12, 18, 0.9)
			_die()
			return

		if not car.counted and car.position.y > Consts.PLAYER_Y + 50:
			car.counted = true
			if abs(car.position.x - player.position.x) < 110:
				score.add_near_miss()
				sfx.near_miss()
				float_text(Vector2(player.position.x, Consts.PLAYER_Y - 90), "NEAR MISS +10", Consts.PICKUP_ENERGY)

		if car.dead():
			car.queue_free()
			traffic.remove_at(i)

# ---- roadside scenery ----
func spawn_scenery() -> void:
	var r := Roadside.new()
	r.kind = [0, 0, 0, 1, 1, 2, 3, 4, 5].pick_random()
	var x: float
	if randf() < 0.5:
		x = randf_range(18, Consts.ROAD_X - 28)
	else:
		x = randf_range(Consts.ROAD_RIGHT + 28, Consts.GAME_W - 18)
	r.position = Vector2(x, -90)
	r.scale = Vector2.ONE * randf_range(0.85, 1.2)
	r.z_index = -10
	world.add_child(r)
	scenery.append(r)

func _update_scenery(dt: float, eff: float) -> void:
	scenery_acc += dt
	if scenery_acc >= 0.5:
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
	var sz := randf_range(10, 16)
	var c := ColorRect.new()
	c.color = Color(0.85, 0.85, 0.88, 0.5)
	c.size = Vector2(sz, sz)
	c.pivot_offset = Vector2(sz / 2.0, sz / 2.0)
	c.position = player.position + Vector2(randf_range(-14, 14), player.half.y) - Vector2(sz / 2.0, sz / 2.0)
	c.z_index = 6
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	world.add_child(c)
	var t := create_tween().set_parallel(true)
	t.tween_property(c, "position:y", c.position.y + 90, 0.5)
	t.tween_property(c, "scale", Vector2(1.8, 1.8), 0.5)
	t.tween_property(c, "modulate:a", 0.0, 0.5)
	t.finished.connect(c.queue_free)

# ---- helpers ----
func _overlap(a, b, shrink: float = 0.7) -> bool:
	var ah: Vector2 = a.half * shrink
	var bh: Vector2 = b.half * shrink
	return abs(a.position.x - b.position.x) < (ah.x + bh.x) \
		and abs(a.position.y - b.position.y) < (ah.y + bh.y)

func shake(duration: float, strength: float) -> void:
	shake_time = max(shake_time, duration)
	shake_strength = strength

func flash(color: Color, dur: float) -> void:
	flash_rect.color = Color(color.r, color.g, color.b, 0.6)
	var t := create_tween()
	t.tween_property(flash_rect, "color:a", 0.0, dur)

func burst(pos: Vector2, color: Color, count: int, sz: float, dur: float) -> void:
	for i in count:
		var r := ColorRect.new()
		r.color = color
		r.size = Vector2(sz, sz)
		r.pivot_offset = Vector2(sz / 2.0, sz / 2.0)
		r.position = pos - Vector2(sz / 2.0, sz / 2.0)
		r.z_index = 30
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		world.add_child(r)
		var ang := randf() * TAU
		var dist := randf_range(40, 160)
		var target := r.position + Vector2(cos(ang), sin(ang)) * dist + Vector2(0, 120)
		var t := create_tween().set_parallel(true)
		t.tween_property(r, "position", target, dur).set_ease(Tween.EASE_OUT)
		t.tween_property(r, "rotation", randf_range(-6, 6), dur)
		t.tween_property(r, "modulate:a", 0.0, dur)
		t.finished.connect(r.queue_free)

func float_text(pos: Vector2, msg: String, color: Color) -> void:
	var l := Label.new()
	l.text = msg
	l.position = pos - Vector2(60, 0)
	l.size = Vector2(120, 40)
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
		"crashed_id": crashed_id,
		"crashed_new": crashed_new,
	})
