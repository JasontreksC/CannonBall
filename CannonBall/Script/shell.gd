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
var timeScale: float = 0.75

var isFalling: bool = false
var alive = true
var t: float = 0

var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func search_landed_pond(ponds: Array[Node]) -> Pond:
	for p: Pond in ponds:
		if p.in_range(global_position.x):
			return p
	return null

func search_overlapped_ponds(df: DamageField, ponds: Array[Node]) -> Array[Pond]:
	var overlappedPonds: Array[Pond] = []
	for p: Pond in ponds:
		if df.in_range(p.leftX) or df.in_range(p.rightX):
			overlappedPonds.append(p)
	return overlappedPonds

func search_overlapped_bushes(df: DamageField, bushes: Array[Node]) -> Array[Bush]:
	var overlappedBushes: Array[Bush] = []
	for b: Bush in bushes:
		if df.in_range(b.leftX) or df.in_range(b.rightX):
			overlappedBushes.append(b)
	return overlappedBushes

func land():
	if not multiplayer.is_server():
		return
	
	var pos = Vector2(global_position.x, 0)
	
	var psDF: PackedScene = load("res://Scene/damage_field.tscn")
	var df: DamageField = psDF.instantiate()

	df.global_position = pos
	df.shellType = shellType
	df.target = game.players[1 - launcher]
	df.set_radius(range / 2)

	df.hitDamage = hitDamage
	df.tickDamage = tickDamage
	df.tickInterval = tickInterval
	df.lifetimeTurn = lifetimeTurn

	game.world.dfPool.add_child(df)

	var ponds: Array[Node] 
	var bushes: Array[Node]
	if df.attackTo == 0:
		ponds = game.world.nP1Ponds.get_children() as Array[Node]
		bushes = game.world.nP1Bush.get_children() as Array[Node]
	else:
		ponds = game.world.nP2Ponds.get_children() as Array[Node]
		bushes = game.world.nP2Bush.get_children() as Array[Node]

	match shellType:
		0: ## 일반탄
			var landedPond: Pond = search_landed_pond(ponds)
			if landedPond:
				pass # 연못 탄착 이펙트
			else:
				pass # 일반 탄착 이펙트
			game.server_spawn_directly(spawnableEffects["explo"], "none", {
				"global_position": pos
			})

		1: ## 화염탄
			var landedPond: Pond = search_landed_pond(ponds)
			if landedPond:
				pass # 연못 탄착 이펙트, 틱 대미지 X
			else:
				var overlappedPonds: Array[Pond] = search_overlapped_ponds(df, ponds)

				for p in overlappedPonds: # 대미지 필드에서 연못과 겹치는 부분을 제거 
					var substracted: Vector2 = p.substract_area_x(Vector2(df.leftX, df.rightX))
					df.leftX = substracted.x
					df.rightX = substracted.y
					df.refresh_radius_center()

				var fxFireField = game.server_spawn_directly(spawnableEffects["fire"], "none", {
					"global_position": df.global_position,
					"width": df.radius * 2
				})
				game.regist_lifetime(fxFireField.name, df.lifetimeTurn, 1)
			
	
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
	t += delta * timeScale
	var x = v0 * cos(theta0) * t
	var y = -v0 * sin(theta0) * t + 0.5 * game.G * pow(t, 2)
	## 떨어지고 있는 중인지 판정
	if ((p0.y + y) - global_position.y) < 0:
		isFalling = false
	else:
		isFalling = true
	
	global_position = p0 + Vector2(x, y)
