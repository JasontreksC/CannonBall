extends Node2D
class_name World
	
# 격발 이벤트 - 탄환을 생성 및 운동함
# 탄착 이벤트 - 피격 범위를 생성 및 유지함. 이펙트를 발생시킴
# 시간 시스템 - 서버에서 시간을 재면서 게임 시간 누적 -> ui 표시
# 턴제 시스템 - 플레이어가 공격을 할때마다 턴 전환, 플레이어에게 공격인지 수비인지 전달함
@onready var nP1SpawnSpot: Node2D = $P1SpawnSpot
@onready var nP2SpawnSpot: Node2D = $P2SpawnSpot

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
	
	var shell: Shell = game.server_spawn_directly(load(shellPath), "", p0)
	print(shell.name)
	shell.shellType = shellType
	shell.p0 = p0
	shell.v0 = v0
	shell.theta0 = theta0
	shell.launcher = launcher
	
@rpc("any_peer", "call_local")
func spawn_effect(pos: Vector2, index: int, path: String) -> void:
	if not multiplayer.is_server():
		return
	var psEffect: PackedScene = load(path)
	var newEffect: Node2D = psEffect.instantiate()
	add_child(newEffect)
	newEffect.global_position = pos
	newEffect.visibility_layer = index
	
	
func _ready() -> void:
	game = get_parent() as Game
		
func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
