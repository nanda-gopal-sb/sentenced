# StartMenu.gd
extends Control

@onready var title_label: RichTextLabel = $TitileCard
@onready var name_input: LineEdit = $NameInput
@onready var start_button: Button = $Start

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	
	# Allow starting by pressing Enter inside the LineEdit
	name_input.text_submitted.connect(func(_text): _on_start_pressed())

func _on_start_pressed() -> void:
	var entered_name = name_input.text.strip_edges()
	
	# Fallback if no name entered
	if entered_name == "":
		entered_name = "Hon. Judge"
		
	# Store in GameManager
	GameManager.player_name = entered_name
	
	# Fade out or directly change scene to the main Chamber/Desk scene
	get_tree().change_scene_to_file("res://scenes/info_screen.tscn")
