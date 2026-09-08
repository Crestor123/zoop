class_name BlockLine extends Node2D

@onready var Blocks = $Blocks

@export var block_object : PackedScene
@export var direction : Vector2
@export var tile_size : int = 16

var blocks : Array[Block]

func create_block():
	var new_block : Block = block_object.instantiate()
	Blocks.add_child(new_block)
	new_block.line = self
	new_block.change_color(randi_range(0, Game.BlockColor.size() - 1))
	new_block.s_destroyed.connect(block_destroyed)
	blocks.append(new_block)
	
	for block : Block in Blocks.get_children():
		var tween = create_tween()
		tween.tween_property(block, "position", block.position + direction * tile_size, 1.0)

func block_destroyed(block : Block):
	blocks.erase(block)
	block.remove()

## Finds the furthest (closest to the edge of the screen) block from the player of a given color.
## If there is a block behind that one, the function returns it instead.
## color : The BlockColor of block to query for. Searches until blocks are no longer this color.
## return : The furthest block of the given color, the block behind it, or the end of the blocks array.
func get_back_block_by_color(color : Game.BlockColor) -> Block:
	for i in range(blocks.size()):
		if blocks[i].color != color:
			if i < blocks.size():
				return blocks[i]
			else:
				return blocks[i - 1]
	
	return blocks.back()
