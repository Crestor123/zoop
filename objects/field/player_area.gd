extends Node2D

@onready var Rectangle = $ColorRect
@onready var Walls = $Walls

@export var size : Vector2

func set_size(new_size : Vector2):
	Rectangle.custom_minimum_size = new_size
	
	for wall in Walls:
		var collision = wall.get_child(0)
		collision.shape.distance = -abs(new_size * collision.shape.normal)
