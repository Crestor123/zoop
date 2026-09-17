extends Node2D

@onready var Rectangle = $ColorRect
@onready var Walls = $Walls
@onready var LoseArea = $LoseArea

@export var size : Vector2

signal s_player_lose

func set_size(new_size : Vector2):
	Rectangle.custom_minimum_size = new_size
	
	for wall in Walls:
		var collision = wall.get_child(0)
		collision.shape.distance = -abs(new_size * collision.shape.normal)

func _on_lose_area_body_entered(body):
	if body is Collectible:
		s_player_lose.emit()
