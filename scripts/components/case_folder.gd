extends Control

const TEXTURE_CLOSED = preload("res://assets/sprites/folder_closed.png")
const TEXTURE_OPENED = preload("res://assets/sprites/folder_opened.png")

@onready var texture_rect: TextureRect = $TextureRect
@onready var case_label: RichTextLabel = $CaseFile

@onready var left_page_label: RichTextLabel = $LeftText
@onready var right_page_label: RichTextLabel = $RightText
@onready var page_turn_btn: TextureButton = $RghtTurnButton
@onready var page_back_btn: TextureButton = $LeftTurnButton
@onready var choice_overlay: VBoxContainer = $ChoiceOverlay

@onready var courtSummon: Button = $ChoiceOverlay/CourtSummon
@onready var paper_sound_player: AudioStreamPlayer2D = $PaperSoundPlayer

# Dynamic pages populated from GameManager JSON
var folder_pages: Array = []

const BASELINE_WIDTH: float = 80.0
const BASELINE_HEIGHT: float = 50.0
var current_spread_index: int = 0
var middle_zone: ReferenceRect
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

var is_inside_zone: bool = false

func _ready() -> void:
	if GameManager.current_case.has("case_file"):
		folder_pages = GameManager.current_case["case_file"]

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

func play_paper_sound() -> void:
	if paper_sound_player:
		paper_sound_player.pitch_scale = randf_range(0.9, 1.1)
		paper_sound_player.play()

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
			left_page_label.visible = true
			right_page_label.visible = true
			case_label.visible = false
			page_turn_btn.visible = true
	else:
		if is_inside_zone:
			play_paper_sound()
			is_inside_zone = false

		if texture_rect.texture != TEXTURE_CLOSED:
			size = Vector2(76, 50)
			rotation_degrees = randf_range(-12.0, 12.0)
			texture_rect.texture = TEXTURE_CLOSED
			left_page_label.visible = false
			right_page_label.visible = false
			case_label.visible = true
			page_turn_btn.visible = false
			page_back_btn.visible = false
			choice_overlay.visible = false
			current_spread_index = 0

func update_ledger_display() -> void:
	var left_page_idx = current_spread_index * 2
	var right_page_idx = left_page_idx + 1
	
	if left_page_idx < folder_pages.size():
		left_page_label.text = folder_pages[left_page_idx]
		left_page_label.visible = true
	else:
		left_page_label.text = ""
		
	if right_page_idx < folder_pages.size():
		right_page_label.text = folder_pages[right_page_idx]
		right_page_label.visible = true
	else:
		right_page_label.text = ""

	var next_spread_has_pages = (current_spread_index + 1) * 2 < folder_pages.size()
	if next_spread_has_pages:
		page_turn_btn.visible = true
		choice_overlay.visible = false
	else:
		page_turn_btn.visible = false
		choice_overlay.visible = true
	
	if current_spread_index > 0:
		page_back_btn.visible = true
	else:
		page_back_btn.visible = false

func _on_page_turn_pressed() -> void:
	current_spread_index += 1
	update_ledger_display()

func _on_page_back_pressed() -> void:
	current_spread_index -= 1
	update_ledger_display()

func _on_address_court() -> void:
	# Clear the old verdict flag so the game knows we are entering a fresh trial
	GameManager.last_chosen_verdict = ""
	GameManager.last_judged_case = {}

	choice_overlay.visible = false
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	var main_desk_surface = get_node("/root/Control")
	if main_desk_surface:
		main_desk_surface.visible = false
		
	await get_tree().create_timer(2.0).timeout
	
	# Transition to courtroom to try the current_case (which is now Case N+1)
	get_tree().change_scene_to_file("res://scenes/CourtRoom.tscn")
