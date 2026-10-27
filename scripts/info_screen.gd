# IntroScreen.gd
extends Control

@onready var intro_label: RichTextLabel = $IntroLabel
@onready var typewriter_audio: AudioStreamPlayer = $TypewriterAudio

# Write your contextual lore text here
@export_multiline var intro_text: String = "The year is 1876, in Meridia Republic.\n\nYou are appointed as the Judicial Judge for the Republic.\n\nCases are being appoineted to you, make sure you get the right verdict, and move up the ranks\n\n CLICK ANYWHERE TO BEGIN"

var is_typing: bool = true

func _ready() -> void:
	intro_label.text = ""
	# Fade in from black slightly if desired, then start typing
	type_intro_text(intro_text, 0.03)

func type_intro_text(full_text: String, speed: float = 0.03) -> void:
	is_typing = true
	intro_label.text = ""
	
	for character in full_text:
		intro_label.text += character
		
		# Play typewriter click audio for non-empty characters
		if character.strip_edges() != "" and typewriter_audio:
			typewriter_audio.pitch_scale = randf_range(0.95, 1.05)
			typewriter_audio.play()
			
		await get_tree().create_timer(speed).timeout
		
	is_typing = false

func _input(event: InputEvent) -> void:
	# Allow player to click/tap to skip the typing animation or proceed after it finishes
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventScreenTouch and event.pressed):
		
		if is_typing:
			# Skip typing and show full text instantly
			is_typing = false
			# Stop any active timer / jump to end (handled by simply setting text)
			# Note: To fully abort an active await cleanly, you can also just transition:
			intro_label.text = intro_text
		else:
			# If text is already fully typed, proceed to the Chamber/Desk scene
			get_tree().change_scene_to_file("res://scenes/ChamberScene.tscn")
