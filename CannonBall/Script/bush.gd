extends Node2D
class_name Bush

@export var effetivePlayer:int = 0
@export var bushRadius: float = 300

@export var psFxFlame: PackedScene
@export var psFxSmoke: PackedScene

@onready var spBush: Sprite2D = $SP_Bush
@onready var world: World = $"../../.."

@onready var nBurnSpots: Node2D = $BurnFxSpots

var xrange: XRange = XRange.new()
var target: Player = null

func start_burn() -> void:
	if not multiplayer.is_server():
		return

	world.game.regist_lifetime(self.name, 4)

	var spots: Array[Node] = nBurnSpots.get_children()
	for s: Node2D in spots:
		world.game.server_spawn_directly(psFxFlame, "none", {
			"global_position": s.global_position
		})
		world.game.server_spawn_directly(psFxSmoke, "none", {
			"global_position": s.global_position
		})



@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	world.game.delete_object(self.name)


func _ready() -> void:
	xrange.set_from_center(global_position.x, bushRadius)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and effetivePlayer == 1:
		return
	elif not multiplayer.is_server() and effetivePlayer == 0:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession":
		return

	if target == null:
		return

	if xrange.in_range(target.global_position.x):
		spBush.modulate.a = 0.5
	elif xrange.in_range(target.cannon.global_position.x):
		spBush.modulate.a = 0.5
	else:
		spBush.modulate.a = 1.0
