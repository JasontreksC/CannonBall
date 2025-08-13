extends Node2D
class_name TickDamageField

## SERVER ONLY: 서버에서만 작동하는 객체
var target: int = -1
var type: int
var xrange: XRange = XRange.new()

var tickDamage: int = 0  # 틱 대미지 간격은 1초로 고정
var tickInterval: float = 0
var lifeturn: int = 0

var world: World = null
@onready var timer: Timer = $Timer

func activate():
	if target != -1:
		timer.start(tickInterval)

func _enter_tree() -> void:
	world = get_parent().get_parent() as World

func _ready() -> void:
	pass
	
func _on_timer_timeout() -> void:
	if xrange.in_range(world.game.players[target].global_position.x):
		world.game.players[target].rpc("get_damage", tickDamage, type)
