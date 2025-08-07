extends Node2D

@onready var particle: GPUParticles2D = $GPUParticles2D
@onready var timer: Timer = $Timer
var extendX: float = 300

var game: Game = null


@rpc("any_peer", "call_local")
func on_spawned() -> void:
	var ppm: ParticleProcessMaterial = particle.process_material
	ppm.emission_box_extents.x = extendX
	particle.restart()

func set_extend(radius: float):
	pass
	#var ppm: ParticleProcessMaterial = particle.process_material
	#ppm.emission_box_extents.x = extendX
	#particle.restart()

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	particle.one_shot = false
	particle.emitting = true
	
	if multiplayer.is_server():
		game.regist_lifetime(self.name, 4, 0)

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	particle.emitting = false
	timer.start(particle.lifetime)

func _on_timer_timeout() -> void:
	game.delete_object(self.name)
