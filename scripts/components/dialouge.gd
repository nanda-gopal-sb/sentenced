# DialogueBox.gd — attach to each dialogue Panel
extends Panel

@onready var speaker_label = $SpeakerLabel
@onready var text_label = $RichTextLabel
@onready var typewriter_audio: AudioStreamPlayer2D = $TypewriterAudio

var full_text: String = ""
var char_index: int = 0
var typing_timer: Timer

func _ready():
	typing_timer = Timer.new()
	typing_timer.wait_time = 0.05  # typing speed
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
		var current_char = full_text[char_index]
		text_label.text += current_char
		
		# Play typewriter sound for non-empty characters with slight pitch variation
		if current_char.strip_edges() != "" and typewriter_audio:
			typewriter_audio.play()
			
		char_index += 1
	else:
		typing_timer.stop()

func hide_dialogue():
	visible = false
	text_label.text = ""
