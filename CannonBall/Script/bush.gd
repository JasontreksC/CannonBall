extends Node2D
class_name Bush

@export var effetivePlayer:int = 0
@export var bushRange: float = 600

@onready var spBush: Sprite2D = $SP_Bush

var leftX: float
var rightX: float

var world: World = null
var target: Player = null

func _enter_tree() -> void:
	world = get_parent().get_parent() as World

func _ready() -> void:
	leftX = global_position.x - bushRange / 2
	rightX = global_position.x + bushRange / 2

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and not effetivePlayer == 0:
		return
	elif not multiplayer.is_server() and not effetivePlayer == 1:
		return
		
	if not world.game.gameStarted:
		return

	if target == null:
		target = world.game.players[effetivePlayer]
	elif in_range(target.global_position.x):
		spBush.modulate.a = 0.5
	
func in_range(targetX: float) -> bool:
	return targetX > leftX and targetX < rightX
				
func _process(delta: float) -> void:
	pass
