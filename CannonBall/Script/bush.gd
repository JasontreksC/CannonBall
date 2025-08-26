extends Node2D
class_name Bush

@export var target:int = 0
@export var bushRadius: float = 300
@export var psFxFlame: PackedScene
@export var psFxSmoke: PackedScene

@onready var spBush: Sprite2D = $SP_Bush
@onready var nBurnSpots: Node2D = $BurnFxSpots

var xrange: XRange = XRange.new("bush")
var isBurning: bool = false
var world: World = null
var target_player: Player = null

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
	queue_free()


func _enter_tree() -> void:
	world = get_parent().get_parent().get_parent() as World

func _ready() -> void:
	xrange.set_from_center(global_position.x, bushRadius)
	xrange.on_entered.connect(on_entered_bush)
	xrange.on_exited.connect(on_exited_bush)

func _physics_process(_delta: float) -> void:
	# 덤불 진입/출입 판정
	if not is_instance_valid(target_player):
		return
		
	if xrange.overlap_test(target_player) or xrange.overlap_test(target_player.cannon):
		self.modulate.a = 0.5
	else:
		self.modulate.a = 1.0

func on_entered_bush(node: Node2D) -> void:
	if node is Player:
		world.game.ui.set_interaction("b_bush", true)

func on_exited_bush(node: Node2D) -> void:
	if node is Player:
		world.game.ui.set_interaction("b_bush", false)
