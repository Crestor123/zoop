class_name Game extends Node2D

@export var main_menu_scene : PackedScene
@export var field_scene : PackedScene

@export var powerups : Array[PowerupData]

@export var tile_size = 16

var current_scene = null

var score : int = 0

enum BlockColor {
	GREEN,
	BLUE,
	RED,
	ORANGE,
}

func _ready():
	main_menu()
	
func play():
	var playfield = change_scene(field_scene)
	
	playfield.powerups = powerups
	playfield.s_quit.connect(main_menu)
	playfield.initialize()
	
func main_menu():
	var menu = change_scene(main_menu_scene)
	menu.play.connect(play)
	
func change_scene(scene : PackedScene) -> Node:
	if current_scene:
		current_scene.queue_free()
		
	var new_scene = scene.instantiate()
	add_child(new_scene)
	current_scene = new_scene
	
	return new_scene
