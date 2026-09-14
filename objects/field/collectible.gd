class_name Collectible extends StaticBody2D

@onready var Sprite = $Sprite2D

@export var speed : float = 20

var line : BlockLine = null
var next_position : Vector2

signal s_destroyed

func _process(delta):
	if position != next_position:
		position = position.move_toward(next_position, speed * delta)
	pass

func destroy():
	s_destroyed.emit(self)

func remove():
	queue_free()
