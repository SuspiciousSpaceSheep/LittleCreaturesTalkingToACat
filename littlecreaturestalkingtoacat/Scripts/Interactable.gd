extends Node3D
class_name Interactable

@export_group("Dialogue Settings")
@export var first_time_dialogue_id: String = ""
@export var default_dialogue_id: String = ""
@export var priority_list: Dictionary[String, String] = {}
@export var has_interacted_var: String = ""  # Dialogic variable name to track first interaction (must be created in Dialogic)

@export_group("Camera Settings")
#dialoge camera settings
@export var camera_distance: float = 0.8
@export var camera_height: float = 0.3

@export_group("Outline Settings")
# Outline shader settings
@export var outline_color: Color = Color(0.0, 1.0, 0.0, 1.0)
@export var outline_width: float = 1.0

var outline_materials: Array[ShaderMaterial] = []
var is_mouse_over: bool = false


func _ready() -> void:
	# Connect to Dialogic's timeline ended signal
	Dialogic.timeline_ended.connect(_on_dialogue_ended)
	
	# Find all mesh instances and collect their outline materials
	_collect_outline_materials(self)
	
	# Initialize outline as hidden
	_set_outline_visibility(false)


func _collect_outline_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh = node as MeshInstance3D
		var material = mesh.get_active_material(0)
		if material and material.next_pass and material.next_pass is ShaderMaterial:
			var outline_mat = material.next_pass as ShaderMaterial
			outline_materials.append(outline_mat)
	
	for child in node.get_children():
		_collect_outline_materials(child)


func _set_outline_visibility(show_outline: bool) -> void:
	for outline_mat in outline_materials:
		if outline_mat:
			var alpha = 1.0 if show_outline else 0.0
			outline_mat.set_shader_parameter("outline_color", Color(outline_color.r, outline_color.g, outline_color.b, alpha))
			outline_mat.set_shader_parameter("outline_width", outline_width)


func _get_dialogue_id() -> String:
	# First time interaction
	if has_interacted_var != "" and not Dialogic.VAR.get_variable(has_interacted_var, false) and first_time_dialogue_id != "":
		return first_time_dialogue_id
	
	# Check priority list for set variables
	for var_name in priority_list.keys():
		if Dialogic.VAR.get_variable(var_name, false):
			return priority_list[var_name]

	# Default dialogue
	return default_dialogue_id


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Capture screenshot BEFORE starting dialogue (for clean save thumbnails)
			GameManager.capture_screenshot_now()
			
			# Focus secondary camera: distance=2.0, height=1.5
			SecondaryCameraController.focus_on_target(self, camera_distance, camera_height)
			
			# Get the appropriate dialogue ID based on interaction history and variables
			var dialogue_to_play = _get_dialogue_id()
			
			# Mark as interacted in Dialogic system after getting the ID (so first_time works correctly)
			if has_interacted_var != "":
				Dialogic.VAR.set_variable(has_interacted_var, true)
			
			# Start dialogue
			Dialogic.start(dialogue_to_play)


func _on_area_3d_mouse_entered() -> void:
	is_mouse_over = true
	_set_outline_visibility(true)


func _on_area_3d_mouse_exited() -> void:
	is_mouse_over = false
	_set_outline_visibility(false)


# Release camera focus when dialogue ends
func _on_dialogue_ended() -> void:
	SecondaryCameraController.release_focus(false)
			
