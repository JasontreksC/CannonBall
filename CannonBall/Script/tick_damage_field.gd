extends Node2D
class_name TickDamageField

## SERVER ONLY: 서버에서만 작동하는 객체
var target: int = -1
var xrange: XRange = XRange.new()

var tickDamage: int = 0  # 틱 대미지 간격은 1초로 고정
var tickInterval: float = 0
var lifeturn: int = 0

var world: World = null
var target_player: Player = null
@onready var timer: Timer = $Timer

func activate():
	if target != -1:
		timer.start(tickInterval)

func _enter_tree() -> void:
	world = get_parent().get_parent() as World

func _ready() -> void:
	target_player = world.game.players[target]
	
func _on_timer_timeout() -> void:
	if target_player == null:
		return
		
	if xrange.in_range(target_player.global_position.x):
		target_player.rpc("get_damage", tickDamage)
