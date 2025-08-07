extends Node2D
class_name Shell

var shellType: int = 0 # 일반탄 0, 화염탄 1, 독탄 2

@export_category("Damage Field Property")
@export var range: float
@export var hitDamage: float
@export var tickDamage: float
@export var lifetimeTurn: int
@export var tickInterval: float

@export var spawnableEffects: Dictionary[String, PackedScene]

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
	
	var pos = Vector2(global_position.x, 0)
	
	var psDF: PackedScene = load("res://Scene/damage_field.tscn")
	var df: DamageField = psDF.instantiate()
	#var df: DamageField = game.server_spawn_directly(load("res://Scene/damage_field.tscn"), "none", pos)
	df.global_position = pos
	df.attackTo = 1 - launcher
	df.shellType = shellType
	df.target = game.players[1 - launcher]
	df.range = range
	df.hitDamage = hitDamage
	df.tickDamage = tickDamage
	df.tickInterval = tickInterval
	df.lifetimeTurn = lifetimeTurn
	game.world.add_child(df)

	var ponds: Array[Node] 
	var bushes: Array[Node]
	if df.attackTo == 0:
		ponds = game.world.nP1Ponds.get_children()
		bushes = game.world.nP1Bush.get_children()
	else:
		ponds = game.world.nP2Ponds.get_children()
		bushes = game.world.nP2Bush.get_children()
		
	match shellType:
		0: ## 일반탄
			game.server_spawn_directly(spawnableEffects["explo"], "none", {
				"global_position": pos
			})

		1: ## 화염탄
			var drawn: bool = false
			var modified: bool = false
			var modifiedR: float = 0
			var modifiedX: float = 0

			for p: Pond in ponds:
				if p.in_range(pos.x):
					df.tickDamage = 0
					drawn = true
				
				else:
					if p.in_range(pos.x + df.range / 2): ## 오른쪽 끝이 연못 안에
						df.set_right_x(p.leftX)
					else:
						df.set_right_x(pos.x + df.range / 2)
					
					if p.in_range(pos.x - df.range / 2): ## 왼쪽 끝이 연못 안에
						df.set_left_x(p.rightX)
					else:
						df.set_left_x(pos.x - df.range / 2)
						
				#elif abs(p.global_position.x - pos.x) < p.pondRadius + (df.range / 2):
					#modifiedR += clamp(abs(p.leftX - pos.x), 0, 150)
					#modifiedR += clamp(abs(p.rightX - pos.x), 0, 150)
					#
					#if pos.x < p.leftX and abs(p.leftX - pos.x) < 150:
						#df.modify_range_R(p.leftX)
					#elif pos.x > p.rightX and abs(p.rightX - pos.x) < 150:
						#df.modify_range_L(p.rightX)
					#modified = true
					#modifiedR = df.rightX - df.leftX
					#modifiedX = (df.leftX + df.rightX) / 2
	
			if drawn:
				pass
			else:
				game.server_spawn_directly(spawnableEffects["fire"], "none", {
					"global_position": Vector2(df.leftX + df.rightX / 2, 0),
					"extendX": abs(df.leftX - df.rightX) / 2
				})
			
			#if modified:
				#game.server_spawn_directly(spawnableEffects["fire"], "none", {
					#"global_position": Vector2(modifiedX, 0),
					#"extendX": modifiedR
				#})
			#elif drawn:
				#game.server_spawn_directly(spawnableEffects["explo"], "none", {
					#"global_position": pos
				#})
			#else:
				#game.server_spawn_directly(spawnableEffects["fire"], "none", {
					#"global_position": pos
				#})
	
		2: ## 독탄
			game.server_spawn_directly(spawnableEffects["poison"], "none", {
				"global_position": pos
			})
	
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
