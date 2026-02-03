extends Node

# Save file paths for 3 save slots
const SAVE_SLOT_1 = "user://savegame_slot1.dat"
const SAVE_SLOT_2 = "user://savegame_slot2.dat"
const SAVE_SLOT_3 = "user://savegame_slot3.dat"

# Scene paths
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"
const GAME_SCENE = "res://Scenes/scene_1.tscn"

var current_save_slot: int = -1
var is_game_paused: bool = false

# Transition variables
var is_transitioning: bool = false


func _ready():
	# Ensure process mode allows this to run even when paused
	process_mode = Node.PROCESS_MODE_ALWAYS


func save_slot_exists(slot_number: int) -> bool:
	"""Check if a save file exists for the given slot (1, 2, or 3)"""
	var save_path = ""
	match slot_number:
		1:
			save_path = SAVE_SLOT_1
		2:
			save_path = SAVE_SLOT_2
		3:
			save_path = SAVE_SLOT_3
		_:
			return false
	
	return FileAccess.file_exists(save_path)


func any_save_exists() -> bool:
	"""Check if any save file exists"""
	return save_slot_exists(1) or save_slot_exists(2) or save_slot_exists(3)


func start_new_game():
	"""Start a new game"""
	current_save_slot = -1
	change_scene(GAME_SCENE)


func load_game(slot_number: int):
	"""Load game from specific slot (placeholder for now)"""
	if save_slot_exists(slot_number):
		current_save_slot = slot_number
		# TODO: Implement actual loading logic
		change_scene(GAME_SCENE)


func save_game(slot_number: int):
	"""Save game to specific slot (placeholder for now)"""
	# TODO: Implement actual saving logic
	current_save_slot = slot_number
	print("Game saved to slot ", slot_number)


func change_scene(scene_path: String):
	"""Change scene with fade transition"""
	if is_transitioning:
		return
	
	is_transitioning = true
	
	# Create transition overlay
	var transition = ColorRect.new()
	transition.color = Color(0, 0, 0, 0)
	transition.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.add_child(transition)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(transition, "color:a", 1.0, 0.3)
	await tween.finished
	
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	
	# Fade in
	tween = create_tween()
	tween.tween_property(transition, "color:a", 0.0, 0.3)
	await tween.finished
	
	transition.queue_free()
	is_transitioning = false


func return_to_main_menu():
	"""Return to main menu"""
	is_game_paused = false
	get_tree().paused = false
	change_scene(MAIN_MENU_SCENE)


func quit_game():
	"""Quit the game"""
	get_tree().quit()


func toggle_pause():
	"""Toggle pause state"""
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	return is_game_paused


func resume_game():
	"""Resume the game"""
	is_game_paused = false
	get_tree().paused = false
