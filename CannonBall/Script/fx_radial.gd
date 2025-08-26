extends Node2D

@export var dir: Vector2
@export var v_min: float = 1000
@export var v_max: float = 1500
@export var s_min: float = 5
@export var s_max: float = 10
@export var mode: int = 0 # 0. 일반, 화염   1. 물 

@onready var gpuRadial: GPUParticles2D = $Radial
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

var game: Game = null

func _enter_tree() -> void:
	game = get_parent() as Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ppm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	match mode:
		0: ## 일반탄, 화염탄. 불꽃 튀기다 검게 변하는 래디얼
			ppm = load("res://Material/ppm_fx_radial_burst.tres")
			gpuRadial.trail_enabled = false
		1: ## 연못에 탄착 시, 물 입자 래디얼
			ppm = load("res://Material/ppm_fx_radial_water.tres")
			gpuRadial.trail_enabled = true
			gpuRadial.trail_lifetime = 0.1
			audio.play()
			
	if ppm == null:
		return
	
	var d: float = dir.dot(Vector2.RIGHT)
	var t: float = inverse_lerp(-1, 1, d)
	var dirX: float = lerp(-0.5, 0.5, t)
	
	ppm.direction.x = dirX
	ppm.initial_velocity_min = v_min
	ppm.initial_velocity_max = v_max
	ppm.scale_min = s_min
	ppm.scale_max = s_max

	gpuRadial.process_material = ppm
	
	gpuRadial.emitting = true
	gpuRadial.one_shot = true
	gpuRadial.restart()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_radial_finished() -> void:
	game.rpc("delete_object", self.name)
