class_name Game extends Node2D

@export var main_menu_scene : PackedScene
@export var field_scene : PackedScene
@export var high_score_scene : PackedScene

@export var powerups : Array[PowerupData]

@onready var GameHighScores = $HighScores

@export var tile_size = 16

var current_scene = null

enum BlockColor {
	GREEN,
	BLUE,
	RED,
	ORANGE,
}

func _ready():
	#GameHighScores.load_high_scores()
	
	main_menu()
	
func play():
	var playfield = change_scene(field_scene)
	
	playfield.powerups = powerups
	playfield.s_quit.connect(main_menu)
	playfield.s_game_over.connect(game_over)
	playfield.s_new_high_score_name.connect(score_entry_confirm)
	playfield.initialize()
	
func main_menu():
	var menu = change_scene(main_menu_scene)
	menu.play.connect(play)
	menu.high_scores.connect(high_scores)
	
func high_scores():
	var high_score_menu = change_scene(high_score_scene)
	high_score_menu.back.connect(main_menu)
	
	high_score_menu.populate_scores(GameHighScores.high_scores)
	
func game_over(score : int):
	var new_high_score = GameHighScores.check_score(score)
	
	current_scene.show_score(new_high_score)

func score_entry_confirm(score_name : String, score : int):
	GameHighScores.add_high_score(score_name, score)
	pass
	
func change_scene(scene : PackedScene) -> Node:
	if current_scene:
		current_scene.queue_free()
		
	var new_scene = scene.instantiate()
	add_child(new_scene)
	current_scene = new_scene
	
	return new_scene
