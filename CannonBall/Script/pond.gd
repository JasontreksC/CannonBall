extends Node2D
class_name Pond

@export var effetivePlayer:int = 0
@export var pondRadius: float = 220
@export var pondDepth: float = 100
@export var pondID: int = 0

var leftX: float
var rightX: float

var world: World = null
var target: Player = null

func _enter_tree() -> void:
	world = get_parent().get_parent().get_parent() as World
	
func _ready() -> void:
	leftX = global_position.x - pondRadius
	rightX = global_position.x + pondRadius

func _physics_process(delta: float) -> void:
	if multiplayer.is_server() and effetivePlayer == 1:
		return
	elif not multiplayer.is_server() and effetivePlayer == 0:
		return
	if world.game.stateMachine.current_state_name() == "WaitSession":
		return
	
	if target == null:
		return
	
	if target.inPondID == self.pondID:
		var distance: float = abs(target.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		target.global_position.y = yInPond

	if target.cannon.inPondID == self.pondID:
		var distance: float = abs(target.cannon.global_position.x - self.global_position.x)
		var t: float = inverse_lerp(pondRadius, 0, distance)
		var yInPond: float = lerp(0.0, pondDepth, t)
		target.cannon.global_position.y = yInPond

func in_range(targetX: float) -> bool:
	return targetX > leftX and targetX < rightX

func substract_area_x(origin: Vector2) -> Vector2:
	if in_range(origin.x): ## 왼쪽 끝이 연못 안에
		origin.x = rightX

	if in_range(origin.y): ## 오른쪽 끝이 연못 안에
		origin.y = leftX

	return origin
