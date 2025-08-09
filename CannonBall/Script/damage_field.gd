extends Node2D
class_name DamageField

## SERVER ONLY: 서버에서만 작동하는 객체

var attackTo: int = -1

var shellType: int = -1
	
var radius: float = 0
var leftX: float = 0
var rightX: float = 0
var hitDamage: int = 0
var tickDamage: int = 0  # 틱 대미지 간격은 1초로 고정
var tickInterval: float = 0
var lifetimeTurn: int = 0

var game: Game = null
var target: Player = null
@onready var timer: Timer = $Timer

func set_radius(r: float):
	radius = r
	leftX = global_position.x - radius
	rightX = global_position.x + radius

func refresh_radius_center():
	var range: float = max(rightX - leftX, 0)
	radius = range / 2
	global_position.x = (leftX + rightX) / 2

func in_range(targetX: float) -> bool:
	if targetX > leftX and targetX < rightX:
		return true
	else:
		return false

func activate():
	if target == null:
		print("damage field target null")
		return
		
	if hitDamage:
		if in_range(target.global_position.x):
			target.rpc("get_damage", hitDamage, shellType)
	
	if tickDamage:
		timer.start(tickInterval)
	
	if lifetimeTurn <= 0:
		queue_free()

func _enter_tree() -> void:
	game = get_parent().get_parent() as Game

func _ready() -> void:
	pass
	

func _on_timer_timeout() -> void:
	if in_range(target.global_position.x):
		target.rpc("get_damage", tickDamage,shellType)
