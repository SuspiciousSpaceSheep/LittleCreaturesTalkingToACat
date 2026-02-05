extends Node

## Game Manager - Handles saving, loading, scene transitions, and global game state

# Save directory and file paths
const SAVE_DIR = "user://saves/"
const SAVE_METADATA_FILE = "save_metadata.json"
const AUTOSAVE_SLOT = 0  # Dedicated autosave slot

# Scene paths
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"
const GAME_SCENE = "res://Scenes/scene_1.tscn"

# Current state
var current_save_slot: int = -1
var is_game_paused: bool = false
var is_transitioning: bool = false

# Playtime tracking
var session_start_time: int = 0  # Time.get_ticks_msec() when game started/loaded
var loaded_playtime_seconds: int = 0  # Playtime from loaded save

# Screenshot for save
var pending_screenshot: Image = null

# Auto-save state
var auto_save_enabled: bool = true
var _last_scene_path: String = ""

# Camera state to restore after load
var _pending_camera_progress: float = -1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_save_directory_exists()
	
	# Connect to Dialogic signals for auto-save
	if Dialogic:
		Dialogic.timeline_ended.connect(_on_dialogue_ended)
	
	# Connect to scene changes
	get_tree().tree_changed.connect(_on_tree_changed)


func _ensure_save_directory_exists() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _get_save_path(slot_number: int) -> String:
	return SAVE_DIR + "slot_%d/" % slot_number


func _get_metadata_path(slot_number: int) -> String:
	return _get_save_path(slot_number) + SAVE_METADATA_FILE


func _get_thumbnail_path(slot_number: int) -> String:
	return _get_save_path(slot_number) + "thumbnail.png"


func save_slot_exists(slot_number: int) -> bool:
	"""Check if a save file exists for the given slot (0=autosave, 1-3=manual)"""
	return FileAccess.file_exists(_get_metadata_path(slot_number))


func any_save_exists() -> bool:
	"""Check if any save file exists (including autosave)"""
	return save_slot_exists(0) or save_slot_exists(1) or save_slot_exists(2) or save_slot_exists(3)


func get_latest_save_slot() -> int:
	"""Get the slot number of the most recent save, or -1 if none exists"""
	var latest_slot = -1
	var latest_timestamp = ""
	
	for slot in [0, 1, 2, 3]:
		if save_slot_exists(slot):
			var info = get_save_slot_info(slot)
			var timestamp = info.get("timestamp", "")
			if timestamp > latest_timestamp:
				latest_timestamp = timestamp
				latest_slot = slot
	
	return latest_slot


