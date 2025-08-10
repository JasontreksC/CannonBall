extends Node2D
class_name Bush

@export var effetivePlayer:int = 0
@export var radius: float = 300

@onready var spBush: Sprite2D = $SP_Bush
@onready var world: World = $"../../.."

var leftX: float
var rightX: float

var target: Player = null

func in_range(targetX: float) -> bool:
	return targetX > leftX and targetX < rightX

@rpc("any_peer", "call_local")
func start_burn() -> void:
	world.game.rpc("regist_lifetime", self.name, 4)

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	world.game.delete_object(self.name)


func _ready() -> void:
	leftX = global_position.x - radius
	rightX = global_position.x + radius

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and effetivePlayer == 1:
		return
	elif not multiplayer.is_server() and effetivePlayer == 0:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession":
		return

	if target == null:
		return

	if in_range(target.global_position.x):
		spBush.modulate.a = 0.5
	elif in_range(target.cannon.global_position.x):
		spBush.modulate.a = 0.5
	else:
		spBush.modulate.a = 1.0
