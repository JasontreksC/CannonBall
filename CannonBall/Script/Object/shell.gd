extends Node2D
class_name Shell

var p0: Vector2 = Vector2.ZERO
var v0: float = 0
var theta0: float = 0
var t: float = 0

var isFalling: bool = false
var alive = true
var shellType: int = 0 # 일반탄 0, 화염탄 1, 독탄 2
var launcher: int = 0

signal land_event

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	
	t += delta
	var x = v0 * cos(theta0) * t
	var y = v0 * sin(theta0) * t - 0.5 * SceneManager.G * pow(t, 2)
	y *= -1
	
	if ((p0.y + y) - global_position.y) < 0:
		isFalling = false
	else:
		isFalling = true
	
	global_position = p0 + Vector2(x, y)		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.get_meta("tag") == "field" and isFalling:
		alive = false
		emit_signal("land_event", Vector2(global_position.x, -50), shellType, launcher)
