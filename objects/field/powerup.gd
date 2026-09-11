class_name Powerup extends Collectible

@export var powerup_data : PowerupData

func set_powerup_data(new_data : PowerupData):
	powerup_data = new_data
	Sprite.texture = powerup_data.sprite
	Sprite.region_enabled = false
