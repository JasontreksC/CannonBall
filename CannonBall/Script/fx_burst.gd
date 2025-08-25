extends Node2D

@export var direction: Vector2 = Vector2(1, 0)

@onready var gpSmoke: GPUParticles2D = $GP_Smoke
@onready var gpFlame: GPUParticles2D = $GP_Flame
@onready var fxBlink: Node2D = $FxBlink

var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gpSmoke.process_material.set("direction", Vector3(direction.x, direction.y, 0))
	gpFlame.process_material.set("direction", Vector3(direction.x, direction.y, 0))
	
	gpFlame.one_shot = true
	gpSmoke.one_shot = true
	gpFlame.emitting = true
	gpSmoke.emitting = true
	gpFlame.restart()
	gpSmoke.restart()
	
	var ampBlink: AnimationPlayer = fxBlink.get_child(1)
	ampBlink.play("blink")

func _on_gp_smoke_finished() -> void:
	game.rpc("delete_object", self.name)
