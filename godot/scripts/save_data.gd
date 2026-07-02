# SaveData: persistent storage (high score + collected/selected cars) in a
# ConfigFile under user://. All static so any script can read/write it.
class_name SaveData

const PATH := "user://pothole_patrol.cfg"
const DEFAULT_CAR := "repair_truck"

static func _cfg() -> ConfigFile:
	var c := ConfigFile.new()
	c.load(PATH)  # ignore error if the file doesn't exist yet
	return c

# --- high score ---
static func get_high() -> int:
	return int(_cfg().get_value("score", "high", 0))

static func set_high(v: int) -> void:
	var c := _cfg()
	c.set_value("score", "high", v)
	c.save(PATH)

# --- garage ---
static func get_owned() -> Array:
	return _cfg().get_value("garage", "owned", [DEFAULT_CAR])

static func is_owned(id: String) -> bool:
	return id in get_owned()

# Returns true if this id was newly added.
static func unlock(id: String) -> bool:
	var c := _cfg()
	var owned: Array = c.get_value("garage", "owned", [DEFAULT_CAR])
	if id in owned:
		return false
	owned.append(id)
	c.set_value("garage", "owned", owned)
	c.save(PATH)
	return true

static func get_selected() -> String:
	var sel: String = _cfg().get_value("garage", "selected", DEFAULT_CAR)
	if not is_owned(sel):
		return DEFAULT_CAR
	return sel

static func set_selected(id: String) -> void:
	var c := _cfg()
	c.set_value("garage", "selected", id)
	c.save(PATH)

# --- audio ---
static func get_muted() -> bool:
	return bool(_cfg().get_value("audio", "muted", false))

static func set_muted(v: bool) -> void:
	var c := _cfg()
	c.set_value("audio", "muted", v)
	c.save(PATH)
	AudioServer.set_bus_mute(0, v)

static func apply_mute() -> void:
	AudioServer.set_bus_mute(0, get_muted())

# --- progression ---
static func get_runs() -> int:
	return int(_cfg().get_value("progress", "runs", 0))

static func inc_runs() -> void:
	var c := _cfg()
	c.set_value("progress", "runs", int(c.get_value("progress", "runs", 0)) + 1)
	c.save(PATH)

static func get_mission_index() -> int:
	return int(_cfg().get_value("progress", "mission", 0))

static func advance_mission() -> void:
	var c := _cfg()
	c.set_value("progress", "mission", int(c.get_value("progress", "mission", 0)) + 1)
	c.save(PATH)

# --- controls ---
static func get_arrows() -> bool:
	return bool(_cfg().get_value("controls", "arrows", true))

static func set_arrows(v: bool) -> void:
	var c := _cfg()
	c.set_value("controls", "arrows", v)
	c.save(PATH)
