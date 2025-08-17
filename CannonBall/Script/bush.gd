extends Node2D
class_name Bush

@export var target:int = 0
@export var bushRadius: float = 300

@export var psFxFlame: PackedScene
@export var psFxSmoke: PackedScene

@onready var spBush: Sprite2D = $SP_Bush
@onready var world: World = $"../../.."

@onready var nBurnSpots: Node2D = $BurnFxSpots

var xrange: XRange = XRange.new()
var isBurning: bool = false

func start_burn() -> void:
	if not multiplayer.is_server():
		return

	if isBurning:
		return

	world.game.regist_lifeturn(self.get_path(), 4)

	var spots: Array[Node] = nBurnSpots.get_children()
	for s: Node2D in spots:
		var fxf = world.game.server_spawn_directly(psFxFlame, "none", {
			"global_position": s.global_position
		})
		world.game.regist_lifeturn(fxf.get_path(), 4)
		
		var fxs = world.game.server_spawn_directly(psFxSmoke, "none", {
			"global_position": s.global_position
		})
		world.game.regist_lifeturn(fxs.get_path(), 4)
	
	isBurning = true
	
@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	print("bush deleted!")
	queue_free()
	# world.game.delete_object(get_path())


func _ready() -> void:
	xrange.set_from_center(global_position.x, bushRadius)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and target == 1:
		return
	elif not multiplayer.is_server() and target == 0:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession" or world.game.stateMachine.current_state_name() == "EndSession":
		return

	if xrange.in_range(world.game.players[target].global_position.x):
		spBush.modulate.a = 0.5
	elif xrange.in_range(world.game.players[target].cannon.global_position.x):
		spBush.modulate.a = 0.5
	else:
		spBush.modulate.a = 1.0
