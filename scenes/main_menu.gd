extends Control

@onready var btnPlay = $CanvasLayer/CenterContainer/VBoxContainer/Play

signal play

func _on_play_pressed():
	play.emit()
