extends Node2D
class_name HitDamageField

## SERVER ONLY: 서버에서만 작동하는 객체

var target: int = -1
var type: int
var xrange: XRange = XRange.new()

var hitDamage: int = 0
var lifetime: float = 0.0

var game: Game = null
@onready var timer: Timer = $Timer

func activate():
	if lifetime <= 0:
		if xrange.in_range(game.players[target].global_position.x):
			game.players[target].rpc("get_damage", hitDamage, type)
		queue_free()
	else:
		timer.one_shot = true
		timer.start(lifetime)

func _enter_tree() -> void:
	game = get_parent().get_parent() as Game

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not timer.is_stopped():
		if xrange.in_range(game.players[target].global_position.x):
			game.players[target].rpc("get_damage", hitDamage, type)
			timer.stop()
			queue_free()

func _on_timer_timeout() -> void:
	queue_free()
