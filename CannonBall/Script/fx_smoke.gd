extends Node2D

@onready var particle1: GPUParticles2D = $Particle1
@onready var particle2: GPUParticles2D = $Particle2

@export var smokeAmount: int = 50
@export var smokeLifetime: float = 3.0
@export var spawnBox: Vector2 = Vector2(50, 50)
@export var upAccell: float = -100 

var mat: ParticleProcessMaterial
var game: Game = null

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready():
	particle1.amount = smokeAmount
	particle2.amount = smokeAmount
	particle1.lifetime = smokeLifetime
	particle2.lifetime = smokeLifetime
	
	mat = particle1.process_material.duplicate()
	mat.set("gravity/y", upAccell)
	mat.set("emission_box_extents", Vector3(spawnBox.x, spawnBox.y,  0))

	particle1.process_material = mat
	particle2.process_material = mat

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	particle1.emitting = false
	particle2.emitting = false
	
	await get_tree().create_timer(max(particle1.lifetime, particle2.lifetime)).timeout
	game.rpc("delete_object", self.name)
	# game.delete_object(self.name)
