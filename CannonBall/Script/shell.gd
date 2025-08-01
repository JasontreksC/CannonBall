extends Node2D
class_name Shell

var shellType: int = 0 # 일반탄 0, 화염탄 1, 독탄 2
var p0: Vector2 = Vector2.ZERO
var v0: float = 0
var theta0: float = 0
var launcher: int = 0

var isFalling: bool = false
var alive = true
var t: float = 0

var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func land():
	if not multiplayer.is_server():
		return
	
	var df: DamageField = game.server_spawn_directly(load("res://Scene/damage_field.tscn"), "", global_position)
	df.target = game.players[1 - launcher]
	match shellType:
		0: ## 일반탄
			df.hitDamage = 5
			df.tickDamage = 0
			df.lifetimeCount = 0
			df.range = 600
			
			game.rpc("spawn_object", "res://Scene/explosion.tscn", "", global_position)
			
		1: ## 화염탄
			df.hitDamage = 0
			df.tickDamage = 1
			df.lifetimeCount = 2
			df.range = 400
	
			game.rpc("spawn_object", "res://Scene/fire.tscn", "", global_position)
			
		2: ## 독탄
			df.hitDamage = 3
			df.tickDamage = 0
			df.lifetimeCount = 0
			df.range = 1000	
	
	df.activate()
	
	game.rpc("delete_object", self.name)
	game.rpc("transit_game_state", "Turn")

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
		
	## 탄착 여부 판정
	if global_position.y >= -50 and isFalling and alive:
		alive = false
		land()
		return
		
	## 포물선 운동
	t += delta
	var x = v0 * cos(theta0) * t
	var y = -v0 * sin(theta0) * t + 0.5 * game.G * pow(t, 2)
	## 떨어지고 있는 중인지 판정
	if ((p0.y + y) - global_position.y) < 0:
		isFalling = false
	else:
		isFalling = true
	
	global_position = p0 + Vector2(x, y)
