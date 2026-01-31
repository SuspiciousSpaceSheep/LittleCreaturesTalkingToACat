extends Node3D
class_name SecondaryCameraController

## Secondary camera that can focus on NPCs/objects

# Singleton reference
static var instance: SecondaryCameraController = null

# Camera settings
@export var camera: Camera3D

# Camera configuration
@export_group("Camera Positioning")
@export var default_offset: Vector3 = Vector3(0, 1.5, 2.0) ## Offset from target position
@export var look_at_offset: Vector3 = Vector3(0, 1.0, 0) ## Offset for look-at point on target

@export_group("Transition Settings")
@export var transition_duration: float = 0.5 ## Duration for blend transition
@export var use_blend_transition: bool = true ## If false, switches instantly

# Internal state
var is_active: bool = false
var current_target: Node3D = null
var transition_tween: Tween = null
var main_camera: Camera3D = null


func _ready() -> void:
	# Set up singleton
	if instance == null:
		instance = self
	else:
		push_warning("Multiple SecondaryCameraController instances detected!")
	
	# Store reference to main camera
	main_camera = get_viewport().get_camera_3d()
	
	# Ensure secondary camera is disabled initially
	if camera:
		camera.current = false
	
	is_active = false


func _process(_delta: float) -> void:
	if is_active and current_target and camera:
		# Update camera to look at target
		var target_pos = current_target.global_position + look_at_offset
		camera.look_at(target_pos, Vector3.UP)


## Static function to activate the secondary camera on a target
## distance: How far from the character
## height: How high above the character
## use_character_forward: If true, positions camera based on character's facing direction
static func focus_on_target(target: Node3D, distance: float = 2.0, height: float = 1.5, use_character_forward: bool = true, blend: bool = false) -> void:
	if instance:
		instance._focus_on_target_internal(target, distance, height, use_character_forward, blend)
	else:
		push_error("SecondaryCameraController instance not found!")


## Static function to deactivate the secondary camera
static func release_focus(blend: bool = false) -> void:
	if instance:
		instance._release_focus_internal(blend)
	else:
		push_error("SecondaryCameraController instance not found!")


## Internal function to focus on target
func _focus_on_target_internal(target: Node3D, distance: float, height: float, use_character_forward: bool, blend: bool) -> void:
	if not target or not camera:
		return
	
	current_target = target
	
	# Calculate camera position based on character's facing direction
	var camera_offset: Vector3
	
	if use_character_forward:
		# Get the character's forward direction and reverse it to position camera in front
		var forward = target.global_transform.basis.z.normalized()
		# Position camera in front of character at specified distance and height
		camera_offset = forward * distance + Vector3.UP * height
	else:
		# Use default offset if not using character forward
		camera_offset = Vector3(0, height, distance)
	
	var target_camera_pos = target.global_position + camera_offset
	
	# Position the camera
	camera.global_position = target_camera_pos
	#camera.look_at(target.global_position, Vector3.UP)
	
	# Activate camera
	if blend and use_blend_transition:
		_blend_to_secondary_camera()
	else:
		_activate_camera()


## Internal function to release focus
func _release_focus_internal(blend: bool) -> void:
	if blend and use_blend_transition:
		_blend_to_main_camera()
	else:
		_deactivate_camera()


## Blend transition to secondary camera
func _blend_to_secondary_camera() -> void:
	if transition_tween:
		transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.set_ease(Tween.EASE_IN_OUT)
	transition_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Simple approach: just switch after a delay
	transition_tween.tween_callback(_activate_camera).set_delay(transition_duration)


## Blend transition to main camera
func _blend_to_main_camera() -> void:
	if transition_tween:
		transition_tween.kill()
	
	transition_tween = create_tween()
	transition_tween.set_ease(Tween.EASE_IN_OUT)
	transition_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Simple approach: just switch after a delay
	transition_tween.tween_callback(_deactivate_camera).set_delay(transition_duration)


## Activate secondary camera
func _activate_camera() -> void:
	is_active = true
	if camera:
		camera.current = true


## Deactivate secondary camera and restore main camera
func _deactivate_camera() -> void:
	is_active = false
	current_target = null
	
	# Restore main camera
	if main_camera:
		main_camera.current = true
	elif camera:
		camera.current = false
