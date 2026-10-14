# Desk.gd
extends Control

const ENVELOPE_SCENE = preload("res://scenes/components/envelope_item.tscn")
const CASE_FILE_SCENE = preload("res://scenes/components/case_file.tscn")
const PROFILE_CARD_SCENE = preload("res://scenes/components/profile.tscn")
@onready var right_zone = $LayoutGuild/RightZone
@onready var left_zone = $LayoutGuild/LeftZone

func _ready() -> void:
	# 1. Spawn current active case file (Next Case)
	spawn_case_files()
	spawn_profile_card()
	# 2. If returning from courtroom, spawn letters for the PREVIOUS case just judged
	if GameManager.last_chosen_verdict != "":
		var govt_letter = GameManager.get_govt_letter()
		var family_letter = GameManager.get_family_letter()
		
		spawn_letter_on_desk(govt_letter)
		spawn_letter_on_desk(family_letter)
	else:
		# Initial game start briefing letter
		spawn_letter_on_desk("To the Hon. Presiding Judge,\n\nWelcome to your chamber. Review the case dossier carefully before summoning the court.\n\nFrom: The High Ministry")


func spawn_profile_card() -> void:
	var profile = PROFILE_CARD_SCENE.instantiate()
	add_child(profile)
	
	# Position it near top corner or left zone
	var zone_pos = left_zone.global_position
	profile.global_position = Vector2(zone_pos.x + 10.0, zone_pos.y + 10.0)
	profile.rotation_degrees = -5.0

func spawn_letter_on_desk(content: String) -> void:
	var new_letter = ENVELOPE_SCENE.instantiate()
	new_letter.letter_content = content
	add_child(new_letter)
	
	var zone_pos = right_zone.global_position
	var zone_size = right_zone.size
	
	var random_x = zone_pos.x + (zone_size.x * 0.15) + randf_range(-15.0, 15.0)
	var random_y = zone_pos.y + (zone_size.y * 0.2) + randf_range(-20.0, 20.0)
	
	new_letter.global_position = Vector2(random_x, random_y)
	new_letter.rotation_degrees = randf_range(-12.0, 12.0)

func spawn_case_files() -> void:
	var new_case = CASE_FILE_SCENE.instantiate()
	add_child(new_case)
	
	var zone_pos = left_zone.global_position
	var zone_size = left_zone.size
	
	var random_x = zone_pos.x + (zone_size.x * 0.2) + randf_range(-10.0, 10.0)
	var random_y = zone_pos.y + (zone_size.y * 0.15) + randf_range(-15.0, 15.0)
	
	new_case.global_position = Vector2(random_x, random_y)
	new_case.rotation_degrees = randf_range(-5.0, 5.0)
