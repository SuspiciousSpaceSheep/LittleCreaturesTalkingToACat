extends Resource
class_name InventoryItem

## Represents an inventory item that can be collected and displayed in the player's inventory.
## The item's existence is tracked via a boolean variable in the Dialogic system.

@export var variable_name: String = "" ## Dialogic variable name that tracks if this item exists (e.g., "Items.Lighter")
@export var item_icon: Texture2D ## Item icon texture (recommended 64x64 pixels)
@export var item_name: String = "" ## Display name of the item
@export_multiline var item_description: String = "" ## Item description text
