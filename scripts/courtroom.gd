# CourtroomScene.gd
extends Control

@onready var dialogue_left = $Dialouge_Left
@onready var dialogue_right = $Dialouge_Left2
@onready var verdict_panel = $Panel
@onready var death_button = $Panel/VBoxContainer/Death_Sentence
@onready var not_guilty_button = $Panel/VBoxContainer/"Not Guilty"
@onready var reduced_button = $Panel/VBoxContainer/ReducedSentence
@onready var death_animation = $AnimatedSprite2D
@onready var fade_overlay = $FadeOverlay
@onready var result_label = $ResultLabel
@onready var continue_button = $ContinueButton

# Back-and-forth dialogue script before verdict buttons appear
var dialogue: Array[Dictionary] = [
	{
		"speaker": "PROSECUTION",
		"side": "left",
		"text": "Your Honor, the evidence clearly shows that the defendant is guilty!"
	},
	{
		"speaker": "DEFENSE",
		"side": "right",
		"text": "Objection! That evidence was completely circumstantial!"
	},
	{
		"speaker": "PROSECUTION",
		"side": "left",
		"text": "Circumstantial or not, the testimony seals their fate."
	},
	{
		"speaker": "DEFENSE",
		"side": "right",
		"text": "We demand the court look at the facts before deciding a verdict."
	}
]

var current_line: int = 0
var is_waiting_for_verdict: bool = false
var is_starting: bool = true

func _ready():
	# Connect verdict buttons
	death_button.pressed.connect(func(): _on_verdict_chosen("Death Sentence"))
	not_guilty_button.pressed.connect(func(): _on_verdict_chosen("Not Guilty"))
	reduced_button.pressed.connect(func(): _on_verdict_chosen("Reduced Sentence"))
	
	# Connect continue button
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
		continue_button.hide()
	
	# Initial UI states
	verdict_panel.hide()
	dialogue_left.hide_dialogue()
	dialogue_right.hide_dialogue()
	death_animation.visible = false
	
	if fade_overlay:
		fade_overlay.modulate.a = 0.0
		fade_overlay.visible = false
		
	if result_label:
		result_label.text = ""
		result_label.visible = false
		
	start_trial()

func start_trial():
	current_line = 0
	is_waiting_for_verdict = false
	is_starting = true
	
	await get_tree().create_timer(2.0).timeout
	is_starting = false
	show_line()

func show_line():
	if current_line >= dialogue.size():
		is_waiting_for_verdict = true
		dialogue_left.hide_dialogue()
		dialogue_right.hide_dialogue()
		verdict_panel.show()
		return

	var line = dialogue[current_line]
	
	if line["side"] == "left":
		dialogue_left.show_dialogue(line["speaker"], line["text"])
		dialogue_right.hide_dialogue()
	else:
		dialogue_right.show_dialogue(line["speaker"], line["text"])
		dialogue_left.hide_dialogue()

func _input(event: InputEvent) -> void:
	if is_starting or is_waiting_for_verdict:
		return

	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventScreenTouch and event.pressed):
		current_line += 1
		show_line()

# Placeholder function for score calculation
func get_score_earned() -> int:
	# TODO: Replace with your actual score calculation logic later
	return 150

# Typewriter effect function for the ResultLabel
func type_result_text(full_text: String, speed: float = 0.03):
	result_label.text = ""
	result_label.visible = true
	for character in full_text:
		result_label.text += character
		await get_tree().create_timer(speed).timeout

func _on_verdict_chosen(verdict_name: String):
	is_waiting_for_verdict = true
	verdict_panel.hide()
	dialogue_left.hide_dialogue()
	dialogue_right.hide_dialogue()
	
	# 1. Fade to black
	if fade_overlay:
		fade_overlay.visible = true
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5)
		await tween.finished
		
	# 2. Wait for a few seconds in the dark
	await get_tree().create_timer(2.0).timeout
	
	# 3. Play the animation
	death_animation.visible = true
	death_animation.play("default")
	
	await get_tree().create_timer(3.0).timeout
		
	if result_label:
		var score = get_score_earned()
		var full_message = "You have chosen to give the " + verdict_name + "\n\nScore Earned: " + str(score)
		await type_result_text(full_message, 0.03)
		
	if continue_button:
		continue_button.show()

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/ChamberScene.tscn")
