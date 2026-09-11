class_name Collectible extends StaticBody2D

@onready var Sprite = $Sprite2D

var line : BlockLine = null

signal s_destroyed

func destroy():
	s_destroyed.emit(self)

func remove():
	queue_free()
