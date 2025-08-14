extends Node2D
class_name Pond

@onready var spWater:Sprite2D = $SP_Water

@export var target:int = 0
@export var pondRadius: float = 220
@export var pondDepth: float = 100
@export var pondID: int = 0

#var mat : ShaderMaterial
var xrange: XRange = XRange.new()
var world: World = null

@rpc("any_peer", "call_local")
func set_poisoned() -> void:
	print(name, ": poisoned")
	$SP_Water.material.set("shader_parameter/poisoned", 1.0)

func _enter_tree() -> void:
	world = get_parent().get_parent().get_parent() as World
	
func _ready() -> void:
	#mat = spWater.material.duplicate()
	#spWater.material = mat
	spWater.material = load("res://Shader/pond.tres")
	xrange.set_from_center(global_position.x, pondRadius)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and target == 1:
		return
	elif not multiplayer.is_server() and target == 0:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession":
		return
	
	if target == null:
		return
	
	if world.game.players[target].inPondID == self.pondID:
		var distance: float = abs(world.game.players[target].global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		world.game.players[target].global_position.y = yInPond

	if world.game.players[target].cannon.inPondID == self.pondID:
		var distance: float = abs(world.game.players[target].cannon.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		world.game.players[target].cannon.global_position.y = yInPond
