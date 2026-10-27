class_name FieldUI extends Control

@export var powerup_ui : PackedScene

@onready var lblScore = $Score
@onready var lblBlocksRequired = $BlocksRequired
@onready var lblLevel = $Level
@onready var PauseMenu = $PauseMenu
@onready var PowerupContainer = $PowerupContainer

@onready var GameOverMenu = $GameOverMenu
@onready var lblGameOverScore = $GameOverMenu/PanelContainer/VBoxContainer/GameOverScore
@onready var NewHighScoreMenu = $GameOverMenu/PanelContainer/VBoxContainer/NewHighScoreMenu
@onready var NameEntry = $GameOverMenu/PanelContainer/VBoxContainer/NewHighScoreMenu/HBoxContainer/HighScoreNameEntry

signal resume
signal reset
signal quit
signal new_high_score_confirm

func update_score(val : int):
	lblScore.text = str(val)

func update_blocks_required(val : int):
	lblBlocksRequired.text = str(val)
	
func update_level(val : int):
	lblLevel.text = str(val)

func add_powerup(powerup_sprite : AtlasTexture) -> PowerupUI:
	var new_powerup = powerup_ui.instantiate()
	PowerupContainer.add_child(new_powerup)
	new_powerup.set_sprite(powerup_sprite)
	return new_powerup

func show_pause():
	PauseMenu.show()
	
func hide_pause():
	PauseMenu.hide()

func show_game_over(new_high_score : bool, score : int):
	lblGameOverScore.text = str(score)
	if new_high_score:
		NameEntry.editable = true
		NewHighScoreMenu.show()
	
	GameOverMenu.show()

func hide_game_over():
	NewHighScoreMenu.hide()
	GameOverMenu.hide()

func submit_high_score():
	NameEntry.editable = false
	new_high_score_confirm.emit(NameEntry.text)

func _on_resume_pressed():
	resume.emit()

func _on_pause_quit_pressed():
	quit.emit()

func _on_play_again_pressed():
	reset.emit()

func _on_quit_pressed():
	quit.emit()

func _on_new_high_score_confirm_pressed():
	submit_high_score()

func _on_high_score_name_entry_text_submitted(_new_text):
	submit_high_score()
