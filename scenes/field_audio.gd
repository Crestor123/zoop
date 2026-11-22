extends AudioStreamPlayer2D

@export var sfx_explosion : AudioStreamMP3
@export var sfx_bonus : AudioStreamMP3
@export var sfx_gameover : AudioStreamMP3

func _ready():
	randomize()

func play_explosion():
	stream = sfx_explosion
	play()
	
func play_bonus():
	stream = sfx_bonus
	reset_pitch()
	play()
	
func play_gameover():
	stream = sfx_gameover
	reset_pitch()
	play()

func adjust_pitch(multiplier : int):
	pitch_scale = max(1.0 - (multiplier * 0.2), 0.5)
	
func reset_pitch():
	pitch_scale = 1.0
