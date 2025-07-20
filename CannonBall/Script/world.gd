extends Node2D
class_name WorldScape

@onready var ground: Node2D = $Ground

@export var groundTexture: CompressedTexture2D
@export_range(400, 10000, 400) var volume: int
	
var worldLeftEnd: int
var worldRightEnd: int

func generate_ground():
	worldLeftEnd = volume / 2 * -1
	worldRightEnd = volume / 2
	
	var groundSprites = ground.get_children()
	for g in groundSprites:
		g.free()
		
	for x in range(worldLeftEnd, worldRightEnd, 200):
		var groundSprite = Sprite2D.new()
		groundSprite.texture = groundTexture
		groundSprite.scale = Vector2(2, 2)
		groundSprite.position = Vector2(x + 100, 100)
		ground.add_child(groundSprite)

func _ready() -> void:
	generate_ground()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
