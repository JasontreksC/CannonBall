extends Node2D

@onready var spFire: Sprite2D = $SP_Fire
@onready var timer: Timer = $Timer
@export var width: float = 300

var game: Game = null


@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	spFire.material = spFire.material.duplicate()

	spFire.scale.x = width
	spFire.material.set("shader_parameter/w_per_h", spFire.scale.y / spFire.scale.x * 0.2)
	spFire.material.set("shader_parameter/Scale", Vector2(spFire.scale.x / spFire.scale.y, 1.0))

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	game.delete_object(self.name)

# func _on_timer_timeout() -> void:
# 	game.delete_object(self.name)
