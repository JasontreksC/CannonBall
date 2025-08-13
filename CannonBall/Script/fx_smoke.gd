extends Node2D

@onready var particle1: GPUParticles2D = $Particle1
@onready var particle2: GPUParticles2D = $Particle2

var game: Game = null

func _enter_tree() -> void:
	game = get_parent() as Game

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	particle1.emitting = false
	particle2.emitting = false
	
	await get_tree().create_timer(max(particle1.lifetime, particle2.lifetime)).timeout
	game.delete_object(self.name)
