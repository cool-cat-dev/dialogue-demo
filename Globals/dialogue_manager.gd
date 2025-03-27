extends Node

# Path to the DialogueBox scene
@export var dialogue_box_scene: PackedScene = preload("res://Scenes/dialogue_box.tscn")

# Track the active dialogue box and dialogue queue
var active_dialogue_box: Node = null
var dialogue_queue: Array = []  # Stores pending dialogues as dictionaries with text and callback

# Start the dialogue by spawning a new DialogueBox instance or adding it to the queue
func start_dialogue(text: String, on_complete: Callable = Callable()):
	# If a dialogue box is already active, add the dialogue to the queue
	if active_dialogue_box != null:
		dialogue_queue.append({"text": text, "on_complete": on_complete})
		return

	# Create a new dialogue box instance and mark it as active
	active_dialogue_box = dialogue_box_scene.instantiate()
	add_child(active_dialogue_box)

	# Initialize the dialogue box with the text and completion callback
	active_dialogue_box.start_dialogue(text, Callable(self, "_on_dialogue_complete").bind(on_complete))

# Handle completion of the dialogue
func _on_dialogue_complete(on_complete: Callable):
	# Call the provided callback if it's valid
	if on_complete.is_valid():
		on_complete.call()

	# Clear the active dialogue box reference
	active_dialogue_box = null

	# Check if there are any dialogues in the queue
	if dialogue_queue.size() > 0:
		var next_dialogue = dialogue_queue.pop_front()
		# Start the next dialogue from the queue
		start_dialogue(next_dialogue["text"], next_dialogue["on_complete"])
