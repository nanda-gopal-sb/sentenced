extends Control

# Preload your envelope scene template
const ENVELOPE_SCENE = preload("res://scenes/components/envelope_item.tscn")

# Get references based on your exact image tree setup
@onready var right_zone = $LayoutGuild/RightZone

func _ready() -> void:
	# Let's spawn 3 letters right when the game starts
	for i in range(3):
		spawn_letter_on_desk()

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
	var random_x = zone_pos.x + randf_range(10.0, zone_size.x - 90.0)
	var random_y = zone_pos.y + randf_range(10.0, zone_size.y - 60.0)
	
	new_letter.global_position = Vector2(random_x, random_y)
	
	# 4. Give them a slight messy rotation tilt
	new_letter.rotation_degrees = randf_range(-12.0, 12.0)