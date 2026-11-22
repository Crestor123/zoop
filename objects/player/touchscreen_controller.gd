class_name TouchscreenController extends PlayerController

signal set_dir

func _input(event):
	pass

func dash_pressed():
	dash.emit()
	
func powerup_pressed():
	powerup.emit()

func set_direction(dir : Vector2):
	set_dir.emit(dir)

func up_pressed():
	input_buffer.append(inputs["up"])
	
func down_pressed():
	input_buffer.append(inputs["down"])
	
func left_pressed():
	input_buffer.append(inputs["left"])
	
func right_pressed():
	input_buffer.append(inputs["right"])

func up_released():
	input_buffer.erase(inputs["up"])
	
func down_released():
	input_buffer.erase(inputs["down"])
	
func left_released():
	input_buffer.erase(inputs["left"])
	
func right_released():
	input_buffer.erase(inputs["right"])

func get_inputs():
	var inputs = input_buffer.duplicate()
	input_buffer.clear()
	input_buffer = [Vector2.ZERO]
	return inputs
