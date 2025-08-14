extends Node2D

@onready var shaker: ShakerComponent = $ShakerComponent
@onready var spMainFlame: Sprite2D = $MainFlame
@onready var gpuSubFlame: GPUParticles2D = $SubFlame

var game: Game = null
var flame_shake: float

func _enter_tree() -> void:
	game = get_parent() as Game

func _physics_process(delta: float) -> void:
	spMainFlame.material.set("shader_parameter/emission", shaker.shakerProperty[0].get_value(0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
@rpc("any_peer", "call_local")
func lifetime_end() -> void:
	gpuSubFlame.emitting = false
	
	await get_tree().create_timer(gpuSubFlame.lifetime).timeout
	game.rpc("delete_object", self.name)
	# game.delete_object(self.name)
	print("flame deleted")
