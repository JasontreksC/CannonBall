extends Node2D

# 격발 이벤트 - 탄환을 생성 및 운동함
# 탄착 이벤트 - 피격 범위를 생성 및 유지함. 이펙트를 발생시킴

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ShellingSystem.field = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
