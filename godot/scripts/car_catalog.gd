# CarCatalog: master list of car models + the shared drawing routine.
# `chance` is the relative spawn weight; rarity is shown to the player as "1 in N"
# (computed from the total weight). The repair truck is the free starter and never
# spawns in traffic. Everything else is collected by crashing into it.
class_name CarCatalog

static func cars() -> Array:
	return [
		{"id": "repair_truck", "name": "Repair Truck", "color": Consts.PLAYER, "rarity": "Starter", "chance": 0.0, "special": "truck"},
		# Common
		{"id": "hatchback", "name": "Hatchback", "color": Color(0.10, 0.65, 0.62), "rarity": "Common", "chance": 26.0, "special": ""},
		{"id": "sedan", "name": "Sedan", "color": Color(0.85, 0.22, 0.22), "rarity": "Common", "chance": 22.0, "special": ""},
		{"id": "compact", "name": "Compact", "color": Color(0.30, 0.62, 0.90), "rarity": "Common", "chance": 18.0, "special": "two_tone", "accent": Color(0.16, 0.32, 0.55)},
		{"id": "pickup", "name": "Pickup", "color": Color(0.55, 0.40, 0.22), "rarity": "Common", "chance": 16.0, "special": "pickup"},
		{"id": "wagon", "name": "Wagon", "color": Color(0.30, 0.55, 0.32), "rarity": "Common", "chance": 14.0, "special": "wagon", "accent": Color(0.22, 0.42, 0.24)},
		{"id": "roadster", "name": "Roadster", "color": Color(0.90, 0.35, 0.20), "rarity": "Common", "chance": 20.0, "special": "stripe", "accent": Color(0.98, 0.95, 0.90)},
		# Uncommon
		{"id": "van", "name": "Cargo Van", "color": Color(0.45, 0.30, 0.75), "rarity": "Uncommon", "chance": 10.0, "special": "van"},
		{"id": "sports", "name": "Sport Coupe", "color": Color(0.15, 0.70, 0.30), "rarity": "Uncommon", "chance": 7.0, "special": "stripe", "accent": Color(0.95, 0.97, 1.0)},
		{"id": "muscle", "name": "Muscle Car", "color": Color(0.92, 0.45, 0.08), "rarity": "Uncommon", "chance": 6.0, "special": "stripe", "accent": Color(0.10, 0.10, 0.12)},
		{"id": "minivan", "name": "Minivan", "color": Color(0.40, 0.50, 0.62), "rarity": "Uncommon", "chance": 5.0, "special": "van"},
		{"id": "offroad", "name": "Off-Roader", "color": Color(0.50, 0.52, 0.30), "rarity": "Uncommon", "chance": 4.5, "special": "pickup"},
		{"id": "camper", "name": "Camper", "color": Color(0.86, 0.82, 0.66), "rarity": "Uncommon", "chance": 6.5, "special": "van"},
		# Rare
		{"id": "taxi", "name": "City Taxi", "color": Color(0.98, 0.78, 0.10), "rarity": "Rare", "chance": 4.0, "special": "taxi"},
		{"id": "police", "name": "Interceptor", "color": Color(0.10, 0.11, 0.14), "rarity": "Rare", "chance": 3.0, "special": "police"},
		{"id": "ambulance", "name": "Ambulance", "color": Color(0.95, 0.96, 0.98), "rarity": "Rare", "chance": 2.5, "special": "ambulance"},
		{"id": "delivery", "name": "Delivery Van", "color": Color(0.62, 0.42, 0.24), "rarity": "Rare", "chance": 2.0, "special": "van"},
		{"id": "gt", "name": "Grand Tourer", "color": Color(0.18, 0.35, 0.85), "rarity": "Rare", "chance": 1.8, "special": "stripe", "accent": Color(0.95, 0.97, 1.0)},
		{"id": "drift", "name": "Drift Spec", "color": Color(0.55, 0.20, 0.75), "rarity": "Rare", "chance": 2.2, "special": "stripe", "accent": Color(0.98, 0.30, 0.70)},
		# Epic
		{"id": "inferno", "name": "Inferno GT", "color": Color(0.80, 0.12, 0.10), "rarity": "Epic", "chance": 1.2, "special": "flame", "accent": Color(1.0, 0.55, 0.12)},
		{"id": "hotrod", "name": "Hot Rod", "color": Color(0.45, 0.06, 0.06), "rarity": "Epic", "chance": 0.9, "special": "flame", "accent": Color(1.0, 0.7, 0.15)},
		{"id": "racer", "name": "Race Car", "color": Color(0.93, 0.95, 0.98), "rarity": "Epic", "chance": 0.7, "special": "race", "accent": Color(0.85, 0.15, 0.15)},
		{"id": "toxic", "name": "Toxic", "color": Color(0.45, 0.85, 0.10), "rarity": "Epic", "chance": 0.8, "special": "neon", "accent": Color(0.70, 1.0, 0.20)},
		# Legendary
		{"id": "diamond", "name": "Diamondback", "color": Color(0.35, 0.85, 0.92), "rarity": "Legendary", "chance": 0.6, "special": "diamond"},
		{"id": "golden", "name": "Golden Cruiser", "color": Color(0.95, 0.78, 0.18), "rarity": "Legendary", "chance": 0.5, "special": "gold", "accent": Color(1.0, 0.92, 0.55)},
		{"id": "chrome", "name": "Chrome Bullet", "color": Color(0.78, 0.80, 0.85), "rarity": "Legendary", "chance": 0.45, "special": "chrome"},
		{"id": "onyx", "name": "Onyx", "color": Color(0.10, 0.10, 0.13), "rarity": "Legendary", "chance": 0.5, "special": "chrome"},
		# Mythic
		{"id": "phantom", "name": "Phantom", "color": Color(0.85, 0.90, 1.0), "rarity": "Mythic", "chance": 0.3, "special": "ghost"},
		{"id": "neon", "name": "Neon Rider", "color": Color(0.95, 0.15, 0.75), "rarity": "Mythic", "chance": 0.25, "special": "neon"},
		{"id": "rainbow", "name": "Rainbow Racer", "color": Color(1, 1, 1), "rarity": "Mythic", "chance": 0.2, "special": "rainbow"},
		{"id": "prism", "name": "Prism", "color": Color(0.90, 0.90, 0.95), "rarity": "Mythic", "chance": 0.22, "special": "chromatic"},
		# Exotic
		{"id": "galaxy", "name": "Galaxy Glider", "color": Color(0.10, 0.10, 0.28), "rarity": "Exotic", "chance": 0.14, "special": "galaxy"},
		{"id": "aurora", "name": "Aurora", "color": Color(0.10, 0.55, 0.55), "rarity": "Exotic", "chance": 0.12, "special": "neon", "accent": Color(0.4, 1.0, 0.6)},
		{"id": "chromatic", "name": "Chromatic", "color": Color(0.8, 0.2, 0.9), "rarity": "Exotic", "chance": 0.10, "special": "chromatic"},
		{"id": "hologram", "name": "Hologram", "color": Color(0.14, 0.40, 0.62), "rarity": "Exotic", "chance": 0.09, "special": "holo"},
		{"id": "comet", "name": "Comet", "color": Color(0.08, 0.06, 0.22), "rarity": "Exotic", "chance": 0.10, "special": "galaxy"},
		# Secret (the long chase — still reachable in a good session streak)
		{"id": "glitch", "name": "G̷l̴i̶t̷c̸h", "color": Color(0.05, 0.9, 0.7), "rarity": "Secret", "chance": 0.07, "special": "glitch"},
		{"id": "pulsar", "name": "Pulsar", "color": Color(0.98, 0.20, 0.55), "rarity": "Secret", "chance": 0.06, "special": "pulsar"},
		{"id": "developer", "name": "Dev Car", "color": Color(0.12, 0.12, 0.14), "rarity": "Secret", "chance": 0.05, "special": "two_tone", "accent": Color(0.0, 0.9, 0.4)},
		# Ultimate (the months-long chase — spotting one on the road is an event)
		{"id": "midas", "name": "King Midas", "color": Color(0.85, 0.65, 0.10), "rarity": "Ultimate", "chance": 0.02, "special": "gold", "accent": Color(1.0, 0.95, 0.60)},
		{"id": "phoenix", "name": "Phoenix", "color": Color(0.55, 0.10, 0.05), "rarity": "Ultimate", "chance": 0.012, "special": "flame", "accent": Color(1.0, 0.45, 0.05)},
		{"id": "eclipse", "name": "Eclipse", "color": Color(0.05, 0.05, 0.10), "rarity": "Ultimate", "chance": 0.009, "special": "galaxy"},
		{"id": "void", "name": "The Void", "color": Color(0.03, 0.02, 0.08), "rarity": "Ultimate", "chance": 0.005, "special": "void"},
	]

