extends Node2D
class_name Shell

var shellType: int = 0 # 일반탄 0, 화염탄 1, 독탄 2
var p0: Vector2 = Vector2.ZERO
var v0: float = 0
var theta0: float = 0
var launcher: int = 0

var isFalling: bool = false
var alive = true
var t: float = 0

var game: Game = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	pass

func _enter_tree() -> void:
	game = get_parent() as Game

func _ready() -> void:
	if multiplayer.is_server():
		var prop: World.ShellProp = game.world.shellingQueue[self.name]
		self.shellType = prop.shellType
		self.p0 = prop.p0
		self.v0 = prop.v0
		self.theta0 = prop.theta0
		self.launcher = prop.launcher

func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	## 탄착 여부 판정
	if global_position.y >= -50 and isFalling and alive:
		alive = false
		game.delete_object(self.name)
		game.world.shellingQueue[self.name].land_event.emit(self.name, Vector2(global_position.x, -50))
		return
	## 포물선 운동
	t += delta
	var x = v0 * cos(theta0) * t
	var y = (v0 * sin(theta0) * t - 0.5 * game.G * pow(t, 2)) * -1
	## 떨어지고 있는 중인지 판정
	if ((p0.y + y) - global_position.y) < 0:
		isFalling = false
	else:
		isFalling = true
	
	global_position = p0 + Vector2(x, y)
