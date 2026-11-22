class_name BreakLinePowerup extends PowerupData

func activate(player : Player):
	if player.target_block == null: return
	
	print("Activating break line powerup!")
	var cur_target = player.target_block
	player.target_block = cur_target.line.get_back_block()
	player.break_all_blocks = true
	player.s_finished_dash.connect(cleanup)
	player.initiate_dash()

func cleanup(player : Player):
	player.s_finished_dash.disconnect(cleanup)
	player.break_all_blocks = false
	player.finished_use_powerup()
	pass
