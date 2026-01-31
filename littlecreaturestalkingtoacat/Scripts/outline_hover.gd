extends Node

@onready var mesh : MeshInstance3D  = get_node(".") as MeshInstance3D
var outline_color_name : StringName = "outline_color";
var outline_material : ShaderMaterial;
var is_hightlighted : bool = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#mesh.material.set_shader_parameter(outline_color_name, Vector4(0.0, 1.0, 0.0, 0.0))
	print(mesh);
	print(mesh.get_active_material(0));
	var mat = mesh.get_active_material(0);
	outline_material = mat.next_pass as ShaderMaterial;
#	set_hightlighted(false);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func set_hightlighted(_new_is_highlighted):
	pass
#	is_hightlighted = new_is_highlighted
#	if (new_is_highlighted):
#		outline_material.set_shader_parameter(outline_color_name, Vector4(0.0, 1.0, 0.0, 1.0))
#	else:
#		outline_material.set_shader_parameter(outline_color_name, Vector4(0.0, 1.0, 0.0, 0.0))

# TODO: Add a global script that makes a mouse raycast, setting the objects to hightled or not
