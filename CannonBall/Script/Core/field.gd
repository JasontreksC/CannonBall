extends Node2D
class_name Field
# 격발 이벤트 - 탄환을 생성 및 운동함
# 탄착 이벤트 - 피격 범위를 생성 및 유지함. 이펙트를 발생시킴

@onready var nP1SpawnSpot: Node2D = $P1SpawnSpot
@onready var nP2SpawnSpot: Node2D = $P2SpawnSpot

func get_spawn_spot(tag: String) -> Vector2:
	match tag:
		"p1":
			return nP1SpawnSpot.global_position
		"p2":
			return nP2SpawnSpot.global_position
		_:
			return Vector2.ZERO

func _ready() -> void:
	ShellingSystem.field = self
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass
