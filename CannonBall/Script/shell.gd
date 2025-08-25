extends Node2D
class_name Shell

enum DamageType {
	ABSOLUTE = 0, # 독탄 (3), 연못에 탄착한 일반탄 화염탄 (1)
	REDUCE_BY_POND = 1, # 연못 피해절감, 화염탄
	REDUCE_BY_DISTANCE = 2 # 거리 비례 피해절감, 일반탄
}


var shellType: int = 0 # 일반탄 0, 화염탄 1, 독탄 2

@export_category("Damage Field Property")
@export var radius: float
@export var hitDamage: int
@export var tickDamage: int
@export var lifetimeTurn: int
@export var tickInterval: float
@export var direction: Vector2

var p0: Vector2 = Vector2.ZERO
var v0: float = 0
var theta0: float = 0
var launcher: int = 0
var timeScale: float = 1.0

var isFalling: bool = false
var alive = true
var t: float = 0

var attatchedFx: Array[String]

var game: Game = null
var sprite: Sprite2D = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func search_landed_pond(ponds: Array[Node]) -> Pond:
	for p: Pond in ponds:
		if p.xrange.in_range(global_position.x):
			return p
	return null

func search_overlapped_ponds(xr: XRange, ponds: Array[Node]) -> Array[Pond]:
	var overlappedPonds: Array[Pond] = []
	for p: Pond in ponds:
		if p.xrange.is_overlapping(xr):
			overlappedPonds.append(p)
	return overlappedPonds

func search_overlapped_bushes(xr: XRange, bushes: Array[Node]) -> Array[Bush]:
	var overlappedBushes: Array[Bush] = []
	for b: Bush in bushes:
		if b.xrange.is_overlapping(xr):
			overlappedBushes.append(b)
	return overlappedBushes

