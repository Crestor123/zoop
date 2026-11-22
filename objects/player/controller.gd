class_name PlayerController extends Node

signal dash
signal powerup

var input_buffer : Array[Vector2] = [Vector2.ZERO]

var inputs = {
	"up" : 		Vector2.UP,
	"down" : 	Vector2.DOWN,
	"left" : 	Vector2.LEFT,
	"right" : 	Vector2.RIGHT
}


func _process(delta):
	if Input.is_action_just_pressed("cycle_powerup"):
		powerup.emit()
			
	if Input.is_action_just_pressed("dash"):
		dash.emit()

func get_inputs():
	# Loop through the inputs array and check each direction for movement
	# Add the input directions to the buffer
	for dir in inputs.keys():
		if Input.is_action_just_pressed(dir):
			input_buffer.append(inputs[dir])
	for dir in inputs.keys():
		if Input.is_action_just_released(dir):
			input_buffer.erase(inputs[dir])
			
	return input_buffer
