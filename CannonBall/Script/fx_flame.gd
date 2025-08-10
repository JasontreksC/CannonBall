extends Node2D
@onready var shaker: ShakerComponent = $ShakerComponent
@onready var spMainFlame: Sprite2D = $MainFlame
var flame_shake: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	#var value: float = shaker.shakerProperty[0].get_value(0)
	print(shaker.shakerProperty[0].get_value(0))
	
	spMainFlame.material.set("shader_parameter/emission", shaker.shakerProperty[0].get_value(0))
	#var mat: ShaderMaterial = spMainFlame.material
	#mat.set_shader_parameter("emission", shaker.shakerProperty[0].get_value(0))
	#print(flame_shake)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
