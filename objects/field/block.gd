class_name Block extends Collectible

@onready var ColorComp = $ColorComponent

@export var color : Game.BlockColor

## Changes the block's color to the given color.
## new_color: The BlockColor to change to.
func change_color(new_color : Game.BlockColor):
	color = new_color
	ColorComp.set_color(color)

func destroy():
	s_destroyed.emit(self)

func remove():
	queue_free()
