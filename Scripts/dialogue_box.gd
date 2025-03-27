extends CanvasLayer

@onready var dialogue_label = $DialogueBox/Label
@onready var sound_player = $AudioStreamPlayer
@onready var proceed_button = $DialogueBox/Label/EndCursor

@export var character_delay: float = 0.02
@export var sound_per_character: String = "res://Assets/voice.ogg"

var dialogue_text = ""
var current_char_index = 0
var is_displaying = false
var on_complete_callback: Callable = Callable()

func _ready():
	# Connect the button pressed signal to the function
	#proceed_button.connect("pressed", Callable(self, "_on_button_pressed"))
	set_process_input(true)

func start_dialogue(text: String, on_complete: Callable = Callable()):
	dialogue_text = text
	current_char_index = 0
	is_displaying = true
	on_complete_callback = on_complete if on_complete.is_valid() else Callable()
	dialogue_label.text = ""
	proceed_button.visible = false
	_animate_entrance()

func _animate_entrance():
	_start_display()

func _start_display():
	if current_char_index < dialogue_text.length():
		var char = dialogue_text[current_char_index]
		dialogue_label.text += char
		current_char_index += 1
		_play_character_sound()
		await get_tree().create_timer(character_delay).timeout
		_start_display()
	else:
		is_displaying = false
		proceed_button.visible = true

func _play_character_sound():
	if sound_per_character != "":
		sound_player.stream = load(sound_per_character)
		sound_player.play()

func _on_button_pressed():
	proceed_button.visible = false
	_animate_exit()

func _animate_exit():
	if on_complete_callback.is_valid():
		on_complete_callback.call()
	queue_free()

func _input(event: InputEvent):
	# Detect if the Enter key is pressed and the button is visible
	if event.is_action_pressed("ui_accept") and proceed_button.visible:
		_on_button_pressed()
	# Detect any mouse button press and the button is visible
	elif event is InputEventMouseButton and event.pressed and proceed_button.visible:
		_on_button_pressed()

