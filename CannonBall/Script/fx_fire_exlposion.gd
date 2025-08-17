extends Node2D

@onready var gpuFireExplo: GPUParticles2D = $FireExplo

var game: Game = null

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gpuFireExplo.emitting = true
	gpuFireExplo.one_shot = true

func _on_fire_explo_finished() -> void:
	game.rpc("delete_object", self.name)