func land():
	if not multiplayer.is_server():
		return
	
	var newXR: XRange = XRange.new()
	newXR.set_from_center(global_position.x, radius)

	# var df: DamageField = game.world.gen_damage_field(pos, shellType, 1 - launcher, range / 2, hitDamage, tickDamage, tickInterval, lifetimeTurn)

	var ponds: Array[Node] 
	var bushes: Array[Node]
	if launcher == 1:
		ponds = game.world.nP1Ponds.get_children() as Array[Node]
		bushes = game.world.nP1Bushes.get_children() as Array[Node]
	else:
		ponds = game.world.nP2Ponds.get_children() as Array[Node]
		bushes = game.world.nP2Bushes.get_children() as Array[Node]

	var landedPond: Pond = search_landed_pond(ponds)
	var overlappedPonds: Array[Pond] = search_overlapped_ponds(newXR, ponds)
	var overlappedBushes: Array[Bush] = search_overlapped_bushes(newXR, bushes)

	var genertated_hdf: HitDamageField = null
	var genertated_tdf: TickDamageField = null

	match shellType: 
		0: ## 일반탄
			if landedPond:
				game.world.gen_HDF(newXR, DamageType.ABSOLUTE, 1 - launcher, 1, 0.0).activate()
				
				game.server_spawn_directly(load("res://Scene/fx_radial.tscn"), "none", {
					"global_position": Vector2(newXR.centerX, 0),
				 	"dir": direction,
					"mode" : 1
				})
			else:
				game.world.gen_HDF(newXR, DamageType.REDUCE_BY_DISTANCE, 1 - launcher, hitDamage, 0.0).activate()
				
				game.server_spawn_directly(load(game.spawner.get_spawnable_scene(5)) as PackedScene, "none", {
					"global_position": Vector2(newXR.centerX, 0)
				})
				game.server_spawn_directly(load("res://Scene/fx_radial.tscn"), "none", {
					"global_position": Vector2(newXR.centerX, 0),
				 	"dir": direction,
					"s_min": 15,
					"s_max": 30,
					"mode" : 0 
				})

		1: ## 화염탄
			if landedPond: # 연못 안에 들어옴
				game.world.gen_HDF(newXR, DamageType.ABSOLUTE, 1 - launcher, 1, 0.0).activate()
				
				game.server_spawn_directly(load("res://Scene/fx_radial.tscn"), "none", {
					"global_position": Vector2(newXR.centerX, 0),
				 	"dir": direction,
					"mode" : 1
				})
			else:		   # 연못 밖
				# 힡 대미지 필드
				game.world.gen_HDF(newXR, DamageType.REDUCE_BY_POND, 1 - launcher, hitDamage, 0.0).activate()

				# 화염 폭발
				game.server_spawn_directly(load("res://Scene/fx_fire_exlposion.tscn"), "none", {
					"global_position": Vector2(newXR.centerX, 0),
				})				
				game.server_spawn_directly(load("res://Scene/fx_radial.tscn"), "none", {
					"global_position": Vector2(newXR.centerX, 0),
				 	"dir": direction,
					"s_min": 15,
					"s_max": 30,
					"mode" : 0 
				})
				
				# 틱 대미지 필드
				newXR.set_from_center(newXR.centerX, newXR.radius / 2)

				if overlappedPonds.size() > 0: # 연못과 겹침
					for p in overlappedPonds: # 대미지 필드에서 연못과 겹치는 부분을 제거
						newXR.substract(p.xrange)

				game.world.gen_TDF(newXR, 1 - launcher, tickDamage, tickInterval, lifetimeTurn).activate()

				# 화염 필드
				var fxFireField = game.server_spawn_directly(load(game.spawner.get_spawnable_scene(6)) as PackedScene, "none", {
					"global_position": Vector2(newXR.centerX, 0),
					"width": newXR.radius * 2
				})
				game.regist_lifeturn(fxFireField.name, lifetimeTurn)

				# 연기 이펙트
				var fxSmoke = game.server_spawn_directly(load(game.spawner.get_spawnable_scene(9)) as PackedScene, "none", {
					"global_position": Vector2(newXR.centerX, 0),
					"smokeAmount": 100,
					"smokeLifetime": 5,
					"spawnBox": Vector2(newXR.radius, 50),
					"upAccell": -150
				})
				game.regist_lifeturn(fxSmoke.name, lifetimeTurn)

				if overlappedBushes.size() > 0: # 덤불과 겹침
					for b in overlappedBushes:
						b.start_burn()          # 덤불 점화 
	
		2: ## 독탄
			if landedPond: # 연못에 탄착
						   # 틱 대미지 (연못 독성화)
				game.world.gen_TDF(landedPond.xrange, 1 - launcher, tickDamage, tickInterval, lifetimeTurn).activate()
				landedPond.rpc("set_poisoned")
				
				game.server_spawn_directly(load("res://Scene/fx_radial.tscn"), "none", {
					"global_position": Vector2(newXR.centerX, 0),
				 	"dir": direction,
					"mode" : 1
				})
			else:
				# 힛 대미지
				game.world.gen_HDF(newXR, DamageType.ABSOLUTE, 1 - launcher, hitDamage, 3).activate()
				game.server_spawn_directly(load(game.spawner.get_spawnable_scene(7)) as PackedScene, "none", {
						"global_position": Vector2(newXR.centerX, 0),
				})
	
	if genertated_hdf:
		genertated_hdf.activate()
	if genertated_tdf:
		genertated_tdf.activate()
	
	for fx: String in attatchedFx:
		if game.has_node(fx):
			game.get_node(fx).rpc("lifetime_end")

	## 카메라 흔들림
	game.players[1 - launcher].rpc("shake_camera", global_position.x, 1000)
	
	game.rpc("delete_object", self.name)
	game.rpc("transit_game_state", "Turn", 3)

func _enter_tree() -> void:
	set_multiplayer_authority(1)
	game = get_parent() as Game

func _ready() -> void:
	sprite = get_child(0) as Sprite2D
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
	
	var new_pos: Vector2 = p0 + Vector2(x, y)
	direction = global_position.direction_to(new_pos)
	global_position = new_pos