func get_save_slot_info(slot_number: int) -> Dictionary:
	"""Get metadata info for a save slot"""
	var metadata_path = _get_metadata_path(slot_number)
	if not FileAccess.file_exists(metadata_path):
		return {}
	
	var file = FileAccess.open(metadata_path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return {}
	
	var data = json.data
	if data is Dictionary:
		return data
	return {}


func get_total_playtime_seconds() -> int:
	"""Get total playtime including current session"""
	var current_session_ms = Time.get_ticks_msec() - session_start_time
	var current_session_seconds = current_session_ms / 1000
	return loaded_playtime_seconds + current_session_seconds


func capture_screenshot_now() -> void:
	"""Capture current screen proactively for later use in saves.
	Call this BEFORE opening menus or starting dialogue."""
	var viewport = get_viewport()
	if viewport:
		# Get current frame
		var image = viewport.get_texture().get_image()
		if image:
			# Resize for thumbnail (16:9, 320x180)
			image.resize(320, 180, Image.INTERPOLATE_LANCZOS)
			pending_screenshot = image
			print("[GameManager] Screenshot captured")


func _get_camera_progress() -> float:
	"""Get the current camera path progress"""
	var tree = get_tree()
	if not tree or not tree.current_scene:
		return 0.0
	
	# Find PathFollow3D in the scene
	var path_follow = _find_path_follow(tree.current_scene)
	if path_follow:
		return path_follow.progress
	return 0.0


func _find_path_follow(node: Node) -> PathFollow3D:
	"""Recursively find PathFollow3D in the scene tree"""
	if node is PathFollow3D:
		return node
	for child in node.get_children():
		var result = _find_path_follow(child)
		if result:
			return result
	return null


func _restore_camera_progress() -> void:
	"""Restore camera position after scene load"""
	if _pending_camera_progress < 0:
		return
	
	var progress_to_restore = _pending_camera_progress
	_pending_camera_progress = -1.0  # Clear immediately to prevent multiple calls
	
	var tree = get_tree()
	if not tree or not tree.current_scene:
		print("[GameManager] Cannot restore camera - no current scene")
		return
	
	var path_follow = _find_path_follow(tree.current_scene)
	if path_follow:
		path_follow.progress = progress_to_restore
		print("[GameManager] Restored camera progress: %f" % progress_to_restore)
	else:
		print("[GameManager] Cannot restore camera - PathFollow3D not found")


func start_new_game() -> void:
	"""Start a new game"""
	current_save_slot = -1
	loaded_playtime_seconds = 0
	session_start_time = Time.get_ticks_msec()
	
	# Clear Dialogic state for new game
	Dialogic.clear()
	
	change_scene(GAME_SCENE)


func load_game(slot_number: int) -> void:
	"""Load game from specific slot"""
	if not save_slot_exists(slot_number):
		push_error("Save slot %d does not exist" % slot_number)
		return
	
	# Ensure game is not paused when loading
	is_game_paused = false
	get_tree().paused = false
	
	current_save_slot = slot_number
	
	# Load our metadata
	var metadata = get_save_slot_info(slot_number)
	loaded_playtime_seconds = metadata.get("playtime_seconds", 0)
	session_start_time = Time.get_ticks_msec()
	
	var scene_to_load = metadata.get("current_scene", GAME_SCENE)
	
	# Store camera progress to restore after scene loads
	_pending_camera_progress = metadata.get("camera_progress", -1.0)
	
	# Load Dialogic state
	var dialogic_slot = "game_slot_%d" % slot_number
	Dialogic.Save.load(dialogic_slot)
	
	# Change to the saved scene
	change_scene(scene_to_load)
	
	print("[GameManager] Loaded game from slot %d" % slot_number)


func save_game(slot_number: int, is_autosave: bool = false) -> void:
	"""Save game to specific slot"""
	# Don't update current_save_slot for autosaves (keep manual slot)
	if not is_autosave:
		current_save_slot = slot_number
	
	var slot_dir = _get_save_path(slot_number)
	
	# Ensure slot directory exists
	if not DirAccess.dir_exists_absolute(slot_dir):
		DirAccess.make_dir_recursive_absolute(slot_dir)
	
	# Save Dialogic state
	var dialogic_slot = "game_slot_%d" % slot_number
	Dialogic.Save.save(dialogic_slot)
	
	# Get current scene path
	var current_scene = get_tree().current_scene
	var scene_path = GAME_SCENE
	if current_scene and current_scene.scene_file_path:
		scene_path = current_scene.scene_file_path
	
	# Create metadata
	var metadata = {
		"slot": slot_number,
		"timestamp": _get_formatted_timestamp(),
		"playtime_seconds": get_total_playtime_seconds(),
		"current_scene": scene_path,
		"dialogic_slot": dialogic_slot,
		"thumbnail": _get_thumbnail_path(slot_number),
		"camera_progress": _get_camera_progress(),
		"is_autosave": is_autosave
	}
	
	# Save metadata
	var file = FileAccess.open(_get_metadata_path(slot_number), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(metadata, "\t"))
		file.close()
	
	# Save thumbnail
	if pending_screenshot:
		pending_screenshot.save_png(_get_thumbnail_path(slot_number))
		pending_screenshot = null
	
	print("[GameManager] Game saved to slot %d" % slot_number)


func delete_save(slot_number: int) -> void:
	"""Delete a save slot"""
	var slot_dir = _get_save_path(slot_number)
	
	if DirAccess.dir_exists_absolute(slot_dir):
		var dir = DirAccess.open(slot_dir)
		if dir:
			# Delete all files in the directory
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					dir.remove(file_name)
				file_name = dir.get_next()
			dir.list_dir_end()
			
			# Remove the directory
			DirAccess.remove_absolute(slot_dir)
	
	# Also delete Dialogic save
	var dialogic_slot = "game_slot_%d" % slot_number
	if Dialogic.Save.has_slot(dialogic_slot):
		Dialogic.Save.delete_slot(dialogic_slot)
	
	print("[GameManager] Deleted save slot %d" % slot_number)


func _get_formatted_timestamp() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d %02d:%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute
	]


## Auto-save triggers

func _on_dialogue_ended() -> void:
	"""Auto-save when a dialogue ends"""
	if auto_save_enabled:
		_perform_auto_save()


func _on_tree_changed() -> void:
	"""Check for scene changes, auto-save, and restore camera"""
	if not is_inside_tree():
		return
	var tree = get_tree()
	if not tree:
		return
	var current_scene = tree.current_scene
	if current_scene:
		var scene_path = current_scene.scene_file_path
		
		# Note: Camera restoration is now handled in change_scene() after scene loads
		
		if scene_path != _last_scene_path and _last_scene_path != "" and scene_path != MAIN_MENU_SCENE:
			if auto_save_enabled:
				_perform_auto_save()
		_last_scene_path = scene_path


func _perform_auto_save() -> void:
	"""Perform an auto-save to the autosave slot"""
	if not is_transitioning and _last_scene_path != MAIN_MENU_SCENE:
		# Use the latest captured screenshot (should be captured before dialogue/menu)
		save_game(AUTOSAVE_SLOT, true)
		print("[GameManager] Auto-saved to autosave slot")


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
	
	# Wait a frame for scene to be fully loaded
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Restore camera position if we have pending data
	if _pending_camera_progress >= 0:
		_restore_camera_progress()
	
	# Fade in
	tween = create_tween()
	tween.tween_property(transition, "color:a", 0.0, 0.3)
	await tween.finished
	
	transition.queue_free()
	is_transitioning = false


func return_to_main_menu():
	"""Return to main menu - auto-saves first if in a game"""
	if auto_save_enabled and _last_scene_path != MAIN_MENU_SCENE:
		# Screenshot should already be captured before menu opened
		save_game(AUTOSAVE_SLOT, true)
	
	is_game_paused = false
	get_tree().paused = false
	change_scene(MAIN_MENU_SCENE)


func quit_game():
	"""Quit the game - auto-saves first if in a game"""
	if auto_save_enabled and _last_scene_path != MAIN_MENU_SCENE:
		# Screenshot should already be captured before menu opened
		save_game(AUTOSAVE_SLOT, true)
	
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
