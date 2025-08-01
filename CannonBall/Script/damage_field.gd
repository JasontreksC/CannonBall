extends Node2D
class_name DamageField


var attackTo: int = -1
var hitDamage: int = 0
var tickDamage: int = 0  # 틱 대미지 간격은 1초로 고정
var lifetimeCount: int = 0
var range: float = 1000

var game: Game = null
var target: Player = null
@onready var timer: Timer = $Timer

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
	if target == null:
		return
		
	if hitDamage:
		if in_range(target.global_position.x):
			target.get_damage(hitDamage)
			game.ui.rpc("set_hp", attackTo, target.hp)
	
	if tickDamage:
		timer.start(1)
		#game.regist_tick(self.name, 1, Callable(self, "tick"))
	
#func tick():
	#if in_range(target.global_position.x):
		#target.get_damage(tickDamage)
		#game.ui.rpc("set_hp", attackTo, target.hp)
		#print("Tick Damage to: ", target.name)

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	var prop: World.ShellProp = game.world.shellingQueue[self.name]
	
	attackTo = 1 - prop.launcher
	target = game.players[attackTo]
	
	match prop.shellType:
		0: ## 일반탄
			hitDamage = 5
			tickDamage = 0
			lifetimeCount = 0
			range = 600
		1: ## 화염탄
			hitDamage = 0
			tickDamage = 1
			lifetimeCount = 2
			range = 400
		2: ## 독탄
			hitDamage = 3
			tickDamage = 0
			lifetimeCount = 0
			range = 1000
	
	activate()
	
func _process(delta: float) -> void:
	if lifetimeCount <= 0:
		game.delete_object(self.name)


func _on_timer_timeout() -> void:
	if in_range(target.global_position.x):
		target.get_damage(tickDamage)
		game.ui.rpc("set_hp", attackTo, target.hp)
		print("Tick Damage to: ", target.name)
