# GameManager.gd
extends Node
var player_name: String = "Hon. Judge" # Default fall-back name
var cases_data: Array = []
var current_case_index: int = 0
var current_case: Dictionary = {}

# Snapshot of the case just judged in courtroom (used for post-trial letters)
var last_judged_case: Dictionary = {}
var last_chosen_verdict: String = ""
var total_score: int = 0
var current_level: int = 1

const LEVEL_THRESHOLDS: Array[int] = [0, 300, 850, 1700, 3200, 5200]

func _ready() -> void:
	load_cases_from_json("res://data/data.json")
	if cases_data.size() > 0:
		set_current_case(0)

func load_cases_from_json(file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			cases_data = json.data
		else:
			print("JSON Parse Error: ", json.get_error_message())

func set_current_case(index: int) -> void:
	if index >= 0 and index < cases_data.size():
		current_case_index = index
		current_case = cases_data[index]

func advance_to_next_case() -> bool:
	current_case_index += 1
	if current_case_index < cases_data.size():
		set_current_case(current_case_index)
		return true
	return false

# Called in Courtroom when verdict is chosen
func finalize_verdict(verdict_name: String):
	last_chosen_verdict = verdict_name
	# Save a copy of the case we just finished judging
	last_judged_case = current_case.duplicate(true)
	# Immediately advance current_case so the desk folder shows the NEXT case
	advance_to_next_case()

# Letter generators now read from last_judged_case
func get_govt_letter() -> String:
	var desired_verdict = last_judged_case.get("actual_verdict", "")
	if last_chosen_verdict == desired_verdict:
		return last_judged_case.get("govt_positive_letter", "")
	elif last_chosen_verdict == "Reduced Sentence":
		return last_judged_case.get("govt_meh_letter", "")
	else:
		return last_judged_case.get("govt_negative_letter", "")

func get_family_letter() -> String:
	if last_chosen_verdict == "Death Sentence":
		return last_judged_case.get("family_negative_letter", "")
	else:
		return last_judged_case.get("family_positive_letter", "")

func add_score_and_check_promotion(earned_points: int) -> bool:
	total_score += earned_points
	var old_level = current_level
	var new_level = 1
	for i in range(LEVEL_THRESHOLDS.size()):
		if total_score >= LEVEL_THRESHOLDS[i]:
			new_level = i + 1
	if new_level > old_level:
		current_level = new_level
		return true
	return false
