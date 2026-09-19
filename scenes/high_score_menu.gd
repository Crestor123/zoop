class_name HighScoreMenu extends Control

@export var high_score_record_object : PackedScene

@onready var lblNoScores = $CanvasLayer/NoScoresYet
@onready var Records = $CanvasLayer/MarginContainer/Records

signal back

func populate_scores(scores : Array[HighScoreData]):
	if scores.size() == 0:
		lblNoScores.visible = true
	
	for score_record in scores:
		var new_record : HighScoreRecord = high_score_record_object.instantiate()
		Records.add_child(new_record)
		new_record.initialize(score_record.name, score_record.score)

func _on_back_pressed():
	back.emit()
