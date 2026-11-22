class_name HighScores extends Node

const SAVE_FILE : String = "user://high_scores.tres"

@export var score_count : int = 5

var high_scores : Array[HighScoreData]

func _ready():
	load_high_scores()

func check_score(score : int) -> bool:
	if score == 0: return false
	
	if high_scores.size() < score_count:
		return true
		
	for score_i : HighScoreData in high_scores:
		var score_value = score_i.score
		if score > score_value: return true
		
	return false

func add_high_score(score_name : String, score : int):
	var new_high_score = HighScoreData.new()
	new_high_score.name = score_name
	new_high_score.score = score
	
	if high_scores.size() < score_count:
		high_scores.append(new_high_score)
	else:
		for high_score_record in high_scores:
			if score > high_score_record.score:
				high_scores.append(new_high_score)
				break
			
	sort_high_scores()
	
	if high_scores.size() > score_count:
		high_scores.pop_back()
		
	save_high_scores()
	
func sort_high_scores():
	high_scores.sort_custom(
		func(a : HighScoreData, b : HighScoreData):
			return a.score > b.score
	)

func load_high_scores():
	if !FileAccess.file_exists(SAVE_FILE): return
	print("loading data from ", SAVE_FILE)
	var loaded_file : HighScoreSave = ResourceLoader.load(SAVE_FILE) as HighScoreSave
	high_scores = loaded_file.scores
	sort_high_scores()

func save_high_scores():
	var new_save : HighScoreSave = HighScoreSave.new()
	new_save.scores = high_scores.duplicate()
	
	var error = ResourceSaver.save(new_save, SAVE_FILE)
	if error == OK:
		print("Saving data to ", SAVE_FILE)
	else:
		print("Saving failed.")
