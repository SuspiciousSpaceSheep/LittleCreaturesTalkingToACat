extends Camera3D

@export var speed : float = 5.0
@export var edge_fraction: float = 0.1
@export var use_mouse_edges: bool = true
@export var use_input_actions: bool = true

var path_follow: PathFollow3D = null

func _ready():
	# Find the PathFollow3D parent
	if get_parent() is PathFollow3D:
		path_follow = get_parent()
	else:
		push_warning("Camera3D should be a child of PathFollow3D for path movement to work")


func _process(_delta: float):
	if not path_follow:
		return
	
	var movement_direction = 0.0
	
	# Mouse edge detection
	if use_mouse_edges:
		var vp = get_viewport()
		var x_pos_fraction = vp.get_mouse_position().x / vp.size.x
		
		if x_pos_fraction < edge_fraction:
			movement_direction -= 1.0
		elif x_pos_fraction > (1 - edge_fraction):
			movement_direction += 1.0
	
	# Input actions
	if use_input_actions:
		if Input.is_action_pressed("camera_move_left"):
			movement_direction -= 1.0
		if Input.is_action_pressed("camera_move_right"):
			movement_direction += 1.0
	
	# Apply movement along the path
	if movement_direction != 0.0:
		path_follow.progress += movement_direction * speed * _delta
