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
var target_player: Player = null

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
	if not is_instance_valid(target_player):
		return
		
	# 연못 진입/출입 판정
	xrange.overlap_test(target_player)
	xrange.overlap_test(target_player.cannon)
	
	# 연못 내에서 y값 조정
	if target_player.inPondID == self.pondID:
		var distance: float = abs(target_player.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		target_player.global_position.y = yInPond

	if target_player.cannon.inPondID == self.pondID:
		var distance: float = abs(target_player.cannon.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		target_player.cannon.global_position.y = yInPond

func on_entered_pond(node: Node2D) -> void:
	if node is Player:
		node.inPondID = self.pondID
		world.game.ui.set_interaction("b_pond", true)
		if isPoisoned:
			world.game.ui.set_interaction("t_pond", true)

		node.asp.stream = node.asPondStep

	if node is Cannon:
		node.inPondID = self.pondID

func on_exited_pond(node: Node2D) -> void:
	if node is Player:
		node.inPondID = 0
		world.game.ui.set_interaction("b_pond", false)
		if isPoisoned:
			world.game.ui.set_interaction("t_pond", false)
		
		node.asp.stream = node.asGroundStep

	if node is Cannon:
		node.inPondID = 0
