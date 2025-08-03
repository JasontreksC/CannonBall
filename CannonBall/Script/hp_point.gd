extends Node2D
class_name HPPoint

@onready var shaker: ShakerComponent2D = $ShakerComponent2D
@onready var sprite: Sprite2D = $ShakerComponent2D/Sprite2D
@onready var amp: AnimationPlayer = $AnimationPlayer

var vitality: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat: ShaderMaterial = sprite.material
	mat.set_shader_parameter("inner_ratio", 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func kill():
	vitality = false
	shaker.play_shake()
	var mat: ShaderMaterial = sprite.material
	mat.set_shader_parameter("inner_ratio", 0)

func generate():
	vitality = true
	amp.play("generate")
