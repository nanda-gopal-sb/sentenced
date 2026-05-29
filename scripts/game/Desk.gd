extends Control

# Preload your envelope scene template
const ENVELOPE_SCENE = preload("res://scenes/components/envelope_item.tscn")
const CASE_FILE_SCENE = preload("res://scenes/components/case_file.tscn")
# Get references based on your exact image tree setup
@onready var right_zone = $LayoutGuild/RightZone
@onready var left_zone = $LayoutGuild/LeftZone

func _ready() -> void:
	# Let's spawn 3 letters right when the game starts
	for i in range(3):
		spawn_letter_on_desk()
		spawn_case_files()

func spawn_letter_on_desk() -> void:
	# 1. Instance the envelope
	var new_letter = ENVELOPE_SCENE.instantiate()
	
	# 2. Add it to DeskSurface so it sits nicely over the desk background texture
	add_child(new_letter)
	
	# 3. Position them natively within the RightZone bounds
	# We use global_position so it completely ignores any nested parent offsets
	var zone_pos = right_zone.global_position
	var zone_size = right_zone.size
	
	# Keep the spawn points inside the rect container boundaries safely
	var random_x = zone_pos.x + (zone_size.x * 0.15) + randf_range(-15.0, 15.0)
	var random_y = zone_pos.y + (zone_size.y * 0.2) + randf_range(-20.0, 20.0)
	
	new_letter.global_position = Vector2(random_x, random_y)
	
	# 4. Give them a slight messy rotation tilt
	new_letter.rotation_degrees = randf_range(-12.0, 12.0)


func spawn_case_files() -> void:
	# 1. Instance the envelope
	var new_case = CASE_FILE_SCENE.instantiate()
	
	# 2. Add it to DeskSurface so it sits nicely over the desk background texture
	add_child(new_case)
	
	# 3. Position them natively within the RightZone bounds
	# We use global_position so it completely ignores any nested parent offsets
	var zone_pos = left_zone.global_position
	var zone_size = left_zone.size
	
	# Keep the spawn points inside the rect container boundaries safely
	var random_x = zone_pos.x + (zone_size.x * 0.2) + randf_range(-10.0, 10.0)
	var random_y = zone_pos.y + (zone_size.y * 0.15) + randf_range(-15.0, 15.0)
	
	new_case.global_position = Vector2(random_x, random_y)
	
	# 4. Give them a slight messy rotation tilt
	new_case.rotation_degrees = randf_range(-5.0, 5.0)