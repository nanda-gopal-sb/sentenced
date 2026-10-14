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

var dialogue: Array = []
var current_line: int = 0
var is_waiting_for_verdict: bool = false
var is_starting: bool = true

func _ready():
	if GameManager.current_case.has("dialogue"):
		dialogue = GameManager.current_case["dialogue"]

	death_button.pressed.connect(func(): _on_verdict_chosen("Death Sentence"))
	not_guilty_button.pressed.connect(func(): _on_verdict_chosen("Not Guilty"))
	reduced_button.pressed.connect(func(): _on_verdict_chosen("Reduced Sentence"))
	
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
		continue_button.hide()
	
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

func calculate_points_earned() -> int:
	# Read actual_verdict and score_earned from last_judged_case snapshot
	var actual = GameManager.last_judged_case.get("actual_verdict", "")
	if GameManager.last_chosen_verdict == actual:
		return GameManager.last_judged_case.get("score_earned", 100)
	return 0

func type_result_text(full_text: String, speed: float = 0.03):
	result_label.text = ""
	result_label.visible = true
	for character in full_text:
		result_label.text += character
		await get_tree().create_timer(speed).timeout

func _on_verdict_chosen(verdict_name: String):
	is_waiting_for_verdict = true
	
	# Snapshot current case (Case N) and advance GameManager to Case N+1
	GameManager.finalize_verdict(verdict_name)
	
	verdict_panel.hide()
	dialogue_left.hide_dialogue()
	dialogue_right.hide_dialogue()
	
	# 1. Fade to black
	if fade_overlay:
		fade_overlay.visible = true
		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5)
		await tween.finished
		
	# 2. Brief pause in the dark
	await get_tree().create_timer(1.0).timeout
	
	# 3. Play gavel strike animation for ALL verdicts
	death_animation.visible = true
	death_animation.play("default")
	
	await get_tree().create_timer(2.5).timeout
		
	death_animation.visible = false
	await get_tree().create_timer(0.5).timeout
		
	# 4. Calculate points against Case N via last_judged_case
	var earned_points = calculate_points_earned()
	var promoted = GameManager.add_score_and_check_promotion(earned_points)
	
	var full_message = "You have chosen to give the " + verdict_name + "\n\nScore Earned: " + str(earned_points)
	if promoted:
		full_message += "\n\nPROMOTED TO LEVEL " + str(GameManager.current_level) + "!"
		
	# 5. Typewriter result display
	if result_label:
		await type_result_text(full_message, 0.03)
		
	# 6. Show return button
	if continue_button:
		continue_button.show()

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/ChamberScene.tscn")
