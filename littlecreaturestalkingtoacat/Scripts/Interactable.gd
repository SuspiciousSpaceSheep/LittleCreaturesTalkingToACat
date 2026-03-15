@tool
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
@export var camera_height: float = 1.0  ## Height on the character the camera looks at (not a camera position offset)
@export_range(-180, 180, 1.0, "suffix:°") var camera_horizontal_angle: float = 0.0  ## Horizontal orbit angle (0=front, 90=right side)
@export_range(-89, 89, 1.0, "suffix:°") var camera_vertical_angle: float = 0.0  ## Vertical tilt (positive=above looking down)
@export var show_camera_preview: bool = true  ## Show camera position gizmo in editor

@export_group("Outline Settings")
# Outline shader settings
@export var outline_color: Color = Color(0.0, 1.0, 0.0, 1.0)
@export var outline_width: float = 1.0

var outline_materials: Array[ShaderMaterial] = []
var is_mouse_over: bool = false

var _outline_shader: Shader = preload("res://shaders/outline_shader.gdshader")

# Editor preview nodes (internal, not saved to scene)
var _preview_sphere: MeshInstance3D = null
var _preview_line: MeshInstance3D = null


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	# Connect to Dialogic's timeline ended signal
	Dialogic.timeline_ended.connect(_on_dialogue_ended)
	
	# Auto-connect any Area3D child so signals don't need to be wired manually per creature
	var area := _find_area_3d(self)
	if area:
		if not area.input_event.is_connected(_on_area_3d_input_event):
			area.input_event.connect(_on_area_3d_input_event)
		if not area.mouse_entered.is_connected(_on_area_3d_mouse_entered):
			area.mouse_entered.connect(_on_area_3d_mouse_entered)
		if not area.mouse_exited.is_connected(_on_area_3d_mouse_exited):
			area.mouse_exited.connect(_on_area_3d_mouse_exited)
	
	# Find all mesh instances and collect their outline materials
	_collect_outline_materials(self)
	
	# Initialize outline as hidden
	_set_outline_visibility(false)


func _find_area_3d(node: Node) -> Area3D:
	if node is Area3D:
		return node as Area3D
	for child in node.get_children():
		var result := _find_area_3d(child)
		if result:
			return result
	return null


func _collect_outline_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh = node as MeshInstance3D
		var material = mesh.get_active_material(0)
		if material:
			if material.next_pass and material.next_pass is ShaderMaterial:
				# Already set up (e.g. bunny) — just track the existing outline pass
				outline_materials.append(material.next_pass as ShaderMaterial)
			else:
				# Other creatures: create an outline pass and attach it to a
				# per-instance duplicate so we don't mutate the shared resource
				var outline_mat := ShaderMaterial.new()
				outline_mat.shader = _outline_shader
				outline_mat.set_shader_parameter("outline_color", Color(outline_color.r, outline_color.g, outline_color.b, 0.0))
				outline_mat.set_shader_parameter("outline_width", outline_width)
				var local_mat := material.duplicate()
				local_mat.next_pass = outline_mat
				mesh.set_surface_override_material(0, local_mat)
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
			SecondaryCameraController.focus_on_target(self, camera_distance, camera_height, true, false, camera_horizontal_angle, camera_vertical_angle)
			
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


# ---------- Editor preview ----------

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_camera_preview()


## Compute the camera offset from the interactable's global position.
func _compute_camera_offset() -> Vector3:
	var forward = global_transform.basis.z.normalized()
	var dir = forward.rotated(Vector3.UP, deg_to_rad(camera_horizontal_angle))
	var right_vec = dir.cross(Vector3.UP)
	if right_vec.length_squared() > 0.0001:
		right_vec = right_vec.normalized()
		dir = dir.rotated(right_vec, deg_to_rad(camera_vertical_angle))
	return dir * camera_distance


func _update_camera_preview() -> void:
	if not is_inside_tree():
		return

	if not show_camera_preview:
		if is_instance_valid(_preview_sphere):
			_preview_sphere.visible = false
		if is_instance_valid(_preview_line):
			_preview_line.visible = false
		return

	var cam_offset := _compute_camera_offset()

	# --- sphere at camera position ---
	if not is_instance_valid(_preview_sphere):
		_preview_sphere = MeshInstance3D.new()
		_preview_sphere.top_level = true
		var sphere_mesh := SphereMesh.new()
		sphere_mesh.radius = 0.04
		sphere_mesh.height = 0.08
		_preview_sphere.mesh = sphere_mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.7, 0.0)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.no_depth_test = true
		_preview_sphere.material_override = mat
		add_child(_preview_sphere, false, Node.INTERNAL_MODE_BACK)

	_preview_sphere.visible = true
	_preview_sphere.global_position = global_position + cam_offset

	# --- line + frustum wireframe ---
	if not is_instance_valid(_preview_line):
		_preview_line = MeshInstance3D.new()
		_preview_line.top_level = true
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.7, 0.0)
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.no_depth_test = true
		_preview_line.material_override = mat
		add_child(_preview_line, false, Node.INTERNAL_MODE_BACK)

	_preview_line.visible = true
	_preview_line.global_position = global_position

	var im: ImmediateMesh
	if _preview_line.mesh is ImmediateMesh:
		im = _preview_line.mesh as ImmediateMesh
		im.clear_surfaces()
	else:
		im = ImmediateMesh.new()
		_preview_line.mesh = im

	var look_at_local := Vector3.UP * camera_height

	im.surface_begin(Mesh.PRIMITIVE_LINES)
	# Line from look-at point to camera position
	im.surface_add_vertex(look_at_local)
	im.surface_add_vertex(cam_offset)
	# Vertical stem from pivot to look-at point
	im.surface_add_vertex(Vector3.ZERO)
	im.surface_add_vertex(look_at_local)

	# Small frustum/pyramid at camera position pointing toward the look-at point
	if (cam_offset - look_at_local).length() > 0.01:
		var look_dir := (look_at_local - cam_offset).normalized()
		var up := Vector3.UP
		var right := look_dir.cross(up)
		if right.length_squared() < 0.0001:
			right = Vector3.RIGHT
		right = right.normalized()
		var cam_up := right.cross(look_dir).normalized()
		var s := 0.05  # frustum half-size
		var l := 0.10  # frustum length
		var tip := cam_offset
		var bc := cam_offset + look_dir * l  # base center
		var c0 := bc + (right + cam_up) * s
		var c1 := bc + (-right + cam_up) * s
		var c2 := bc + (-right - cam_up) * s
		var c3 := bc + (right - cam_up) * s
		# Edges from tip to base corners
		im.surface_add_vertex(tip); im.surface_add_vertex(c0)
		im.surface_add_vertex(tip); im.surface_add_vertex(c1)
		im.surface_add_vertex(tip); im.surface_add_vertex(c2)
		im.surface_add_vertex(tip); im.surface_add_vertex(c3)
		# Base rectangle
		im.surface_add_vertex(c0); im.surface_add_vertex(c1)
		im.surface_add_vertex(c1); im.surface_add_vertex(c2)
		im.surface_add_vertex(c2); im.surface_add_vertex(c3)
		im.surface_add_vertex(c3); im.surface_add_vertex(c0)

	im.surface_end()

