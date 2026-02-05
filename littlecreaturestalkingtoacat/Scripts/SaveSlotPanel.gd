extends PanelContainer
class_name SaveSlotPanel

## A reusable save slot UI component with thumbnail preview

signal slot_selected(slot_number: int)

@export var slot_number: int = 1

# Internal references (will be created in _ready)
var thumbnail_rect: TextureRect
var slot_label: Label
var timestamp_label: Label
var playtime_label: Label
var empty_label: Label
var select_button: Button
var delete_button: Button
var content_container: VBoxContainer

var is_empty: bool = true


func _ready() -> void:
	_create_ui()
	refresh_display()


func _create_ui() -> void:
	# Main horizontal container
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hbox)
	
	# Thumbnail section
	var thumb_container = PanelContainer.new()
	thumb_container.custom_minimum_size = Vector2(160, 90)  # 16:9 ratio
	hbox.add_child(thumb_container)
	
	thumbnail_rect = TextureRect.new()
	thumbnail_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumbnail_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	thumbnail_rect.custom_minimum_size = Vector2(160, 90)
	thumb_container.add_child(thumbnail_rect)
	
	# Empty placeholder for thumbnail
	empty_label = Label.new()
	empty_label.text = "Empty Slot"
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	thumb_container.add_child(empty_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(15, 0)
	hbox.add_child(spacer)
	
	# Info section
	content_container = VBoxContainer.new()
	content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(content_container)
	
	slot_label = Label.new()
	slot_label.add_theme_font_size_override("font_size", 20)
	content_container.add_child(slot_label)
	
	timestamp_label = Label.new()
	timestamp_label.add_theme_font_size_override("font_size", 14)
	timestamp_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	content_container.add_child(timestamp_label)
	
	playtime_label = Label.new()
	playtime_label.add_theme_font_size_override("font_size", 14)
	playtime_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	content_container.add_child(playtime_label)
	
	# Spacer to push buttons down
	var info_spacer = Control.new()
	info_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.add_child(info_spacer)
	
	# Button container
	var button_container = HBoxContainer.new()
	content_container.add_child(button_container)
	
	select_button = Button.new()
	select_button.text = "Select"
	select_button.custom_minimum_size = Vector2(80, 35)
	select_button.pressed.connect(_on_select_pressed)
	button_container.add_child(select_button)
	
	var btn_spacer = Control.new()
	btn_spacer.custom_minimum_size = Vector2(10, 0)
	button_container.add_child(btn_spacer)
	
	delete_button = Button.new()
	delete_button.text = "Delete"
	delete_button.custom_minimum_size = Vector2(80, 35)
	delete_button.pressed.connect(_on_delete_pressed)
	button_container.add_child(delete_button)


func refresh_display() -> void:
	var save_info = GameManager.get_save_slot_info(slot_number)
	
	# Display slot name - "Autosave" for slot 0, "Slot X" for others
	if slot_number == 0:
		slot_label.text = "Autosave"
	else:
		slot_label.text = "Slot %d" % slot_number
	
	if save_info.is_empty():
		is_empty = true
		empty_label.show()
		thumbnail_rect.texture = null
		timestamp_label.text = ""
		playtime_label.text = ""
		delete_button.disabled = true
	else:
		is_empty = false
		empty_label.hide()
		
		# Load thumbnail
		var thumb_path = save_info.get("thumbnail", "")
		if thumb_path != "" and FileAccess.file_exists(thumb_path):
			var image = Image.load_from_file(thumb_path)
			if image:
				thumbnail_rect.texture = ImageTexture.create_from_image(image)
		
		# Display timestamp
		var timestamp = save_info.get("timestamp", "Unknown")
		timestamp_label.text = timestamp
		
		# Display playtime
		var playtime_sec = save_info.get("playtime_seconds", 0)
		playtime_label.text = "Playtime: " + _format_playtime(playtime_sec)
		
		delete_button.disabled = false


func set_mode(is_save_mode: bool) -> void:
	if is_save_mode:
		select_button.text = "Save"
		# Hide delete button in save mode (we're about to overwrite anyway)
		delete_button.hide()
	else:
		select_button.text = "Load"
		# In load mode, disable button if slot is empty
		select_button.disabled = is_empty
		# Show delete button but hide for autosave slot
		if slot_number == 0:
			delete_button.hide()
		else:
			delete_button.show()


func _format_playtime(seconds: int) -> String:
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60
	
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, secs]
	else:
		return "%d:%02d" % [minutes, secs]


func _on_select_pressed() -> void:
	slot_selected.emit(slot_number)


func _on_delete_pressed() -> void:
	# Don't allow deleting autosave slot
	if slot_number == 0:
		return
	GameManager.delete_save(slot_number)
	refresh_display()
