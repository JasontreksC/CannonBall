extends Node2D
class_name DamageField

var range: float = 1000
var lifetimeCount: int = 0
var attackTo: int = -1

var hitDamage: int = 0
var tickDamage: int = 0 # 틱 대미지 간격은 1초로 고정

var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func in_range(targetX: float) -> bool:
	var left = global_position.x - range / 2
	var right = global_position.x + range / 2
	
	if targetX > left and targetX < right:
		return true
	else:
		return false

func activate():
	if hitDamage:
		var target: Player = game.players[attackTo]
		if target and in_range(target.global_position.x):
			target.hp -= hitDamage
			game.ui.rpc("set_hp", attackTo, target.hp)
			
	if lifetimeCount == 0:
		game.delete_object(self.name)

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
