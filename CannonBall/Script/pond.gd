extends Node2D
class_name Pond

@onready var spWater:Sprite2D = $SP_Water

@export var target:int = 0
@export var pondRadius: float = 220
@export var pondDepth: float = 100
@export var pondID: int = 0

#var mat : ShaderMaterial
var isPoisoned: bool = false
var xrange: XRange = XRange.new("pond")
var world: World = null

@rpc("any_peer", "call_local")
func set_poisoned() -> void:
	create_tween().tween_property($SP_Water.material, "shader_parameter/poisoned", 1, 1)
	world.game.regist_lifeturn(self.get_path(), 4)
	isPoisoned = true

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	create_tween().tween_property($SP_Water.material, "shader_parameter/poisoned", 0, 1)
	isPoisoned = false

func _enter_tree() -> void:
	world = get_parent().get_parent().get_parent() as World

func _ready() -> void:
	spWater.material = spWater.material.duplicate()
	xrange.set_from_center(global_position.x, pondRadius)
	xrange.on_entered.connect(on_entered_pond)
	xrange.on_exited.connect(on_exited_pond)

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and target == 1:
		return
	elif not multiplayer.is_server() and target == 0:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession" or world.game.stateMachine.current_state_name() == "EndSession" :
		return
	if world == null || world.game == null || world.game.players[target] == null:
		return
	
	# 연못 진입/출입 판정
	xrange.overlap_test(world.game.players[target])
	xrange.overlap_test(world.game.players[target].cannon)
	
	# 연못 내에서 y값 조정
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

func on_entered_pond(node: Node2D) -> void:
	if node is Player:
		node.inPondID = self.pondID
		world.game.ui.set_interaction("b_pond", true)
		if isPoisoned:
			world.game.ui.set_interaction("t_pond", true)

	if node is Cannon:
		node.inPondID = self.pondID

func on_exited_pond(node: Node2D) -> void:
	if node is Player:
		node.inPondID = 0
		world.game.ui.set_interaction("b_pond", false)
		if isPoisoned:
			world.game.ui.set_interaction("t_pond", false)
	if node is Cannon:
		node.inPondID = 0
