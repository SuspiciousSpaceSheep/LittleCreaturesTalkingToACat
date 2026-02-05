extends CanvasLayer

@onready var resume_button = $PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var save_game_button = $PanelContainer/MarginContainer/VBoxContainer/SaveGameButton
@onready var load_game_button = $PanelContainer/MarginContainer/VBoxContainer/LoadGameButton
@onready var options_button = $PanelContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var main_menu_button = $PanelContainer/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $PanelContainer/MarginContainer/VBoxContainer/QuitButton
@onready var save_load_menu: SaveLoadMenu = $SaveLoadMenu


func _ready():
	# Initially hide the pause menu
	hide()
	
	# Set process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	save_game_button.pressed.connect(_on_save_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect save/load menu signals
	save_load_menu.menu_closed.connect(_on_save_load_menu_closed)
	save_load_menu.load_completed.connect(_on_load_completed)


func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		# Don't toggle pause if save/load menu is open
		if save_load_menu.is_visible_menu:
			return
		toggle_pause()


func toggle_pause():
	# Don't allow pause menu if Dialogic is active
	if Dialogic.Styles.has_active_layout_node():
		return
	
	if visible:
		hide_pause_menu()
	else:
		show_pause_menu()


func show_pause_menu():
	# Capture screenshot BEFORE showing the menu (for clean save thumbnails)
	GameManager.capture_screenshot_now()
	
	# Update load button state
	load_game_button.disabled = !GameManager.any_save_exists()
	
	show()
	GameManager.toggle_pause()


func hide_pause_menu():
	hide()
	GameManager.resume_game()


func _on_resume_pressed():
	hide_pause_menu()


func _on_save_game_pressed():
	# Show save menu
	save_load_menu.show_menu(SaveLoadMenu.Mode.SAVE)


func _on_load_game_pressed():
	# Show load menu
	save_load_menu.show_menu(SaveLoadMenu.Mode.LOAD)


func _on_save_load_menu_closed():
	# Refresh load button state
	load_game_button.disabled = !GameManager.any_save_exists()


func _on_load_completed(_slot: int):
	# Hide pause menu when a game is loaded
	hide()


func _on_options_pressed():
	# TODO: Open options menu
	pass


func _on_main_menu_pressed():
	hide()
	GameManager.return_to_main_menu()


func _on_quit_pressed():
	GameManager.quit_game()
