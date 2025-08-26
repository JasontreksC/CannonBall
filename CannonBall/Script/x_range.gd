extends Node
class_name XRange

var id: String
var centerX: float
var leftX: float
var rightX: float
var radius: float

var game: Game = null

signal on_entered(target: Node2D)
signal on_exited(target: Node2D)

func set_from_center(centerX_: float, radius_: float) -> void:
	self.centerX = centerX_
	self.radius = radius_
	self.leftX = centerX - radius_
	self.rightX = centerX + radius_

func refresh() -> void:
	centerX = (leftX + rightX) / 2
	radius = (rightX - leftX) / 2

func in_range(targetX: float) -> bool:
	return targetX > leftX and targetX < rightX

func is_overlapping(other: XRange) -> bool:
	return in_range(other.leftX) or in_range(other.rightX)

func substract(target: XRange): # 호출자가 차지하는 범위 중 target이 차지하는 범위를 제외
	if in_range(target.leftX):
		rightX = target.leftX
	elif in_range(target.rightX):
		leftX = target.rightX
	refresh()
	
func _init(_id: String="range") -> void:
	id = _id + str(Time.get_ticks_usec())

func overlap_test(target: Node2D) -> bool:
	if target == null:
		return false

	if not target.has_meta(id) and in_range(target.global_position.x):
		target.set_meta(id, 1)
		if on_entered.has_connections():
			on_entered.emit(target)

	elif target.has_meta(id) and not in_range(target.global_position.x):
		target.remove_meta(id)
		if on_exited.has_connections():
			on_exited.emit(target)
	
	elif target.has_meta(id) and in_range(target.global_position.x):
		return true

	return false
