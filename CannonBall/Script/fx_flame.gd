extends Node2D
@onready var shaker: ShakerComponent = $ShakerComponent
@onready var spMainFlame: Sprite2D = $MainFlame
var flame_shake: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	spMainFlame.material.set("shader_parameter/emission", shaker.shakerProperty[0].get_value(0))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
