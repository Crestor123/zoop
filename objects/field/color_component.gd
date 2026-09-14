class_name ColorComponent extends Node

@export var Sprite : Sprite2D

@export var blockColorRegion : Dictionary[Game.BlockColor, Texture2D]

func set_color(color : Game.BlockColor):
	if Sprite:
		var material : ShaderMaterial = Sprite.material
		material.set_shader_parameter("new_palette", blockColorRegion[color])

func set_palette(palette : Texture2D):
	if Sprite:
		var material : ShaderMaterial = Sprite.material
		material.set_shader_parameter("new_palette", palette)
	pass
