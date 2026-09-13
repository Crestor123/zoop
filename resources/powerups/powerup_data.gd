@abstract class_name PowerupData extends Resource

@export var sprite : AtlasTexture
@export var name : String

@abstract func activate(player : Player)

@abstract func cleanup(player : Player)
