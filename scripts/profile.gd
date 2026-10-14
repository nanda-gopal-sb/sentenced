# ProfileCard.gd
extends Control

const TEXTURE_CLOSED = preload("res://assets/sprites/folder_closed.png")
const TEXTURE_OPENED = preload("res://assets/sprites/folder_opened.png")

@onready var texture_rect: TextureRect = $TextureRect
@onready var card_label: RichTextLabel = $CaseFile
@onready var profile_text: RichTextLabel = $RightText
@onready var paper_sound_player: AudioStreamPlayer2D = $PaperSoundPlayer

const BASELINE_WIDTH: float = 80.0
const BASELINE_HEIGHT: float = 50.0

var middle_zone: ReferenceRect
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var is_inside_zone: bool = false

# Player profile variables
var player_name: String = "Hon. Judge" # Can be updated from Start Menu / GameManager

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	profile_text.visible = false
	card_label.visible = true
	
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

func play_paper_sound() -> void:
	if paper_sound_player:
		paper_sound_player.pitch_scale = randf_range(0.9, 1.1)
		paper_sound_player.play()

func format_profile_data() -> String:
	var current_pts = GameManager.total_score
	var current_lvl = GameManager.current_level
	var thresholds = GameManager.LEVEL_THRESHOLDS
	
	var next_level_str: String = ""
	
	if current_lvl < thresholds.size():
		var pts_needed = thresholds[current_lvl] - current_pts
		next_level_str = str(max(0, pts_needed)) + " pts"
	else:
		next_level_str = "MAX LEVEL REACHED"
		
	var info = "[b]JUDICIAL CREDENTIALS[/b]\n\n"
	info += "Name: " + player_name + "\n\n"
	info += "Rank/Level: Tier " + str(current_lvl) + "\n\n"
	info += "Total Points: " + str(current_pts) + "\n\n"
	info += "Next Promotion: " + next_level_str
	
	return info

func check_zone_collision() -> void:
	var stable_size = Vector2(BASELINE_WIDTH, BASELINE_HEIGHT)
	var my_rect = Rect2(global_position, stable_size)
	var zone_rect = Rect2(middle_zone.global_position, middle_zone.size)
	
	var intersection_rect = my_rect.intersection(zone_rect)
	var my_area = my_rect.get_area()
	var overlap_area = intersection_rect.get_area()
	
	if overlap_area >= (my_area * 0.5):
		if not is_inside_zone:
			play_paper_sound()
			is_inside_zone = true

		if texture_rect.texture != TEXTURE_OPENED:
			size = Vector2(90, 110)
			rotation_degrees = 0.0
			texture_rect.texture = TEXTURE_OPENED
			profile_text.text = format_profile_data()
			profile_text.visible = true
			card_label.visible = false
	else:
		if is_inside_zone:
			play_paper_sound()
			is_inside_zone = false

		if texture_rect.texture != TEXTURE_CLOSED:
			size = Vector2(76, 50)
			rotation_degrees = randf_range(-12.0, 12.0)
			texture_rect.texture = TEXTURE_CLOSED
			profile_text.visible = false
			card_label.visible = true
