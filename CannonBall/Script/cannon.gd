# 플레이어에 의해 조종되는 대포에 대한 스크립트이다
# 대포 역시 상태 머신으로 분기가 나위어져 있으며
# 대포의 상태 전환은 플레이어에 의해 수동적으로 이루어진다.
extends Node2D
class_name Cannon

var stateMachine: StateMachine = StateMachine.new()

# 이동시 바퀴 회전 처리를 위한 속성을 가진다.
var prevPosX: float = 0
var curVelocity: float = 0
var isInPond: bool = false

const FRONT_WHEEL_RADIUS: float = 72.0
const BACK_WHEEL_RADIUS: float = 42.0
const SPEED: float = 300

@export var shellPathes: Array[String]

# 대포의 각종 파트에 대한 뼈대, 애니메이션 플레이어, 에임 컨트롤러
@onready var nHandle: Node2D = $Handle
@onready var bFrontWheel: Bone2D = $Skeleton2D/BnCarriage/BnFrontWheel
@onready var bBackWheel: Bone2D = $Skeleton2D/BnCarriage/BnBackWheel
@onready var bBarrel: Bone2D = $Skeleton2D/BnCarriage/BnBarrel
@onready var ac: AimController = $AimController
@onready var amp: AnimationPlayer = $AnimationPlayer
@onready var world: World = $"../World"

var game: Game = null
var player: Player = null

@rpc("any_peer", "call_local")
func on_spawned() -> void:
	if multiplayer.is_server():
		player = game.players[0]
	else:
		player = game.players[1]
		
	player.cannon = self

# 손잡이, 즉 플레이어가 대포 조종시 위치하게 될 부분의 x좌표를 반환한다.
func get_handle_x() -> float:
	return nHandle.global_position.x

func update_cur_velocity(delta: float):
	var moved = global_position.x - prevPosX
	var velocity = moved / delta
	prevPosX = global_position.x
	curVelocity = velocity

func rotate_wheel(delta: float):
	# 각속도(degree) = 선속도 / 반지름
	# degree -> radian
	var omegaF = curVelocity / FRONT_WHEEL_RADIUS
	var omegaB = curVelocity / BACK_WHEEL_RADIUS
	if not multiplayer.is_server():
		omegaF *= -1
		omegaB *= -1
	
	bFrontWheel.rotate(deg_to_rad(omegaF))
	bBackWheel.rotate(deg_to_rad(omegaB))

func _enter_tree() -> void:
	game = get_parent() as Game
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not is_multiplayer_authority():
		return
	
	if multiplayer.is_server():
		global_position = world.get_spawn_spot("p1")
		scale.x = 1
	else:
		global_position = world.get_spawn_spot("p2")
		scale.x = -1
		
	prevPosX = global_position.x
	
	stateMachine.register_state("Idle")
	stateMachine.register_state("Aim")
	stateMachine.register_state("Fire")
	
	
	stateMachine.register_transit("Idle", "Aim", 0)
	stateMachine.register_transit("Aim", "Idle", 0)
	stateMachine.register_transit("Aim", "Fire", 0)
	stateMachine.register_transit("Fire", "Idle", 0)
	
	stateMachine.register_state_event("Idle", "exit", on_exit_Idle)
	stateMachine.register_state_event("Idle", "entry", on_entry_Idle)
	stateMachine.register_state_event("Aim", "exit", on_exit_Aim)
	stateMachine.register_state_event("Aim", "entry", on_entry_Aim)
	stateMachine.register_state_event("Fire", "exit", on_exit_Fire)
	stateMachine.register_state_event("Fire", "entry", on_entry_Fire)
	
	stateMachine.init_current_state("Idle")

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		

	if stateMachine.is_transit_process("Idle", "Aim", delta):
		pass
	elif stateMachine.is_transit_process("Aim", "Idle", delta):
		pass
	elif stateMachine.is_transit_process("Aim", "Fire", delta):
		pass
	elif stateMachine.is_transit_process("Fire", "Idle", delta):
		pass
		
	else:
		match stateMachine.current_state_name():
			"Idle":
				pass
				
			"Aim":
				var dir = Input.get_axis("left", "right")
				var aimed_x = ac.aim(dir, 500, delta)

				game.ui.aim_to_cam_telescope(aimed_x)
					
				bBarrel.global_rotation = -ac.get_aimed_theta()
				if player.isAttack and player.attackChance:
					stateMachine.transit_by_input("clickL", "Fire")
					
			"Fire":
				stateMachine.transit("Idle")
				player.attackChance = false
				
	update_cur_velocity(delta)	
	# 항상 바닥에 고정
	if not isInPond:
		self.global_position.y = 0

func on_exit_Idle():
	pass
func on_entry_Idle():
	pass
func on_exit_Aim():
	pass
func on_entry_Aim():
	pass
func on_exit_Fire():
	player.stateMachine.transit("Idle")
	if multiplayer.is_server():
		game.rpc("send_transmit", "p1_fired")
	else:
		game.rpc("send_transmit", "p2_fired")
		
func on_entry_Fire():
	amp.play("fire")

func on_fire():
	var launcher: int = 0
	if not multiplayer.is_server():
		launcher = 1
	world.rpc("start_shelling", player.selectedShell, shellPathes[player.selectedShell], ac.get_breech_pos(), ac.V0, ac.get_aimed_theta(), launcher)