static func get_by_id(id: String) -> Dictionary:
	for c in cars():
		if c.id == id:
			return c
	return {}

static func index_of(id: String) -> int:
	var list := cars()
	for i in list.size():
		if list[i].id == id:
			return i
	return -1

static func total_weight() -> float:
	var t := 0.0
	for c in cars():
		t += c.chance
	return t

static func weighted_random() -> Dictionary:
	var list := []
	var total := 0.0
	for c in cars():
		if c.chance > 0.0:
			list.append(c)
			total += c.chance
	var r := randf() * total
	for c in list:
		r -= c.chance
		if r <= 0.0:
			return c
	return list.back()

static func chance_text(m: Dictionary) -> String:
	if m.chance <= 0.0:
		return "Starter"
	var odds := int(round(total_weight() / m.chance))
	return "1 in %s" % _commas(odds)

static func _commas(n: int) -> String:
	var s := str(n)
	var out := ""
	var c := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = "," + out
	return out

static func rarity_color(r: String) -> Color:
	match r:
		"Common": return Color(0.72, 0.74, 0.77)
		"Uncommon": return Color(0.30, 0.80, 0.36)
		"Rare": return Color(0.27, 0.55, 0.96)
		"Epic": return Color(0.66, 0.36, 0.96)
		"Legendary": return Color(0.98, 0.80, 0.10)
		"Mythic": return Color(0.96, 0.30, 0.56)
		"Exotic": return Color(0.10, 0.85, 0.85)
		"Secret": return Color(1.0, 0.25, 0.35)
		"Ultimate": return Color(0.78, 0.62, 1.0)
		_: return Color(0.85, 0.85, 0.88)

