extends Node2D
class_name Field
# 격발 이벤트 - 탄환을 생성 및 운동함
# 탄착 이벤트 - 피격 범위를 생성 및 유지함. 이펙트를 발생시킴

@onready var parabola: Parabola = $Parabola
@onready var nP1SpawnSpot: Node2D = $P1SpawnSpot
@onready var nP2SpawnSpot: Node2D = $P2SpawnSpot

var shell_scene = preload("res://Scene/Object/shell.tscn")
var shell_instance: Shell = null

func get_spawn_spot(tag: String) -> Vector2:
	match tag:
		"p1":
			return nP1SpawnSpot.global_position
		"p2":
			return nP2SpawnSpot.global_position
		_:
			return Vector2.ZERO
			
func start_shelling(start_pos: Vector2, theta0: float, v0: float) -> void:
	if shell_instance:
		print("Still Shelling!")
		return
		
	shell_instance = shell_scene.instantiate()
	add_child(shell_instance)
	shell_instance.global_position = start_pos
	parabola.start_parabola("shelling", shell_instance, start_pos, v0, theta0)
	parabola.result_parabola("shelling", -50, on_shelling_landed)


func on_shelling_landed():
	print("landed!")
	shell_instance.free()
	parabola.pool.erase("shelling")

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	pass
