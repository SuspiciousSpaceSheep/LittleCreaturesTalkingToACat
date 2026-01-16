extends Camera3D

@export var speed : float = 5.0
@export var edge_fraction: float = 0.1

@onready var camera : Camera3D  = get_node(".") as Camera3D

	
func _process(_delta: float):
	var vp = get_viewport();

	
	var x_pos_fraction = vp.get_mouse_position().x / vp.size.x;
	
	if x_pos_fraction < edge_fraction:
		camera.h_offset -= speed * _delta;
	elif x_pos_fraction > (1-edge_fraction):
		camera.h_offset += speed * _delta;
		
	#var transform : Transform3D = camera.get_camera_transform();
	#if mousePos.x < 0:
		#camera.get_camera_transform() -= speed * _delta;
	#elif mousePos.x > 0:
		#camera.h_offset += speed * _delta;
	
	
	
	#if mousePos.x < get_viewport().size.x / edge_percent:
		#camera.h_offset -= speed * _delta;
	#elif mousePos.x > get_viewport().size.x - get_viewport().size.x / edge_percent:
		#camera.h_offset += speed * _delta;
		
