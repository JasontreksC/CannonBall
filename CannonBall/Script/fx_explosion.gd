extends Node2D

@onready var gpuSmoke: GPUParticles2D = $Smoke
@onready var blink: Node2D = $FxBlink

var game: Game = null

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gpuSmoke.emitting = true
	gpuSmoke.one_shot = true
	
	var blinkAmp: AnimationPlayer = blink.get_node("AnimationPlayer")
	blinkAmp.play("blink_stronger")
	
func _on_smoke_finished() -> void:
	game.rpc("delete_object", self.name)
