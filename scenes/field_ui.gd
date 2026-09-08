extends Control

@onready var lblScore = $Score
@onready var PauseMenu = $PauseMenu

signal resume
signal quit

func update_score(val : int):
	lblScore.text = str(val)

func show_pause():
	PauseMenu.show()
	
func hide_pause():
	PauseMenu.hide()

func _on_resume_pressed():
	resume.emit()

func _on_quit_pressed():
	quit.emit()
