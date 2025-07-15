extends Node2D

@onready var particle: GPUParticles2D = $GPUParticles2D
var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func activate():
	particle.one_shot = true
	particle.emitting = true

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	activate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not particle.emitting:
		game.delete_object(self.name)
