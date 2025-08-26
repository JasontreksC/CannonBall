extends Node2D
class_name HitDamageField

## SERVER ONLY: 서버에서만 작동하는 객체

var target: int = -1
var type: int
var xrange: XRange = XRange.new()

var hitDamage: int = 0
var lifetime: float = 0.0

var world: World = null

var target_player: Player = null
@onready var timer: Timer = $Timer

func activate():
	if target_player == null:
		return

	if lifetime <= 0:
		var final_damage: int = range_test_final_damage()
		if final_damage:
			target_player.rpc("get_damage", final_damage)

		queue_free()
	else:
		timer.one_shot = true
		timer.start(lifetime)

func range_test_final_damage() -> int:
	if xrange.in_range(target_player.global_position.x):
		var damage: int = hitDamage
		match type:
			0:
				pass
			1:
				if target_player.inPondID:
					damage /= 2
			2:
				var t: float = inverse_lerp(xrange.radius, 0, abs(target_player.global_position.x - xrange.centerX))
				t = clamp(t, 0, 1)
				if t < 0.5:
					damage /= 2
		return damage
	else:
		return 0

func _enter_tree() -> void:
	world = get_parent().get_parent() as World

func _ready() -> void:
	target_player = world.game.players[target]

func _process(delta: float) -> void:
	if timer.is_stopped():
		return
	
	if target_player == null:
		return

	var final_damage: int = range_test_final_damage()
	if final_damage:
		target_player.rpc("get_damage", final_damage)
		timer.stop()
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
