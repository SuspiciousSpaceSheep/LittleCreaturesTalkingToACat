extends Node3D

@export var dialogue_id: String = "Bunny_says_hi"


#dialoge camera settings
@export var camera_distance: float = 1.5
@export var camera_height: float = 1.0


func _ready() -> void:
	# Connect to Dialogic's timeline ended signal
	Dialogic.timeline_ended.connect(_on_dialogue_ended)


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Focus secondary camera: distance=2.0, height=1.5
			SecondaryCameraController.focus_on_target(self, camera_distance, camera_height)
			
			# Start dialogue
			Dialogic.start(dialogue_id)


# Release camera focus when dialogue ends
func _on_dialogue_ended() -> void:
	SecondaryCameraController.release_focus(false)
			
