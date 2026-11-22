extends Camera2D

@export var decay  : float = 0.8
@export var max_offset : Vector2 = Vector2(16, 16)

var trauma : float = 0.0
var power : int = 2

func _ready():
	randomize()

func add_trauma(amount : float):
	trauma = min(trauma + amount, 1.0)
	
func _process(delta):
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
		
func shake():
	var amount = pow(trauma, power)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
