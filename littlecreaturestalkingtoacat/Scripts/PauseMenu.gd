extends CanvasLayer

@onready var resume_button = $PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var save_game_button = $PanelContainer/MarginContainer/VBoxContainer/SaveGameButton
@onready var options_button = $PanelContainer/MarginContainer/VBoxContainer/OptionsButton
@onready var main_menu_button = $PanelContainer/MarginContainer/VBoxContainer/MainMenuButton
@onready var quit_button = $PanelContainer/MarginContainer/VBoxContainer/QuitButton


func _ready():
	# Initially hide the pause menu
	hide()
	
	# Set process mode to always so it works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	save_game_button.pressed.connect(_on_save_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
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
	show()
	GameManager.toggle_pause()


func hide_pause_menu():
	hide()
	GameManager.resume_game()


func _on_resume_pressed():
	hide_pause_menu()


func _on_save_game_pressed():
	# TODO: Show save slot selection dialog
	# For now, save to slot 1
	GameManager.save_game(1)


func _on_options_pressed():
	# TODO: Open options menu
	pass


func _on_main_menu_pressed():
	hide()
	GameManager.return_to_main_menu()


func _on_quit_pressed():
	GameManager.quit_game()
