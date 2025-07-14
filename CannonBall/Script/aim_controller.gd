extends Node2D
class_name AimController

# 대포의 자식 노드로 존재하는 이 유틸 노드는
# 조준한 위치로부터 거리를 구해 대포의 발사각을 조정하고
# 이에 맞게 포신의 회전 각도를 구한다.

# 최소/최 발사각. 포물선 운동 공식에 따라 가장 멀리 날아가는 발사각은 45도이다.
@export var minAimAngle : float = -10
@export var maxAimAngle : float = -45

# 대포의 초기 속도. 이 속도를 sin/cos 함수로 x축 방향, y축 방향으로 분해한다.
@export var V0 : float = 2000

# breech는 포신의 가장 안쪽, 즉 포탄의 운동이 시작되는 위치이며
# muzzel은 포구, 즉 포탄이 포신 밖으로 나오는 출구이다.
# 이 노드들을 참조하는 이유는 위치 때문이다.
@onready var cannon: Cannon = $".."
@onready var breech: Node2D = $"../Body/Sprite_barrel/Breech"
@onready var muzzel: Node2D = $"../Body/Sprite_barrel/Muzzel"
@onready var field: Field = $"../../Field"

# 포물선 운동 공식에 의해, 최소 사거리와 최대 사거리가 정해진다. 이것은 V0가 변하지 않는 이상 고정 값이다.
# 다만 최근 조준한 위치까지의 사거리를 기억한다. 이것이 있어야 포신의 회전각이 나온다. 
var minAimRange: float = 0
var maxAimRange: float = 0
var currentAimRange: float = 0
var currentAngle : float = 0# degree

# 포물선 운동의 시작지점인 breech의 글로벌 포지션 반환
func get_breech_pos() -> Vector2:
	return breech.global_position

# 대포의 조준 상호작용 시 만원경으로 바라보는 UI 발생, 방향키 조작으로 currentAimRange를 증감시킨다.
# breech의 x좌표에 currentAimRange를 더해 조준한 위치에 대한 글로벌 x좌표를 반환
func aim(dir: float, speed: float, delta: float) -> float:
	if not multiplayer.is_server():
		dir *= -1
	
	currentAimRange += dir * speed * delta
	currentAimRange = clamp(currentAimRange, minAimRange, maxAimRange)	
	
	if multiplayer.is_server():
		return breech.global_position.x + currentAimRange
	else:
		return breech.global_position.x - currentAimRange

# currentAimRange를 기반으로, 그 위치에 포탄이 도달하기 위한 발사각을 구한다. 반환값은 radian 값이다.
func get_aimed_theta() -> float:
	var theta = asin(cannon.game.G * currentAimRange / pow(V0, 2)) / 2
	if multiplayer.is_server():
		return theta
	else:
		return -theta - PI
		
func _ready() -> void:
	# 최대/최소 사거리 구하기
	minAimRange = pow(V0, 2) * sin(2*deg_to_rad(abs(minAimAngle))) / cannon.game.G
	maxAimRange = pow(V0, 2) * sin(2*deg_to_rad(abs(maxAimAngle))) / cannon.game.G
	currentAimRange = minAimRange
