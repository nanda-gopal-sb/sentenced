extends Control

const TEXTURE_CLOSED = preload("res://assets/sprites/folder_closed.png")
const TEXTURE_OPENED = preload("res://assets/sprites/folder_opened.png" )

@onready var texture_rect: TextureRect = $TextureRect
@onready var case_label: RichTextLabel = $CaseFile

@onready var left_page_label: RichTextLabel = $LeftText
@onready var right_page_label: RichTextLabel = $RightText
@onready var page_turn_btn: TextureButton = $RghtTurnButton
@onready var page_back_btn: TextureButton = $LeftTurnButton
@onready var choice_overlay: VBoxContainer = $ChoiceOverlay

@onready var deathPenaltyBtn: Button = $ChoiceOverlay/DeathPenalty
@onready var courtSummon: Button = $ChoiceOverlay/CourtSummon

var folder_pages: Array[String] = [
	"PAGE 1:\nINCIDENT DOSSIER\n\nSubject entered Kochi checkpoint without a valid entry permit.",
	"PAGE 2:\nBIOMETRICS\n\nEye Color: Brown\nHeight: 178 cm\nDistinguishing Marks: None.",
	"PAGE 3:\nPREVIOUS VIOLATIONS\n\n- 2024: Unauthorized entry attempt\n- 2025: Contraband smuggling.",
	"PAGE 4:\nFINAL VERDICT\n\nClearance denied.\nDetain subject if entry is forced.",
	""
]
const BASELINE_WIDTH: float = 80.0
const BASELINE_HEIGHT: float = 50.0
var current_spread_index: int = 0
var middle_zone: ReferenceRect
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var letter_content: String = "You Murdered My Family"

func _ready() -> void:
	page_turn_btn.pressed.connect(_on_page_turn_pressed)
	page_back_btn.pressed.connect(_on_page_back_pressed)
	courtSummon.pressed.connect(_on_address_court)
	update_ledger_display()
	gui_input.connect(_on_gui_input)
	left_page_label.visible = false
	right_page_label.visible = false
	page_turn_btn.visible = false
	page_back_btn.visible = false
	case_label.visible = true
	
	var desk_surface = get_parent()
	if desk_surface:
		middle_zone = desk_surface.get_node_or_null("LayoutGuild/MiddleZone")

func _process(_delta: float) -> void:
	if is_dragging and middle_zone:
		check_zone_collision()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = get_global_mouse_position() - global_position
			get_parent().move_child(self, -1)
		else:
			is_dragging = false

	if event is InputEventMouseMotion and is_dragging:
		global_position = get_global_mouse_position() - drag_offset

func check_zone_collision() -> void:
	# 1. Define the Rect2 for both the envelope and the middle zone
	var stable_size = Vector2(BASELINE_WIDTH, BASELINE_HEIGHT)
	var my_rect = Rect2(global_position, stable_size)
	
	var zone_rect = Rect2(middle_zone.global_position, middle_zone.size)
	
	# 3. Calculate areas
	var intersection_rect = my_rect.intersection(zone_rect)
	
	# 3. Calculate areas using the fixed baseline
	var my_area = my_rect.get_area() # Will always be 4000
	var overlap_area = intersection_rect.get_area()
	
	if overlap_area >= (my_area * 0.5):
		if texture_rect.texture != TEXTURE_OPENED:
			size = Vector2(90, 110)  # Enlarge the letter when it unfolds on the mat
			rotation_degrees = 0.0  # Straighten the letter when it unfolds on the mat
			texture_rect.texture = TEXTURE_OPENED
			# Show the text layer when unfolded on the mat
			left_page_label.visible = true
			right_page_label.visible = true
			case_label.visible = false
			page_turn_btn.visible = true
	else:
		if texture_rect.texture != TEXTURE_CLOSED:
			size = Vector2(76, 50)  # Shrink the letter back down when thrown off the mat
			rotation_degrees = randf_range(-12.0, 12.0)  # Reapply a random tilt when thrown back into the envelope pile
			texture_rect.texture = TEXTURE_CLOSED
			# Hide the text completely when thrown off the mat back into an envelope
			left_page_label.visible = false
			right_page_label.visible = false
			case_label.visible = true
			page_turn_btn.visible = false
			page_back_btn.visible = false
			choice_overlay.visible = false
			current_spread_index = 0 

func update_ledger_display() -> void:
	# Calculate which array indices correspond to our current left and right view
	var left_page_idx = current_spread_index * 2
	var right_page_idx = left_page_idx + 1
	
	# 1. Update Left Page Text
	if left_page_idx < folder_pages.size():
		left_page_label.text = folder_pages[left_page_idx]
		left_page_label.visible = true
	else:
		left_page_label.text = ""
		
	# 2. Update Right Page Text
	if right_page_idx < folder_pages.size():
		right_page_label.text = folder_pages[right_page_idx]
		right_page_label.visible = true
	else:
		right_page_label.text = ""

	# 3. Handle the Corner Visibility Rule!
	# Determine if there are more pages left to see further in the array
	var next_spread_has_pages = (current_spread_index + 1) * 2 < folder_pages.size()
	
	if next_spread_has_pages:
		page_turn_btn.visible = true
		choice_overlay.visible = false  # Keep the dog-ear visible if more pages remain
	else:
		page_turn_btn.visible = false # Hide it completely on the final page spread!
		choice_overlay.visible = true # Show the choices when the final page is reached
	
	# Determine if there are previous pages to see
	var previous_spread_has_pages = current_spread_index > 0
	if previous_spread_has_pages:
		page_back_btn.visible = true  # Keep the dog-ear visible if previous pages exist
	else:
		page_back_btn.visible = false # Hide it completely on the first page spread!

func _on_page_turn_pressed() -> void:
	current_spread_index += 1
	update_ledger_display()

func _on_page_back_pressed() -> void:
	current_spread_index -= 1
	update_ledger_display()
func _on_address_court() -> void:
	# 1. Hide the interactive choice panel immediately
	choice_overlay.visible = false
	
	# 2. Set the global engine background canvas color to absolute black
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	# 3. Hide your primary desk node structure container.
	# Assuming your root node setup is "/root/Control/DeskSurface", 
	# turning visible to false instantly stops rendering all desk sprites, text, and elements.
	var main_desk_surface = get_node("/root/Control")
	if main_desk_surface:
		main_desk_surface.visible = false
	
	# 4. Handle the cinematic 2-second dramatic hold using a clean SceneTree timer
	# This avoids needing to instantiate a custom Tween layout
	await get_tree().create_timer(2.0).timeout
	
	# 5. Jump straight into the courtroom scene once the timeout expires
	get_tree().change_scene_to_file("res://scenes/courtroom.tscn")