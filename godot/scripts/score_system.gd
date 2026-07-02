# ScoreSystem: distance, near-miss bonuses, pothole patches (with a combo
# multiplier) and mission rewards.
#   score = floor(distance_m) + near_miss*10 + patch points + mission bonus
extends RefCounted
class_name ScoreSystem

var near_miss := 0
var patches := 0
var combo := 0          # consecutive potholes patched without missing one
var best_combo := 0
var patch_score := 0
var mission_bonus := 0

func add_near_miss() -> void:
	near_miss += 1

# Returns the points awarded for this patch (base * combo, capped).
func add_patch() -> int:
	patches += 1
	combo += 1
	best_combo = max(best_combo, combo)
	var pts: int = Consts.PATCH_PTS * mini(combo, Consts.PATCH_COMBO_CAP)
	patch_score += pts
	return pts

func break_combo() -> void:
	combo = 0

func add_mission_bonus() -> void:
	mission_bonus += Consts.MISSION_PTS

func total(distance_m: float) -> int:
	return int(floor(distance_m)) + near_miss * Consts.NEAR_MISS_PTS + patch_score + mission_bonus
