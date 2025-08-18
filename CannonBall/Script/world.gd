extends Node2D
class_name World
	
# 격발 이벤트 - 탄환을 생성 및 운동함
# 탄착 이벤트 - 피격 범위를 생성 및 유지함. 이펙트를 발생시킴
# 시간 시스템 - 서버에서 시간을 재면서 게임 시간 누적 -> ui 표시
# 턴제 시스템 - 플레이어가 공격을 할때마다 턴 전환, 플레이어에게 공격인지 수비인지 전달함
@onready var nP1SpawnSpot: Node2D = $P1SpawnSpot
@onready var nP2SpawnSpot: Node2D = $P2SpawnSpot
@onready var nP1Ponds: Node2D = $BenefitFields/P1Ponds
@onready var nP2Ponds: Node2D = $BenefitFields/P2Ponds
@onready var nP1Bushes: Node2D = $BenefitFields/P1Bushes
@onready var nP2Bushes: Node2D = $BenefitFields/P2Bushes
@onready var dfPool: Node2D = $DamageFields

var game: Game = null

func get_spawn_spot(tag: String) -> Vector2:
	match tag:
		"p1":
			return nP1SpawnSpot.global_position
		"p2":
			return nP2SpawnSpot.global_position
		_:
			return Vector2.ZERO

@rpc("any_peer", "call_local")
func start_shelling(shellType: int, shellPath: String, p0: Vector2, v0: float, theta0: float, launcher: int) -> void:
	if not multiplayer.is_server():
		return
	
	var shell: Shell = game.server_spawn_directly(load(shellPath), "none", {
		"shellType": shellType,
		"p0": p0,
		"v0": v0,
		"theta0": theta0,
		"launcher": launcher
	})

	match shellType:
		0:
			var fxSmoke: Node2D = game.server_spawn_directly(load("res://Scene/fx_smoke.tscn"), "none", {
				"attatch" : shell.name,
				"smokeAmount" : 200,
				"smokeLifetime" : 5.0,
				"upAccell" : 0,
				"smokeScaleFactor" : 2
			})
			shell.attatchedFx.append(fxSmoke.name)
		1:
			var fxSmoke: Node2D = game.server_spawn_directly(load("res://Scene/fx_smoke.tscn"), "none", {
				"attatch" : shell.name,
				"smokeAmount" : 200,
				"smokeLifetime" : 5.0,
				"upAccell" : 0,
				"smokeScaleFactor" : 2
			})
			shell.attatchedFx.append(fxSmoke.name)
		2:
			pass
	
	shell.rpc_id(multiplayer.get_remote_sender_id(), "on_spawned")

func gen_HDF(xr: XRange, type: int, target: int, hitDamage: int, lifetime: float) -> HitDamageField:
	var psHDF: PackedScene = load("res://Scene/hit_damage_field.tscn")
	var hdf: HitDamageField = psHDF.instantiate()

	hdf.xrange = xr
	hdf.type = type
	hdf.target = target
	hdf.hitDamage = hitDamage
	hdf.lifetime = lifetime
	
	dfPool.add_child(hdf)
	return hdf

func gen_TDF(xr: XRange, target: int, tickDamage: int, tickInterval: float, lifeturn: int) -> TickDamageField:
	var psTDF: PackedScene = load("res://Scene/tick_damage_field.tscn")
	var tdf: TickDamageField = psTDF.instantiate()

	tdf.xrange = xr
	tdf.target = target
	tdf.tickDamage = tickDamage
	tdf.tickInterval = tickInterval
	tdf.lifeturn = lifeturn

	dfPool.add_child(tdf)
	return tdf

func _ready() -> void:
	game = get_parent() as Game

func _physics_process(delta: float) -> void:
	if game.stateMachine.current_state_name() == "WaitSession" or game.stateMachine.current_state_name() == "EndSession":
		return

	var ponds: Array[Node]
	var bushes: Array[Node]

	if multiplayer.is_server():	
		ponds = nP1Ponds.get_children()
		bushes = nP1Bushes.get_children()
	else:
		ponds = nP2Ponds.get_children()
		bushes = nP2Bushes.get_children()
	
	# 연못 검사: 플레이어
	for p: Pond in ponds:
		if p.xrange.in_range(game.players[p.target].global_position.x):
			game.players[p.target].inPondID = p.pondID
			break
		else:
			game.players[p.target].inPondID = 0
	
	# 연못 검사: 대포
	for p: Pond in ponds:
		if p.xrange.in_range(game.players[p.target].cannon.global_position.x):
			game.players[p.target].cannon.inPondID = p.pondID
			break
		else:
			game.players[p.target].cannon.inPondID = 0

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return

func on_turn_count():
	if not multiplayer.is_server():
		return
	
	var dfs: Array[Node] = game.world.dfPool.get_children()
	for df in dfs:
		if df is TickDamageField:
			var lt: int = df.get("lifeturn")
			if lt <= 0:
				df.queue_free()
			else:
				df.set("lifeturn", lt - 1)
