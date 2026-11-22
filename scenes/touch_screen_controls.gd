extends Control

@onready var btnUp = $Up
@onready var btnDown = $Down
@onready var btnLeft = $Left
@onready var btnRight = $Right

@export var swipe_threshold : float = 25.0
@export var max_tap_time : float = 50.0

signal up
signal down
signal left
signal right

signal set_direction
signal dash
signal powerup

var start_pos : Vector2 = Vector2.ZERO
var drag_vector : Vector2
var pressed : bool = false
var tapping : bool = false
var button_pressed : TouchScreenButton = null
var tap_start_time : float = 0.0
var cur_time : float = 0.0

func connect_signals(controller : TouchscreenController):
	dash.connect(controller.dash_pressed)
	powerup.connect(controller.powerup_pressed)
	set_direction.connect(controller.set_direction)
	up.connect(controller.up_pressed)
	down.connect(controller.down_pressed)
	left.connect(controller.left_pressed)
	right.connect(controller.right_pressed)
	pass


func _process(delta):
	if pressed:
		cur_time = Time.get_ticks_msec()
		#print(cur_time - tap_start_time)
	if !tapping and cur_time - tap_start_time >= max_tap_time:
		tapping = true
		
	if tapping:
		tap()


func _input(event : InputEvent):
	if event is InputEventScreenTouch:
		if event.pressed:
			pressed = true
			tap_start_time = Time.get_ticks_msec()
			start_pos = event.position
			cur_time = 0.0
		elif pressed:
			button_pressed = null
			pressed = false
			tapping = false
			cur_time = 0.0
			
	if event is InputEventScreenDrag:
		drag_vector = event.position - start_pos
		#print(drag_vector.length())
		print(tapping)
		if drag_vector.length() > swipe_threshold and !tapping:
			swipe()


func tap():
	#print(button_pressed)
	match(button_pressed):
		btnUp:
			up.emit()
		btnDown:
			down.emit()
		btnLeft:
			left.emit()
		btnRight:
			right.emit()
	
	
func swipe():
	var dash_vector = Vector2.ZERO
	if abs(drag_vector.x) > abs(drag_vector.y):
		if drag_vector.x > 0:
			dash_vector = Vector2.RIGHT
		else:
			dash_vector = Vector2.LEFT
	else:
		if drag_vector.y > 0:
			dash_vector = Vector2.DOWN
		else:
			dash_vector = Vector2.UP
	
	
	drag_vector = Vector2.ZERO
	if dash_vector != Vector2.ZERO:
		set_direction.emit(dash_vector)
		dash.emit()
	pass


func _on_up_pressed():
	button_pressed = btnUp

func _on_down_pressed():
	button_pressed = btnDown

func _on_left_pressed():
	button_pressed = btnLeft

func _on_right_pressed():
	button_pressed = btnRight
