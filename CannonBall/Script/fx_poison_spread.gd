extends Node2D

@onready var particle: GPUParticles2D = $GPUParticles2D
var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particle.one_shot = true
	particle.emitting = true


func _on_gpu_particles_2d_finished() -> void:
	game.rpc("delete_object", self.name)
