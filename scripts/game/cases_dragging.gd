extends Control

const TEXTURE_CLOSED = preload("res://assets/sprites/folder_closed.png")
const TEXTURE_OPENED = preload("res://assets/sprites/folder_opened.png" )

@onready var texture_rect: TextureRect = $TextureRect
#@onready var document_text: RichTextLabel = $DocumentText
const BASELINE_WIDTH: float = 80.0
const BASELINE_HEIGHT: float = 50.0

var middle_zone: ReferenceRect
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Simple data string for the letter's contents
var letter_content: String = "You Murdered My Family"

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	print("helo")
	# Keep text hidden by default while it sits inside the closed envelope pile
	#document_text.visible = false
	#document_text.text = letter_content
	
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
			#document_text.visible = true
	else:
		if texture_rect.texture != TEXTURE_CLOSED:
			size = Vector2(76, 50)  # Shrink the letter back down when thrown off the mat
			rotation_degrees = randf_range(-12.0, 12.0)  # Reapply a random tilt when thrown back into the envelope pile
			texture_rect.texture = TEXTURE_CLOSED
			# Hide the text completely when thrown off the mat back into an envelope
			#document_text.visible = false
