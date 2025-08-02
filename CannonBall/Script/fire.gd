extends Node2D

@onready var particle: GPUParticles2D = $GPUParticles2D
var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	particle.one_shot = false
	particle.emitting = true
	
	if multiplayer.is_server():
		game.regist_lifetime(self.name, 4, 0)

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	particle.one_shot = true
	particle.emitting = false

func _on_gpu_particles_2d_finished() -> void:
	print("fire effect deleted")
	game.delete_object(self.name)
