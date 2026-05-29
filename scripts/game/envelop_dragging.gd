extends Control

const TEXTURE_CLOSED = preload("res://assets/sprites/letter.png") # Update with your paths
const TEXTURE_OPENED = preload("res://assets/sprites/paper.png")

@onready var texture_rect: TextureRect = $TextureRect
var middle_zone: ReferenceRect

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	
	# 1. Get the parent (DeskSurface)
	var desk_surface = get_parent()
	
	if desk_surface:
		# 2. Get the node relative to DeskSurface using your exact tree layout
		middle_zone = desk_surface.get_node_or_null("LayoutGuild/MiddleZone")
	
	# 3. Debug Fallback: If it's still null, print a clear warning to the console
	if middle_zone == null:
		print_warning_missing_node()

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
	var my_rect = Rect2(global_position, size)
	var zone_rect = Rect2(middle_zone.global_position, middle_zone.size)
	
	if my_rect.intersects(zone_rect):
		if texture_rect.texture != TEXTURE_OPENED:
			texture_rect.texture = TEXTURE_OPENED
	else:
		if texture_rect.texture != TEXTURE_CLOSED:
			texture_rect.texture = TEXTURE_CLOSED

# Helper function to give you meaningful errors if paths change later
func print_warning_missing_node() -> void:
	print_rich("[color=red][b]ERROR:[/b][/color] EnvelopeItem could not find MiddleZone!")
