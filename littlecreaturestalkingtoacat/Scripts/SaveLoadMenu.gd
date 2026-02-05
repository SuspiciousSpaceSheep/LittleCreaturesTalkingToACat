extends CanvasLayer
class_name SaveLoadMenu

## Side panel save/load menu with autosave + 3 manual slots

signal menu_closed
signal save_completed(slot: int)
signal load_completed(slot: int)

enum Mode { SAVE, LOAD }

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var slots_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/SlotsContainer
@onready var close_button: Button = $Panel/MarginContainer/VBoxContainer/CloseButton
@onready var background_dim: ColorRect = $BackgroundDim

var current_mode: Mode = Mode.LOAD
var slot_panels: Array[SaveSlotPanel] = []
var autosave_panel: SaveSlotPanel = null
var is_visible_menu: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create autosave slot panel (slot 0)
	autosave_panel = SaveSlotPanel.new()
	autosave_panel.slot_number = 0
	autosave_panel.custom_minimum_size = Vector2(0, 120)
	autosave_panel.slot_selected.connect(_on_slot_selected)
	slots_container.add_child(autosave_panel)
	slot_panels.append(autosave_panel)
	
	# Add separator after autosave
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 10)
	slots_container.add_child(separator)
	
	# Create manual save slot panels (slots 1-3)
	for i in range(1, 4):
		var slot_panel = SaveSlotPanel.new()
		slot_panel.slot_number = i
		slot_panel.custom_minimum_size = Vector2(0, 120)
		slot_panel.slot_selected.connect(_on_slot_selected)
		slots_container.add_child(slot_panel)
		slot_panels.append(slot_panel)
	
	close_button.pressed.connect(_on_close_pressed)
	background_dim.gui_input.connect(_on_background_input)
	
	# Initially hidden
	hide_menu()


func show_menu(mode: Mode) -> void:
	current_mode = mode
	
	# Update title
	if mode == Mode.SAVE:
		title_label.text = "Save Game"
		# Hide autosave slot when saving (can't manually save to autosave)
		autosave_panel.hide()
	else:
		title_label.text = "Load Game"
		# Show autosave slot when loading
		autosave_panel.show()
	
	# Update slot panels
	for slot_panel in slot_panels:
		slot_panel.refresh_display()
		slot_panel.set_mode(mode == Mode.SAVE)
	
	# Show with slide animation
	is_visible_menu = true
	show()
	background_dim.modulate.a = 0
	panel.position.x = panel.size.x  # Start off-screen to the right
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background_dim, "modulate:a", 1.0, 0.2)
	tween.tween_property(panel, "position:x", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func hide_menu() -> void:
	if not is_visible_menu:
		hide()
		return
	
	is_visible_menu = false
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(background_dim, "modulate:a", 0.0, 0.2)
	tween.tween_property(panel, "position:x", panel.size.x, 0.25).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	hide()
	menu_closed.emit()


func _on_slot_selected(slot_number: int) -> void:
	if current_mode == Mode.SAVE:
		# Screenshot was already captured when pause menu was opened
		# Just do the save directly
		GameManager.save_game(slot_number)
		
		# Refresh the display after saving
		for slot_panel in slot_panels:
			slot_panel.refresh_display()
		
		save_completed.emit(slot_number)
	else:
		# Load mode
		if GameManager.save_slot_exists(slot_number):
			hide_menu()
			await get_tree().process_frame
			GameManager.load_game(slot_number)
			load_completed.emit(slot_number)


func _on_close_pressed() -> void:
	hide_menu()


func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			hide_menu()


func _input(event: InputEvent) -> void:
	if is_visible_menu and event.is_action_pressed("ui_cancel"):
		hide_menu()
		get_viewport().set_input_as_handled()
