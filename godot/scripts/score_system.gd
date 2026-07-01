# ScoreSystem: distance plus near-miss bonuses.
#   score = floor(distance_m) + near_miss * 10
extends RefCounted
class_name ScoreSystem

var near_miss := 0

func add_near_miss() -> void:
	near_miss += 1

func total(distance_m: float) -> int:
	return int(floor(distance_m)) + near_miss * 10
