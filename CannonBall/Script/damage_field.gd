extends Node2D
class_name DamageField

## SERVER ONLY: 서버에서만 작동하는 객체

var attackTo: int = -1

var shellType: int = -1
	
var range: float = 0
var hitDamage: int = 0
var tickDamage: int = 0  # 틱 대미지 간격은 1초로 고정
var tickInterval: float = 0
var lifetimeTurn: int = 0

var game: Game = null
var target: Player = null
@onready var timer: Timer = $Timer



func in_range(targetX: float) -> bool:
	var left = global_position.x - range / 2
	var right = global_position.x + range / 2
	
	if targetX > left and targetX < right:
		return true
	else:
		return false

func activate():
	if target == null:
		print("damage field target null")
		return
		
	if hitDamage:
		if in_range(target.global_position.x):
			#target.get_damage(hitDamage)
			target.rpc("get_damage", hitDamage,shellType)
			#game.ui.rpc("set_hp", attackTo, target.hp)
	
	if tickDamage:
		timer.start(tickInterval)
	
	if lifetimeTurn:
		game.regist_lifetime(self.name, lifetimeTurn, 0)

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	pass
	
@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	game.delete_object(self.name)

func _on_timer_timeout() -> void:
	if in_range(target.global_position.x):
		#target.get_damage(tickDamage)
		target.rpc("get_damage", tickDamage)
		#game.ui.rpc("set_hp", attackTo, target.hp)
		print("Tick Damage to: ", target.name)
