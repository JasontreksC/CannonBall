extends Sprite2D

var emission: float = 20
@onready var fireShell: Shell = $".."
@onready var fireTail: Node2D = $SP_FireTail

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.material = self.material.duplicate()
	self.material.set("shader_parameter/emission", emission)
	fireTail.global_rotation = fireShell.direction.angle() - PI / 2
