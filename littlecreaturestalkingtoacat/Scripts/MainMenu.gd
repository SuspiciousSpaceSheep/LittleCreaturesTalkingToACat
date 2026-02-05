extends Control

@onready var continue_button = $ColorRect/CenterContainer/VBoxContainer/ContinueButton
@onready var new_game_button = $ColorRect/CenterContainer/VBoxContainer/NewGameButton
@onready var load_game_button = $ColorRect/CenterContainer/VBoxContainer/LoadGameButton
@onready var options_button = $ColorRect/CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button = $ColorRect/CenterContainer/VBoxContainer/QuitButton
@onready var save_load_menu: SaveLoadMenu = $SaveLoadMenu


func _ready():
	# Check if any save file exists to enable/disable buttons
	var has_saves = GameManager.any_save_exists()
	var latest_slot = GameManager.get_latest_save_slot()
	
	continue_button.disabled = latest_slot < 0
	load_game_button.disabled = !has_saves
	options_button.disabled = true  # Greyed out for now
	
	# Connect button signals
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Connect save/load menu signals
	save_load_menu.menu_closed.connect(_on_save_load_menu_closed)


func _on_continue_pressed():
	var latest_slot = GameManager.get_latest_save_slot()
	if latest_slot >= 0:
		GameManager.load_game(latest_slot)


func _on_new_game_pressed():
	GameManager.start_new_game()


func _on_load_game_pressed():
	# Show load menu
	save_load_menu.show_menu(SaveLoadMenu.Mode.LOAD)


func _on_save_load_menu_closed():
	# Refresh button states in case saves were deleted
	var has_saves = GameManager.any_save_exists()
	var latest_slot = GameManager.get_latest_save_slot()
	continue_button.disabled = latest_slot < 0
	load_game_button.disabled = !has_saves


func _on_options_pressed():
	# TODO: Open options menu
	pass


func _on_quit_pressed():
	GameManager.quit_game()
