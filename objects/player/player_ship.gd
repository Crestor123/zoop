class_name Player extends Area2D

@onready var CollisionRay = $CollisionRay
@onready var DashRay = $DashRay
@onready var Sprite = $Sprite2D
@onready var ColorComp = $ColorComponent
@onready var Powerups = $Powerups

@export var powerup_object : PackedScene
@export var color : Game.BlockColor
@export var stride : int = 16
@export var move_speed : int = 8
@export var dash_speed : float = 5

signal s_powerup_gained
signal s_finished_forward_dash
signal s_finished_dash
signal s_block_destroyed
signal s_broken_block_count

enum State {
	IDLE,
	MOVE,
	DASH,
}

var blocks_destroyed : int = 0
var input_buffer : Array[Vector2] = [Vector2.ZERO]
var buffered_dash : bool = false
var current_input : Vector2
var current_direction : Vector2

var break_all_blocks : bool = false
var current_powerup : PlayerPowerup
var next_powerup_index : int = -1

var inputs = {
	"up" : 		Vector2.UP,
	"down" : 	Vector2.DOWN,
	"left" : 	Vector2.LEFT,
	"right" : 	Vector2.RIGHT
}

var target_block : Collectible
var target_pos : Vector2
var dash_start_pos : Vector2
var cur_state : State = State.IDLE

func _ready():
	# Set the player's position to be grid-aligned
	position = position.snapped(Vector2.ONE * stride)
	position += Vector2.ONE * stride / 2

func _process(delta):
	# If we're not dashing, we can select the powerup we want to use
	if cur_state != State.DASH:
		if Input.is_action_just_pressed("cycle_powerup"):
			cycle_powerup()
	
	if Input.is_action_just_pressed("dash") or buffered_dash == true:
		if current_powerup != null:
			use_powerup()
		else:
			check_target()
			dash()
	
	# Loop through the inputs array and check each direction for movement
	# Add the input directions to the buffer
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			#move(inputs[dir])
			input_buffer.append(inputs[dir])
	for dir in inputs.keys():
		if Input.is_action_just_released(dir):
			input_buffer.erase(inputs[dir])
	
	# Select the current input from the buffer
	# If we're idling, we can initiate a move
	current_input = input_buffer[-1]
	if current_input != Vector2.ZERO and cur_state == State.IDLE:
		move(current_input)

## Clears the player's input buffer and resets it to the initial state.
func clear_input_buffer():
	input_buffer.clear()
	input_buffer.append(Vector2.ZERO)

## Selects an available powerup from the player's list of powerups.
func cycle_powerup():
	var num_powerups = Powerups.get_child_count()
	if num_powerups == 0: return
	
	if current_powerup:
		current_powerup.powerup_ui.show()
	
	next_powerup_index += 1
	if next_powerup_index + 1 > num_powerups:
		next_powerup_index = -1
		
	if next_powerup_index == -1:
		current_powerup = null
		ColorComp.set_color(color)
		
	else:
		current_powerup = Powerups.get_child(next_powerup_index)
		ColorComp.set_palette(current_powerup.powerup_data.palette)
		current_powerup.powerup_ui.hide()
		print(current_powerup.powerup_data.name)

## Finds the closest block in front of the player, and initiates a tween between the player's current position
## and that block. Does nothing if there are no blocks in front of the player.
## Changes state to the dash state.
func dash():
	# Only initiate a dash if we're not moving
	if cur_state != State.IDLE: 
		buffered_dash = true
		return
	
	buffered_dash = false
	# If we have a target, we can dash
	if target_block != null:
		cur_state = State.DASH
		
		dash_start_pos = global_position
		var tween = create_tween()
		tween.finished.connect(finished_forward_dash)
		tween.tween_method(tween_update, 0.0, 1.0, 0.2)
		#tween.tween_property(self, "global_position", target_block.global_position, 0.2)

