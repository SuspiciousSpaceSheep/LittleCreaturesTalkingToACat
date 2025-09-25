extends Node2D

@export var character_scene : PackedScene

func _on_button_pressed():
	print("Open Character Scene");
	var scene = character_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED);
	get_tree().root.add_child(scene);
