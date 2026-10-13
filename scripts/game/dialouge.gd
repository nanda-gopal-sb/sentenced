# DialogueBox.gd — attach to each dialogue Panel
extends Panel

@onready var speaker_label = $SpeakerLabel
@onready var text_label = $RichTextLabel

var full_text: String = ""
var char_index: int = 0
var typing_timer: Timer

func _ready():
	typing_timer = Timer.new()
	typing_timer.wait_time = 0.03  # typing speed
	typing_timer.timeout.connect(_type_next_char)
	add_child(typing_timer)

func show_dialogue(speaker: String, text: String):
	speaker_label.text = speaker
	full_text = text
	text_label.text = ""
	char_index = 0
	visible = true
	typing_timer.start()

func _type_next_char():
	if char_index < full_text.length():
		text_label.text += full_text[char_index]
		char_index += 1
	else:
		typing_timer.stop()

func hide_dialogue():
	visible = false
	text_label.text = ""
