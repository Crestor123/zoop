class_name PowerupUI extends Control

@onready var Sprite = $TextureRect

func set_sprite(new_sprite : AtlasTexture):
	Sprite.texture = new_sprite