func tween_update(weight : float):
	var pos : Vector2
	if target_block:
		pos = target_block.global_position
	elif target_pos:
		pos = target_pos
	
	global_position = dash_start_pos.lerp(pos, weight)

func check_target():
	target_block = null
	
	# Raycast to find the closest block
	DashRay.target_position = current_direction * 200
	DashRay.force_raycast_update()
	var collider = DashRay.get_collider()
	
	# If it's a powerup, it's the target
	if collider is Powerup:
		target_block = collider
	
	# If it's a block, determine if block is the same color as the player
	elif collider is Block:
		# If it's not the same color, that block is the target
		if collider.color != color:
			target_block = collider
		# If it is the same color, determine if there are multiple blocks of the same color
		else:
			var line = collider.line
			target_block = line.get_back_block_by_color(color)
	pass

func check_closest_block():
	target_block = null
	
	# Raycast to find the closest block
	DashRay.target_position = current_direction * 200
	DashRay.force_raycast_update()
	var collider = DashRay.get_collider()
	
	if collider is Collectible:
		target_block = collider

func use_powerup():
	check_target()
	current_powerup.powerup_data.activate(self)
	
func finished_use_powerup():
	ColorComp.set_color(color)
	current_powerup.powerup_ui.queue_free()
	current_powerup.queue_free()
	current_powerup = null
	
	next_powerup_index = -1

## Moves the player in a given direction, and rotates the player to face that direction.
## Changes state to move.
## dir : The direction to move.
func move(dir : Vector2):
	Sprite.rotation = dir.angle() + deg_to_rad(90)
	current_direction = dir
	
	# Check collision before moving
	CollisionRay.target_position = dir * stride
	CollisionRay.force_raycast_update()
	if CollisionRay.is_colliding(): return
	
	cur_state = State.MOVE
	
	var tween = create_tween()
	tween.finished.connect(finished_move)
	tween.tween_property(self, "position", position + dir * stride, 1.0 / move_speed)

## Moves the player back to the starting position of a dash
## Called by the tween created in the dash function.
func finished_forward_dash():
	s_finished_forward_dash.emit(self)
	s_broken_block_count.emit(blocks_destroyed)
	blocks_destroyed = 0
	
	current_direction = -current_direction
	Sprite.rotation = current_direction.angle() + deg_to_rad(90)
	var tween = create_tween()
	tween.finished.connect(finished_dash)
	tween.tween_property(self, "global_position", dash_start_pos, 0.2)

## Returns the player to an idle state after a dash.
## Called by the tween created in the finished_forward_dash function.
func finished_dash():
	s_finished_dash.emit(self)
	cur_state = State.IDLE

## Returns the player to an idle state after moving.
## Called by the tween created in the move function
func finished_move():
	cur_state = State.IDLE

## Changes the player's color to a given color.
## new_color : The color to change to.
func change_color(new_color : Game.BlockColor):
	color = new_color
	ColorComp.set_color(color)
	print(color)

## Add a powerup to the player's list of powerups.
## powerup_data : The PowerupData of the powerup to add.
func gain_powerup(powerup_data : PowerupData):
	print("Gained powerup!")
	
	var new_powerup : PlayerPowerup = powerup_object.instantiate()
	Powerups.add_child(new_powerup)
	new_powerup.powerup_data = powerup_data 
	s_powerup_gained.emit(new_powerup)
	pass

func _on_body_entered(body):
	# If we collide with a block, check if it is the same color.
	if body == target_block:
		target_pos = target_block.global_position
	
	if body is Block:
		# If it is the same color, destroy the block and increment the score multiplier.
		if body.color == color or break_all_blocks == true:
			body.destroy()
			blocks_destroyed += 1
			s_block_destroyed.emit(blocks_destroyed)
		# If it's not the same color, change the player's color to that block's color.
		else:
			var prev_color = color
			change_color(target_block.color)
			target_block.change_color(prev_color)
	# If we collide with a powerup, add it to the list of powerups.
	if body is Powerup:
		gain_powerup(body.powerup_data)
		body.destroy()
