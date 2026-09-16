class_name ScorePopup extends Control

@onready var lblPoints = $PointValue
@onready var T = $Timer

@export var speed : float = 50

signal finished

func set_points(val : int):
	lblPoints.text = str(val)
	T.start()

func _process(delta):
	global_position.y -= speed * delta

func _on_timer_timeout():
	finished.emit()
	queue_free()
