# Missions: one simple session goal per run, progressing through a fixed list
# (persisted in SaveData). After the list is exhausted the harder half cycles
# forever. Completing a mission awards Consts.MISSION_PTS and advances the list.
class_name Missions

const LIST := [
	{"type": "patch", "goal": 5, "text": "Patch 5 potholes"},
	{"type": "near", "goal": 5, "text": "Get 5 near misses"},
	{"type": "dist", "goal": 400, "text": "Drive 400 m"},
	{"type": "patch", "goal": 12, "text": "Patch 12 potholes"},
	{"type": "time", "goal": 45, "text": "Survive 45 seconds"},
	{"type": "near", "goal": 12, "text": "Get 12 near misses"},
	{"type": "dist", "goal": 800, "text": "Drive 800 m"},
	{"type": "patch", "goal": 20, "text": "Patch 20 potholes"},
	{"type": "time", "goal": 75, "text": "Survive 75 seconds"},
	{"type": "near", "goal": 20, "text": "Get 20 near misses"},
	{"type": "dist", "goal": 1200, "text": "Drive 1200 m"},
	{"type": "patch", "goal": 30, "text": "Patch 30 potholes"},
]
const CYCLE_FROM := 6  # once finished, loop the harder back half

static func current() -> Dictionary:
	var i := SaveData.get_mission_index()
	if i < LIST.size():
		return LIST[i]
	return LIST[CYCLE_FROM + (i - LIST.size()) % (LIST.size() - CYCLE_FROM)]

# Progress value for the current mission given this run's stats.
static func progress(m: Dictionary, score: ScoreSystem, distance: float, run_time: float) -> int:
	match m.type:
		"patch": return score.patches
		"near": return score.near_miss
		"dist": return int(distance)
		"time": return int(run_time)
	return 0
