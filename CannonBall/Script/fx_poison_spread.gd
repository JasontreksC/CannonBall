extends Node2D

@onready var gpuPoisonSpread1: GPUParticles2D = $PoisonSpread1
@onready var gpuPoisonSpread2: GPUParticles2D = $PoisonSpread2

var game: Game = null
var finished: int = 0

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gpuPoisonSpread1.one_shot = true
	gpuPoisonSpread1.emitting = true
	gpuPoisonSpread1.restart()
	
	gpuPoisonSpread2.one_shot = true
	gpuPoisonSpread2.emitting = true
	gpuPoisonSpread2.restart()
	
func _process(delta: float) -> void:
	if finished == 2:
		game.rpc("delete_object", self.name)
		finished += 1

func _on_poison_spread_1_finished() -> void:
	finished += 1
	
func _on_poison_spread_2_finished() -> void:
	finished += 1
