class_name Player extends Area2D

@onready var CollisionRay = $CollisionRay
@onready var DashRay = $DashRay
@onready var Sprite = $Sprite2D
@onready var ColorComp = $ColorComponent

@export var color : Game.BlockColor
@export var stride : int = 16
@export var speed : int = 8

signal s_block_destroyed

var score_multiplier : int = 1
var input_buffer : Array[Vector2] = [Vector2.ZERO]
var current_input : Vector2
var current_direction : Vector2

var inputs = {
	"up" : 		Vector2.UP,
	"down" : 	Vector2.DOWN,
	"left" : 	Vector2.LEFT,
	"right" : 	Vector2.RIGHT
}

var target_block : Collectible
var dash_start_pos : Vector2
var moving : bool = false

func _ready():
	position = position.snapped(Vector2.ONE * stride)
	position += Vector2.ONE * stride / 2

func _process(delta):
	if Input.is_action_just_pressed("dash"):
		dash()
	
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			#move(inputs[dir])
			input_buffer.append(inputs[dir])
	for dir in inputs.keys():
		if Input.is_action_just_released(dir):
			input_buffer.erase(inputs[dir])
			
	current_input = input_buffer[-1]
	if current_input != Vector2.ZERO and moving == false:
		move(current_input)

func clear_input_buffer():
	input_buffer.clear()
	input_buffer.append(Vector2.ZERO)

func dash():
	if moving: return
	
	target_block = null
	
	DashRay.target_position = current_direction * 200
	DashRay.force_raycast_update()
	var collider = DashRay.get_collider()
	
	if collider is Collectible:
		if collider is Powerup:
			target_block = collider
			moving = true
	
		if collider is Block:
			if collider.color != color:
				target_block = collider
			else:
				var line = collider.line
				target_block = line.get_back_block_by_color(color)
			moving = true
		
		dash_start_pos = position
		var tween = create_tween()
		tween.finished.connect(finished_forward_dash)
		tween.tween_property(self, "global_position", target_block.global_position, 0.2)
		
func move(dir : Vector2):
	Sprite.rotation = dir.angle() + deg_to_rad(90)
	current_direction = dir
	
	CollisionRay.target_position = dir * stride
	CollisionRay.force_raycast_update()
	if CollisionRay.is_colliding(): return
	
	moving = true
	
	var tween = create_tween()
	tween.finished.connect(finished_move)
	tween.tween_property(self, "position", position + dir * stride, 1.0 / speed)

func finished_forward_dash():
	score_multiplier = 1
	
	current_direction = -current_direction
	Sprite.rotation = current_direction.angle() + deg_to_rad(90)
	var tween = create_tween()
	tween.finished.connect(finished_dash)
	tween.tween_property(self, "position", dash_start_pos, 0.2)
	
func finished_dash():
	moving = false

func finished_move():
	moving = false

func change_color(new_color : Game.BlockColor):
	color = new_color
	ColorComp.set_color(color)
	print(color)

func _on_body_entered(body):
	if body is Block:
		if body.color == color:
			body.destroy()
			s_block_destroyed.emit(score_multiplier)
			score_multiplier += 1
		else:
			var prev_color = color
			change_color(target_block.color)
			target_block.change_color(prev_color)
	if body is Powerup:
		print("gained powerup!")
		body.destroy()
