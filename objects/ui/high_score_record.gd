class_name HighScoreRecord extends Control

@onready var lblName = $PanelContainer/HBoxContainer/Name
@onready var lblScore = $PanelContainer/HBoxContainer/Score

func initialize(score_name : String, score : int):
	lblName.text = score_name
	lblScore.text = str(score)
	pass
