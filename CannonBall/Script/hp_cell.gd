extends Node2D
class_name HPCell

@onready var shaker: ShakerComponent2D = $ShakerComponent2D
@onready var sprite: Sprite2D = $ShakerComponent2D/Sprite2D
@onready var amp: AnimationPlayer = $AnimationPlayer

var vitality: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mat := ShaderMaterial.new()
	mat.shader = preload("res://Shader/hp_point.gdshader").duplicate()
	mat.set_shader_parameter("inner_ratio", 0)
	mat.set_shader_parameter("inner_color", Color(1, 0, 0))
	mat.set_shader_parameter("outter_color", Color(0.25, 0, 0))
	sprite.material = mat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func kill():
	vitality = false
	shaker.play_shake()
	var mat: ShaderMaterial = sprite.material
	sprite.material.set("shader_parameter/inner_color", Color(1, 0.8, 0.8))

	await get_tree().create_timer(3).timeout
	create_tween().tween_property(mat, "shader_parameter/inner_ratio", 0, 0.25).set_ease(Tween.EASE_IN)

func generate():
	vitality = true
	amp.play("generate")
