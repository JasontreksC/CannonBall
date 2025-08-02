extends Node2D

@onready var particle: CPUParticles2D = $CPUParticles2D
var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	particle.one_shot = false
	particle.emitting = true
	game.regist_lifetime(self.name, 4, 0, stop)

func stop():
	particle.emitting = false
	print("fire emitting stopped")
	
func _on_cpu_particles_2d_finished() -> void:
	game.delete_object(self.name)
