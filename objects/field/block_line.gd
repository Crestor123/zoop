class_name BlockLine extends Node2D

@onready var Collectibles = $Collectibles

@export var block_object : PackedScene
@export var powerup_object : PackedScene
@export var direction : Vector2
@export var tile_size : int = 16

var field : Field
var collectibles : Array[Collectible]

func clear():
	collectibles.clear()
	for item in Collectibles.get_children():
		item.queue_free()

func create_block():
	var new_block : Block = block_object.instantiate()
	Collectibles.add_child(new_block)
	new_block.line = self
	new_block.next_position = new_block.position
	new_block.change_color(randi_range(0, Game.BlockColor.size() - 1))
	new_block.s_destroyed.connect(collectible_destroyed)
	collectibles.append(new_block)
	
	move_collectibles()

func create_powerup(powerup_data : PowerupData):
	var new_powerup : Powerup = powerup_object.instantiate()
	Collectibles.add_child(new_powerup)
	new_powerup.set_powerup_data(powerup_data)
	new_powerup.line = self
	new_powerup.position = new_powerup.position
	new_powerup.s_destroyed.connect(collectible_destroyed)
	collectibles.append(new_powerup)
	
	move_collectibles()

func move_collectibles():
	for collectible : Collectible in Collectibles.get_children():
		collectible.position = collectible.next_position
		collectible.next_position = collectible.next_position + direction * tile_size

func collectible_destroyed(collectible : Collectible):
	collectibles.erase(collectible)
	collectible.remove()
	
	for i in range(collectibles.size()):
		var item = collectibles[i]
		item.next_position = (collectibles.size() - i) * direction * tile_size

## Finds the furthest (closest to the edge of the screen) block from the player of a given color.
## If there is a block behind that one that is the same color, the function returns it instead.
## color : The BlockColor of block to query for. Searches until blocks are no longer this color.
## return : The furthest block of the given color, the block behind it, or the end of the blocks array.
func get_back_block_by_color(color : Game.BlockColor) -> Collectible:
	for i in range(collectibles.size()):
		if collectibles[i] is Powerup:
			return collectibles[i]
		
		if collectibles[i] is Block:
			if collectibles[i].color != color:
				if i < collectibles.size():
					return collectibles[i]
				else:
					return collectibles[i - 1]
	
	return collectibles.back()
	
## Gets the furthest (closest to the edge of the screen) block from the player.
func get_back_block() -> Collectible:
	return collectibles.back()
