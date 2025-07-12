extends Node2D
class_name Field

# 격발 이벤트 - 탄환을 생성 및 운동함
# 탄착 이벤트 - 피격 범위를 생성 및 유지함. 이펙트를 발생시킴

@onready var nP1SpawnSpot: Node2D = $P1SpawnSpot
@onready var nP2SpawnSpot: Node2D = $P2SpawnSpot

var shellPool: Array[Shell]
var shellNum: int = 0

func get_spawn_spot(tag: String) -> Vector2:
	match tag:
		"p1":
			return nP1SpawnSpot.global_position
		"p2":
			return nP2SpawnSpot.global_position
		_:
			return Vector2.ZERO

@rpc("any_peer", "call_local")
func start_shelling(start_pos: Vector2, theta0: float, v0: float) -> void:
	if not multiplayer.is_server():
		return
	
	SceneManager.spawn_scene("res://Scene/Object/shell.tscn", self.name, "shell" + str(shellNum))
	var newShell = SceneManager.get_pool(self.name + "_shell" + str(shellNum))
	shellNum += 1
	
	newShell.global_position = start_pos

	newShell.p0 = start_pos
	newShell.v0 = v0
	newShell.theta0 = theta0
	shellPool.append(newShell)
	newShell.connect("land_event", on_shelling_landed)

func on_shelling_landed():
	print("land!")

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	shellPool = shellPool.filter(func(s): return s != null)
	
	for shell: Shell in shellPool:
		if shell.alive == false:
			SceneManager.rpc("delete_scene", shell.name)
			
