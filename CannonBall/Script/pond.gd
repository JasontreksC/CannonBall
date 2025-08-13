extends Node2D
class_name Pond

@export var effetivePlayer:int = 0
@export var pondRadius: float = 220
@export var pondDepth: float = 100
@export var pondID: int = 0

var xrange: XRange = XRange.new()
var world: World = null
var target: Player = null

@rpc("any_peer", "call_local")
func set_poisoned() -> void:
	$SP_Water.material.set("shader_parameter/poisoned", 1.0)

func _enter_tree() -> void:
	world = get_parent().get_parent().get_parent() as World
	
func _ready() -> void:
	xrange.set_from_center(global_position.x, pondRadius)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and effetivePlayer == 1:
		return
	elif not multiplayer.is_server() and effetivePlayer == 0:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession":
		return
	
	if target == null:
		return
	
	if target.inPondID == self.pondID:
		var distance: float = abs(target.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		target.global_position.y = yInPond

	if target.cannon.inPondID == self.pondID:
		var distance: float = abs(target.cannon.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		target.cannon.global_position.y = yInPond
