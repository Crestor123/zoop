class_name BreakColorPowerup extends PowerupData

var field : Field
var color : Game.BlockColor

func activate(player : Player):
	player.check_closest_block()
	if player.target_block is not Block: return
	
	print("Activating break color powerup!")
	field = player.target_block.line.field
	color = player.target_block.color
	player.s_finished_forward_dash.connect(break_blocks)
	player.s_finished_dash.connect(cleanup)
	player.break_all_blocks = true
	player.initiate_dash()

func break_blocks(player : Player):
	for line : BlockLine in field.BlockLines.get_children():
		for block : Collectible in line.Collectibles.get_children():
			if block is not Block: continue
			if block.color == color:
				player.s_block_destroyed.emit(block, true)
				block.destroy()

func cleanup(player : Player):
	player.s_finished_dash.disconnect(cleanup)
	player.s_finished_forward_dash.disconnect(break_blocks)
	player.break_all_blocks = false
	player.finished_use_powerup()
	pass