# Cars whose look animates each frame (color cycling / moving decals).
static func is_animated(special: String) -> bool:
	return special in ["chromatic", "holo", "pulsar", "rainbow", "void"]

# ---- drawing helpers ----
static func _rrect(ci: CanvasItem, x: float, y: float, w: float, h: float, r: float, col: Color) -> void:
	ci.draw_rect(Rect2(x + r, y, w - 2 * r, h), col)
	ci.draw_rect(Rect2(x, y + r, w, h - 2 * r), col)
	ci.draw_circle(Vector2(x + r, y + r), r, col)
	ci.draw_circle(Vector2(x + w - r, y + r), r, col)
	ci.draw_circle(Vector2(x + r, y + h - r), r, col)
	ci.draw_circle(Vector2(x + w - r, y + h - r), r, col)

static func star_points(center: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 10:
		var rad := r if i % 2 == 0 else r * 0.45
		var a := -PI / 2.0 + PI * i / 5.0
		pts.append(center + Vector2(cos(a), sin(a)) * rad)
	return pts

static func draw_star(ci: CanvasItem, center: Vector2, r: float, color: Color) -> void:
	ci.draw_colored_polygon(star_points(center, r), color)

# Draws a car centred on (0,0). `t` is elapsed time (sec) for animated specials.
static func draw_car(ci: CanvasItem, m: Dictionary, w: float, h: float, _is_player: bool, t: float = 0.0) -> void:
	var hw := w / 2.0
	var hh := h / 2.0
	var body: Color = m.color
	var special: String = m.get("special", "")
	var base_accent: Color = m.get("accent", body.lightened(0.18))
	var alpha := 0.5 if special == "ghost" else 1.0
	var bc := Color(body.r, body.g, body.b, alpha)
	var ac := Color(base_accent.r, base_accent.g, base_accent.b, alpha)
	if special == "chromatic":
		bc = Color.from_hsv(fmod(t * 0.25, 1.0), 0.72, 0.96, alpha)
		ac = Color.from_hsv(fmod(t * 0.25 + 0.5, 1.0), 0.6, 0.92, alpha)
	elif special == "pulsar":
		bc = body.lightened(0.3 * (0.5 + 0.5 * sin(t * 6.0)))
		bc.a = alpha
	var outline := bc.darkened(0.4)
	outline.a = alpha

	# soft drop shadow (two layers) + wheels (tires with hubcaps)
	_rrect(ci, -hw + 3, -hh + 6, w + 4, h + 4, 14, Color(0, 0, 0, 0.10))
	_rrect(ci, -hw + 5, -hh + 9, w, h, 12, Color(0, 0, 0, 0.14))
	for wy in [-hh + 14, hh - 46]:
		ci.draw_rect(Rect2(-hw - 4, wy, 9, 32), Consts.WHEEL)
		ci.draw_rect(Rect2(hw - 5, wy, 9, 32), Consts.WHEEL)
		ci.draw_rect(Rect2(-hw - 4, wy + 2, 3, 28), Color(0.20, 0.22, 0.28))
		ci.draw_rect(Rect2(hw + 1, wy + 2, 3, 28), Color(0.20, 0.22, 0.28))
		ci.draw_circle(Vector2(-hw + 1, wy + 16), 3.0, Color(0.55, 0.55, 0.6))
		ci.draw_circle(Vector2(hw - 1, wy + 16), 3.0, Color(0.55, 0.55, 0.6))

	# glow (neon / pulsar)
	if special == "neon":
		ci.draw_rect(Rect2(-hw - 6, -hh - 6, w + 12, h + 12), Color(body.r, body.g, body.b, 0.28))
	elif special == "pulsar":
		var pg := 0.18 + 0.22 * (0.5 + 0.5 * sin(t * 6.0))
		ci.draw_rect(Rect2(-hw - 8, -hh - 8, w + 16, h + 16), Color(body.r, body.g, body.b, pg))
	elif special == "void":
		var vg := 0.15 + 0.15 * (0.5 + 0.5 * sin(t * 2.5))
		ci.draw_rect(Rect2(-hw - 8, -hh - 8, w + 16, h + 16), Color(0.45, 0.20, 0.85, vg))

	# body (rounded, with outline)
	_rrect(ci, -hw, -hh, w, h, 12, outline)
	if special == "rainbow":
		var cnt := 6
		var bh := (h - 4) / cnt
		for i in cnt:
			var hue := fmod(float(i) / cnt + t * 0.18, 1.0)  # flowing colours
			ci.draw_rect(Rect2(-hw + 2, -hh + 2 + i * bh, w - 4, bh + 1), Color.from_hsv(hue, 0.85, 0.95, alpha))
	else:
		_rrect(ci, -hw + 2, -hh + 2, w - 4, h - 4, 11, bc)

	# body shading: lit down the middle, shaded at the sills (reads as curvature)
	ci.draw_rect(Rect2(-hw + 8, -hh + 4, 5, h - 8), Color(1, 1, 1, 0.16 * alpha))
	ci.draw_rect(Rect2(-hw + 2, -hh + 6, 3, h - 12), Color(0, 0, 0, 0.13 * alpha))
	ci.draw_rect(Rect2(hw - 5, -hh + 6, 3, h - 12), Color(0, 0, 0, 0.13 * alpha))

	# cabin / cargo
	if special == "van":
		_rrect(ci, -hw + 3, -hh + 28, w - 6, hh + 24, 8, ac)
		ci.draw_rect(Rect2(-hw + 2, 8, w - 4, 12), Color(0.92, 0.94, 0.98))
	elif special == "wagon":
		_rrect(ci, -hw + 6, -hh + 26, w - 12, hh + 12, 8, ac)
	elif special != "rainbow":
		_rrect(ci, -hw + 6, -hh + 26, w - 12, 30, 8, ac)

	# paint flair (under glass)
	match special:
		"truck", "pickup":
			ci.draw_rect(Rect2(-hw + 4, 6, w - 8, hh - 16), body.darkened(0.2))
		"stripe":
			ci.draw_rect(Rect2(-6, -hh + 2, 12, h - 4), ac)
		"two_tone":
			_rrect(ci, -hw + 2, 4, w - 4, hh - 4, 8, ac)
		"taxi":
			for i in 6:
				var col := Color(0.1, 0.1, 0.1) if i % 2 == 0 else Color(1, 1, 1)
				ci.draw_rect(Rect2(-hw + i * (w / 6.0), -3, w / 6.0, 8), col)
		"police":
			ci.draw_rect(Rect2(-hw + 2, -5, w - 4, 12), Color(0.95, 0.95, 0.97))
		"ambulance":
			ci.draw_rect(Rect2(-hw + 2, -5, w - 4, 12), Color(0.85, 0.15, 0.12))
		"gold":
			ci.draw_rect(Rect2(-hw + 9, -hh + 4, 7, h - 8), Color(1, 1, 0.85, 0.55))
		"chrome":
			ci.draw_rect(Rect2(-hw + w * 0.28, -hh + 3, 6, h - 6), Color(1, 1, 1, 0.5))
			ci.draw_rect(Rect2(-hw + w * 0.62, -hh + 3, 4, h - 6), Color(1, 1, 1, 0.35))
		"diamond":
			ci.draw_line(Vector2(-hw + 5, -hh + 12), Vector2(hw - 5, hh - 12), Color(1, 1, 1, 0.5), 2)
			ci.draw_line(Vector2(hw - 5, -hh + 12), Vector2(-hw + 5, hh - 12), Color(1, 1, 1, 0.5), 2)
		"flame":
			ci.draw_colored_polygon(PackedVector2Array([Vector2(-hw + 4, hh - 4), Vector2(-hw + 4, -8), Vector2(-hw + 28, hh - 4)]), Color(1, 0.6, 0.1))
			ci.draw_colored_polygon(PackedVector2Array([Vector2(hw - 4, hh - 4), Vector2(hw - 4, -8), Vector2(hw - 28, hh - 4)]), ac)
		"holo":
			for k in 5:
				var yy := -hh + fmod(t * 60.0 + k * 22.0, h)  # scrolling holo bands
				ci.draw_rect(Rect2(-hw + 2, yy, w - 4, 5), Color(0.2, 0.9, 1.0, 0.4))
				ci.draw_rect(Rect2(-hw + 2, yy + 8, w - 4, 3), Color(1.0, 0.3, 0.9, 0.3))
		"glitch":
			ci.draw_rect(Rect2(-hw, -hh + h * 0.30, w - 6, 8), Color(0, 1, 1, 0.7))
			ci.draw_rect(Rect2(-hw + 6, -hh + h * 0.55, w - 6, 6), Color(1, 0, 1, 0.7))
			ci.draw_rect(Rect2(-hw + 2, -hh + h * 0.72, w - 10, 5), Color(1, 1, 1, 0.6))
		"galaxy":
			for i in 16:
				var px := sin(i * 12.9898) * hw * 0.8
				var py := cos(i * 78.233) * hh * 0.85
				ci.draw_circle(Vector2(px, py), 1.6, Color(1, 1, 1, 0.9))
			ci.draw_circle(Vector2(hw * 0.3, -hh * 0.3), 3, Color(0.6, 0.8, 1.0))
			ci.draw_circle(Vector2(-hw * 0.4, hh * 0.2), 2.5, Color(1.0, 0.7, 0.9))
		"void":
			# a slowly swirling accretion ring around a black centre
			ci.draw_circle(Vector2.ZERO, hw * 0.62, Color(0.30, 0.12, 0.55, 0.6))
			ci.draw_circle(Vector2.ZERO, hw * 0.42, Color(0, 0, 0, 0.95))
			ci.draw_arc(Vector2.ZERO, hw * 0.55, t * 2.0, t * 2.0 + PI * 1.3, 20,
				Color(0.75, 0.45, 1.0, 0.9), 3.0)
			ci.draw_arc(Vector2.ZERO, hw * 0.72, -t * 1.3, -t * 1.3 + PI * 0.9, 16,
				Color(0.45, 0.85, 1.0, 0.7), 2.0)
			for i in 3:
				var oa := t * 1.6 + TAU * i / 3.0
				ci.draw_circle(Vector2(cos(oa), sin(oa)) * hw * 0.62, 2.2, Color(0.9, 0.8, 1.0))

	# windshield (trapezoid glass with a diagonal shine) + rear window
	var wsc := Consts.WINDOW
	wsc.a = 0.85 * alpha
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(-hw + 12, -hh + 26), Vector2(hw - 12, -hh + 26),
		Vector2(hw - 9, -hh + 8), Vector2(-hw + 9, -hh + 8)]), wsc)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(-hw + 11, -hh + 12), Vector2(-hw + 22, -hh + 10),
		Vector2(-hw + 15, -hh + 24), Vector2(-hw + 11, -hh + 24)]),
		Color(1, 1, 1, 0.30 * alpha))
	# side mirrors
	ci.draw_rect(Rect2(-hw - 6, -hh + 26, 7, 9), outline)
	ci.draw_rect(Rect2(hw - 1, -hh + 26, 7, 9), outline)
	if special in ["", "stripe", "two_tone", "taxi", "police", "gold", "chrome", "diamond", "neon", "ambulance", "race", "ghost", "glitch", "galaxy", "flame", "rainbow", "chromatic", "holo", "pulsar"]:
		ci.draw_rect(Rect2(-hw + 12, -hh + 58, w - 24, 12), Consts.WINDOW.lightened(0.1))

	# overlay flair (on top of glass)
	match special:
		"truck":
			ci.draw_circle(Vector2(0, -hh + 41), 6, Color(1, 0.72, 0.12))
		"police":
			ci.draw_rect(Rect2(-13, -hh + 24, 11, 8), Color(0.12, 0.32, 1.0))
			ci.draw_rect(Rect2(2, -hh + 24, 11, 8), Color(1.0, 0.12, 0.12))
		"ambulance":
			ci.draw_rect(Rect2(-4, -hh + 30, 8, 22), Color(0.85, 0.15, 0.12))
			ci.draw_rect(Rect2(-11, -hh + 37, 22, 8), Color(0.85, 0.15, 0.12))
		"race":
			ci.draw_rect(Rect2(-5, -hh, 10, h), ac)
			ci.draw_circle(Vector2(0, -2), 11, Color(1, 1, 1))
			ci.draw_arc(Vector2(0, -2), 11, 0, TAU, 18, Color(0.1, 0.1, 0.1), 2.0)

	# lights (headlights get a faint forward glow)
	ci.draw_circle(Vector2(-hw + 10, -hh - 2), 8, Color(1, 0.96, 0.65, 0.18 * alpha))
	ci.draw_circle(Vector2(hw - 10, -hh - 2), 8, Color(1, 0.96, 0.65, 0.18 * alpha))
	ci.draw_rect(Rect2(-hw + 5, -hh + 1, 11, 6), Consts.HEADLIGHT)
	ci.draw_rect(Rect2(hw - 16, -hh + 1, 11, 6), Consts.HEADLIGHT)
	ci.draw_rect(Rect2(-hw + 5, hh - 7, 11, 6), Consts.TAILLIGHT)
	ci.draw_rect(Rect2(hw - 16, hh - 7, 11, 6), Consts.TAILLIGHT)
