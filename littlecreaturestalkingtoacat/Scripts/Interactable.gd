extends Node3D
class_name Interactable


@export var first_time_dialogue_id: String = ""
@export var default_dialogue_id: String = ""
@export var priority_list: Dictionary[String, String] = {}
@export var has_interacted_var: String = ""  # Dialogic variable name to track first interaction (must be created in Dialogic)

#dialoge camera settings
@export var camera_distance: float = 0.8
@export var camera_height: float = 0.3


func _ready() -> void:
	# Connect to Dialogic's timeline ended signal
	Dialogic.timeline_ended.connect(_on_dialogue_ended)


func _get_dialogue_id() -> String:
	# First time interaction
	if has_interacted_var != "" and not Dialogic.VAR.get_variable(has_interacted_var, false) and first_time_dialogue_id != "":
		return first_time_dialogue_id
	
	# Check priority list for set variables
	for var_name in priority_list.keys():
		var var_value = Dialogic.VAR.get_variable(var_name, false)
		print("Checking variable: ", var_name, " = ", var_value)
		if var_value:
			print("Using dialogue: ", priority_list[var_name])
			return priority_list[var_name]

	# Default dialogue
	return default_dialogue_id


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Focus secondary camera: distance=2.0, height=1.5
			SecondaryCameraController.focus_on_target(self, camera_distance, camera_height)
			
			# Get the appropriate dialogue ID based on interaction history and variables
			var dialogue_to_play = _get_dialogue_id()
			
			# Mark as interacted in Dialogic system after getting the ID (so first_time works correctly)
			if has_interacted_var != "":
				Dialogic.VAR.set_variable(has_interacted_var, true)
			
			# Start dialogue
			Dialogic.start(dialogue_to_play)


# Release camera focus when dialogue ends
func _on_dialogue_ended() -> void:
	SecondaryCameraController.release_focus(false)
			