extends Control
class_name InventoryHUD

## Displays collected inventory items on the HUD based on Dialogic variables

@export var inventory_items: Array[InventoryItem] = [] ## List of all possible inventory items
@export var icon_size: Vector2 = Vector2(64, 64) ## Size of each inventory icon
@export var spacing: int = 8 ## Spacing between icons

@onready var items_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var tooltip_panel: PanelContainer = $TooltipPanel
@onready var tooltip_name: Label = $TooltipPanel/MarginContainer/VBoxContainer/ItemName
@onready var tooltip_description: Label = $TooltipPanel/MarginContainer/VBoxContainer/ItemDescription

var item_buttons: Dictionary = {} # Maps InventoryItem -> TextureButton


func _ready() -> void:
	# Connect to Dialogic signals
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
	# Hide tooltip initially
	tooltip_panel.hide()
	
	# Initial update
	_update_inventory_display()


func _update_inventory_display() -> void:
	# Clear existing buttons
	for child in items_container.get_children():
		child.queue_free()
	item_buttons.clear()
	
	# Create buttons for items that exist
	for item in inventory_items:
		if item and item.variable_name != "":
			var item_exists = Dialogic.VAR.get_variable(item.variable_name, false)
			if item_exists:
				_create_item_button(item)


func _create_item_button(item: InventoryItem) -> void:
	var button = TextureButton.new()
	button.texture_normal = item.item_icon
	button.custom_minimum_size = icon_size
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.ignore_texture_size = true
	
	# Connect hover signals
	button.mouse_entered.connect(_on_item_mouse_entered.bind(item))
	button.mouse_exited.connect(_on_item_mouse_exited)
	
	items_container.add_child(button)
	item_buttons[item] = button


func _on_item_mouse_entered(item: InventoryItem) -> void:
	if not tooltip_name or not tooltip_description or not tooltip_panel:
		return
	
	tooltip_name.text = item.item_name
	tooltip_description.text = item.item_description
	tooltip_panel.show()
	
	# Position tooltip to the left of the inventory
	var tooltip_pos = get_global_mouse_position()
	tooltip_pos.x -= tooltip_panel.size.x + 10
	tooltip_panel.global_position = tooltip_pos


func _on_item_mouse_exited() -> void:
	if not tooltip_panel:
		return
	tooltip_panel.hide()


func _process(_delta: float) -> void:
	# Update tooltip position while hovering
	if tooltip_panel.visible:
		var tooltip_pos = get_global_mouse_position()
		tooltip_pos.x -= tooltip_panel.size.x + 10
		tooltip_panel.global_position = tooltip_pos


func _on_dialogic_signal(_argument: String) -> void:
	_update_inventory_display()


func _on_timeline_ended() -> void:
	_update_inventory_display()
