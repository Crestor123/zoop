class_name FieldUI extends Control

@export var powerup_ui : PackedScene

@onready var lblScore = $Score
@onready var PauseMenu = $PauseMenu
@onready var PowerupContainer = $PowerupContainer

@onready var GameOverMenu = $GameOverMenu
@onready var lblGameOverScore = $GameOverMenu/PanelContainer/VBoxContainer/GameOverScore

signal resume
signal reset
signal quit

func update_score(val : int):
	lblScore.text = str(val)

func add_powerup(powerup_sprite : AtlasTexture) -> PowerupUI:
	var new_powerup = powerup_ui.instantiate()
	PowerupContainer.add_child(new_powerup)
	new_powerup.set_sprite(powerup_sprite)
	return new_powerup

func show_pause():
	PauseMenu.show()
	
func hide_pause():
	PauseMenu.hide()

func show_game_over(score : int):
	lblGameOverScore.text = str(score)
	GameOverMenu.show()

func hide_game_over():
	GameOverMenu.hide()

func _on_resume_pressed():
	resume.emit()

func _on_pause_quit_pressed():
	quit.emit()

func _on_play_again_pressed():
	reset.emit()

func _on_quit_pressed():
	quit.emit()
