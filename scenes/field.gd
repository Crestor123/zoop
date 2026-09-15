class_name Field extends Node2D

@onready var Background = $Background
@onready var BlockLines = $BlockLines
@onready var PlayerShip = $PlayerShip
@onready var PlayerArea = $PlayerArea
@onready var BlockTimer = $BlockTimer
@onready var UI : FieldUI = $CanvasLayer/FieldUI

@export var tile_size : int = 16
@export var block_line_object : PackedScene
@export var powerup_chance_increment : float = 0.01

signal s_quit

var powerups : Array[PowerupData]
var powerup_chance : float = 0.0

var paused : bool = false
var score : int = 0
var points_per_block : int = 100

func _ready():
	UI.update_score(score)
	UI.resume.connect(pause)
	UI.quit.connect(quit)

	PlayerShip.s_block_destroyed.connect(gain_points)
	PlayerShip.s_broken_block_count.connect(tally_powerup_chance)
	PlayerShip.s_powerup_gained.connect(gain_powerup)

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
		
	PlayerShip.position = Vector2(x_size / 2 - half_tile, y_size / 2 - half_tile)
	PlayerArea.position = Vector2(x_size / 2, y_size / 2)
		
	BlockTimer.start()
	pass

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pause()

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

func gain_points(_blocks_broken : int, score_multiplier : int):
	score += points_per_block * score_multiplier
	UI.update_score(score)

func tally_powerup_chance(block_count):
	powerup_chance += block_count * powerup_chance_increment
	pass

func _on_block_timer_timeout():
	var line : BlockLine = select_random_line()
	var rand = randf_range(0.0, 1.0)
	if rand < powerup_chance:
		line.create_powerup(select_random_powerup())
		powerup_chance = 0.0
	else:
		line.create_block()
	BlockTimer.start()
