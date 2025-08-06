extends Node2D
class_name Bush

@export var effetivePlayer:int = 0
@export var bushRange: float = 600

@onready var spBush: Sprite2D = $SP_Bush
@onready var world: World = $"../../.."

var leftX: float
var rightX: float

var target: Player = null

func _ready() -> void:
	leftX = global_position.x - bushRange / 2
	rightX = global_position.x + bushRange / 2

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and not effetivePlayer == 0:
		return
	elif not multiplayer.is_server() and not effetivePlayer == 1:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession":
		return

	if target == null:
		target = world.game.players[effetivePlayer]
		return

	if in_range(target.global_position.x):
		spBush.modulate.a = 0.5
	elif in_range(target.cannon.global_position.x):
		spBush.modulate.a = 0.5
	else:
		spBush.modulate.a = 1.0
	
func in_range(targetX: float) -> bool:
	return targetX > leftX and targetX < rightX
				
func _process(delta: float) -> void:
	pass
