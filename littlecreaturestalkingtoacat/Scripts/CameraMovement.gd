extends Node

@export var background : Sprite2D 
@export var speed : float
@export var edge_percent: float

@onready var camera = $Camera2D

func _ready():
	camera.limit_left = background.get_rect().get_center().x - background.get_rect().size.x/2;
	camera.limit_right = background.get_rect().get_center().x + background.get_rect().size.x/2;
	camera.limit_top = background.get_rect().get_center().y - background.get_rect().size.y/2;
	camera.limit_bottom = background.get_rect().get_center().y + background.get_rect().size.y/2;
	
func _process(_delta: float):
	var mousePos = get_viewport().get_mouse_position();
	
	if mousePos.x < get_viewport().size.x / edge_percent:
		camera.position.x -= speed * _delta;
	elif mousePos.x > get_viewport().size.x - get_viewport().size.x / edge_percent:
		camera.position.x += speed * _delta;
		
	if mousePos.y < get_viewport().size.y / edge_percent:
		camera.position.y -= speed * _delta;
	elif mousePos.y > get_viewport().size.y - get_viewport().size.y / edge_percent:
		camera.position.y += speed * _delta;
		
	
