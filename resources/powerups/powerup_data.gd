@abstract class_name PowerupData extends Resource

@export var sprite : AtlasTexture
@export var name : String
@export var palette : Texture2D

@abstract func activate(player : Player)

@abstract func cleanup(player : Player)
