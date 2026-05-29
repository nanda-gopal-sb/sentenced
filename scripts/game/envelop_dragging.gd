extends Control

# Track the dragging state
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Connect Godot's built-in UI input signal to our function
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	# 1. Detect Left Mouse Click Down (Pick up item)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			# Calculate exact click offset so the envelope doesn't awkwardly jump/snap
			drag_offset = get_global_mouse_position() - global_position
			
			# Visual feedback: push it to the end of the drawing stack so it sits on top
			get_parent().move_child(self, -1)
		else:
			# 2. Detect Mouse Release (Drop item)
			is_dragging = false

	# 3. Handle Active Mouse Dragging
	if event is InputEventMouseMotion and is_dragging:
		# Update position dynamically relative to your mouse and original offset
		global_position = get_global_mouse_position() - drag_offset