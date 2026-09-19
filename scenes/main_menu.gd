extends Control

@onready var btnPlay = $CanvasLayer/CenterContainer/VBoxContainer/Play

signal play
signal high_scores

func _on_play_pressed():
	play.emit()

func _on_high_scores_pressed():
	high_scores.emit()
