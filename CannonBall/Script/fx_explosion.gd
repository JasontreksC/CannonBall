extends Node2D

@onready var gpuRadialLeft: GPUParticles2D = $RadialLeft
@onready var gpuRadialRight: GPUParticles2D = $RadialRight
@onready var gpuSmoke: GPUParticles2D = $Smoke
@onready var blink: Node2D = $FxBlink

@export var direction: Vector2

var game: Game = null
var smokeScaleFactor: float = 1.0

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gpuRadialLeft.emitting = true
	gpuRadialLeft.one_shot = true
	gpuRadialRight.emitting = true
	gpuRadialRight.one_shot = true

	gpuSmoke.emitting = true
	gpuSmoke.one_shot = true
	
	var blinkAmp: AnimationPlayer = blink.get_node("AnimationPlayer")
	blinkAmp.play("blink")
	
	var d: float = direction.dot(Vector2.RIGHT)
	if d > 0:
		#var ppm: ParticleProcessMaterial = gpuRadialRight.process_material
		#ppm.
		gpuRadialRight.process_material.set("initial_velocity_min", 500 + 1000 * d)
		gpuRadialRight.process_material.set("initial_velocity_max", 1000 + 1000 * d)
		gpuRadialLeft.process_material.set("initial_velocity_min", 500)
		gpuRadialLeft.process_material.set("initial_velocity_max", 1000)
	else:
		gpuRadialLeft.process_material.set("initial_velocity_min", 500 + 1000 * abs(d))
		gpuRadialLeft.process_material.set("initial_velocity_max", 1000 + 1000 * abs(d))
		gpuRadialRight.process_material.set("initial_velocity_min", 500)
		gpuRadialRight.process_material.set("initial_velocity_max", 1000)
	
func _process(delta: float) -> void:
	pass
	
