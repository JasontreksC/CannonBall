extends Node2D

var attatch: String
@onready var gpuPoison: GPUParticles2D = $GPUParticles2D

var mat: ParticleProcessMaterial
var game: Game = null


func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mat = gpuPoison.process_material
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game.has_node(attatch):
		self.global_position = game.get_node(attatch).global_position

@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	gpuPoison.emitting = false
	
	await get_tree().create_timer(gpuPoison.lifetime).timeout
	game.rpc("delete_object", self.name)
