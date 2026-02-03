extends Control

@onready var new_game_button = $ColorRect/CenterContainer/VBoxContainer/NewGameButton
@onready var load_game_button = $ColorRect/CenterContainer/VBoxContainer/LoadGameButton
@onready var options_button = $ColorRect/CenterContainer/VBoxContainer/OptionsButton
@onready var quit_button = $ColorRect/CenterContainer/VBoxContainer/QuitButton


func _ready():
	# Check if any save file exists to enable/disable load button
	load_game_button.disabled = !GameManager.any_save_exists()
	options_button.disabled = true  # Greyed out for now
	
	# Connect button signals
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_game_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_new_game_pressed():
	GameManager.start_new_game()


func _on_load_game_pressed():
	# For now, just load slot 1
	# TODO: Show save slot selection dialog
	GameManager.load_game(1)


func _on_options_pressed():
	# TODO: Open options menu
	pass


func _on_quit_pressed():
	GameManager.quit_game()
