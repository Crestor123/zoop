class_name Field extends Node2D

@onready var Background = $Background
@onready var BlockLines = $BlockLines
@onready var PlayerShip = $PlayerShip
@onready var PlayerArea = $PlayerArea
@onready var BlockTimer = $BlockTimer
@onready var UI : FieldUI = $CanvasLayer/FieldUI

@export var tile_size : int = 16
@export var block_line_object : PackedScene
@export var score_popup_object : PackedScene
@export var powerup_chance_increment : float = 0.01

signal s_quit
signal s_game_over
signal s_new_high_score_name

var powerups : Array[PowerupData]
var powerup_chance : float = 0.0

var block_timer_active : bool = true
var paused : bool = false
var score_multiplier : int = 0
var blocks_broken : int = 0
var score : int = 0
var points_per_block : int = 100

func _ready():
	UI.update_score(score)
	UI.resume.connect(pause)
	UI.new_high_score_confirm.connect(confirm_new_high_score)
	UI.reset.connect(reset)
	UI.quit.connect(quit)

	PlayerShip.s_block_destroyed.connect(block_broken)
	PlayerShip.s_finished_forward_dash.connect(reset_score_multiplier)
	PlayerShip.s_powerup_gained.connect(gain_powerup)
	
	PlayerArea.s_player_lose.connect(game_over)

func initialize():
	var half_tile = tile_size / 2
	var x_size = Background.get_used_rect().size.x * tile_size
	var y_size = Background.get_used_rect().size.y * tile_size
	
	# Create four sets of block lines in the center of the field,
	# each pointing from the edge of the screen toward the middle.
	
	# Pointing down
	for i in range(4):
		create_block_line(Vector2.DOWN, Vector2((7 * tile_size) + (i * tile_size) + (half_tile), -half_tile))
		
	# Pointing up
	for i in range(4):
		create_block_line(Vector2.UP, Vector2((7 * tile_size) + (i * tile_size) + (half_tile), 
			(y_size + half_tile)))
		
	# Pointing left
	for i in range(4):
		create_block_line(Vector2.LEFT, Vector2((x_size + half_tile), (4 * tile_size) + (i * tile_size) + (half_tile)))
		
	# Pointing right
	for i in range(4):
		create_block_line(Vector2.RIGHT, Vector2(-half_tile, (4 * tile_size) + (i * tile_size) + (half_tile)))
		
	initialize_player()
	PlayerArea.position = Vector2(x_size / 2, y_size / 2)
		
	BlockTimer.start()

func initialize_player():
	var half_tile = tile_size / 2
	var x_size = Background.get_used_rect().size.x * tile_size
	var y_size = Background.get_used_rect().size.y * tile_size
	
	PlayerShip.active = true
	PlayerShip.position = Vector2(x_size / 2 - half_tile, y_size / 2 - half_tile)

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pause()

func reset():
	UI.hide_game_over()
	
	for line : BlockLine in BlockLines.get_children():
		line.clear()
	for line : BlockLine in BlockLines.get_children():
		line.create_block()
	
	initialize_player()
	block_timer_active = true
	BlockTimer.start()

func pause():
	paused = !paused
	
	if !paused:
		UI.hide_pause()
	if paused:
		UI.show_pause()
	
	PlayerShip.clear_input_buffer()
	
	get_tree().paused = paused

func quit():
	if paused:
		get_tree().paused = false
	s_quit.emit()

func create_block_line(dir : Vector2, pos : Vector2):
	var new_block_line : BlockLine = block_line_object.instantiate()
	BlockLines.add_child(new_block_line)
	new_block_line.field = self
	new_block_line.direction = dir
	new_block_line.position = pos
	new_block_line.create_block()
	#new_block_line.create_powerup(select_random_powerup())

func select_random_powerup() -> PowerupData:
	var powerup = powerups.pick_random()
	return powerup

func select_random_line() -> BlockLine:
	var lines = BlockLines.get_children()
	return lines.pick_random()

func gain_powerup(powerup : PlayerPowerup):
	var powerup_ui = UI.add_powerup(powerup.powerup_data.sprite)
	powerup.powerup_ui = powerup_ui

func block_broken(block : Collectible, powerup_active : bool):
	var points : int = points_per_block
	if !powerup_active:
		blocks_broken += 1
		score_multiplier += 1
		points = points_per_block * score_multiplier
	gain_points(points)
	
	var new_popup : ScorePopup = score_popup_object.instantiate()
	add_child(new_popup)
	new_popup.global_position = block.global_position
	new_popup.set_points(points)

func reset_score_multiplier(_player : Player):
	powerup_chance += blocks_broken * powerup_chance_increment
	blocks_broken = 0
	score_multiplier = 0
	
func gain_points(points : int) -> int: 
	score += points
	UI.update_score(score)
	
	return points

func game_over():
	block_timer_active = false
	PlayerShip.game_over()
	
	s_game_over.emit(score)

func show_score(new_high_score : bool):
	UI.show_game_over(new_high_score, score)

func confirm_new_high_score(score_name):
	s_new_high_score_name.emit(score_name, score)

func _on_block_timer_timeout():
	if block_timer_active == false:
		BlockTimer.stop()
		return
	
	var line : BlockLine = select_random_line()
	var rand = randf_range(0.0, 1.0)
	if rand < powerup_chance:
		line.create_powerup(select_random_powerup())
		powerup_chance = 0.0
	else:
		line.create_block()
	BlockTimer.start()
