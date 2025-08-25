# 플레이어에 의해 조종되는 대포에 대한 스크립트이다
# 대포 역시 상태 머신으로 분기가 나위어져 있으며
# 대포의 상태 전환은 플레이어에 의해 수동적으로 이루어진다.
extends Node2D
class_name Cannon

var stateMachine: StateMachine = StateMachine.new()

var heading: int = 0
var prevPosX: float = 0
var curVelocity: float = 0
var inPondID: int = 0
var reverseBlast: float = 0
var aimSpeedOptions: Array[float] = [2000, 1000, 500]
var inBushID: int = 0

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
@onready var nBreech: Node2D = $Skeleton2D/BnCarriage/BnBarrel/SpBarrel/Breech
@onready var nMuzzle: Node2D = $Skeleton2D/BnCarriage/BnBarrel/SpBarrel/Muzzle


var game: Game = null
var world: World = null
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
	world = game.world
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if not is_multiplayer_authority():
		return
	
	if multiplayer.is_server():
		global_position = world.get_spawn_spot("p1")
		scale.x = 1
		heading = 1
	else:
		global_position = world.get_spawn_spot("p2")
		scale.x = -1
		heading = -1
		
	prevPosX = global_position.x
	
	stateMachine.regist_state("Idle")
	stateMachine.regist_state("Aim")
	
	stateMachine.regist_transit("Idle", "Aim", 0)
	stateMachine.regist_transit("Aim", "Idle", 0)
	
	stateMachine.regist_state_event("Idle", "exit", on_exit_Idle)
	stateMachine.regist_state_event("Idle", "entry", on_entry_Idle)
	stateMachine.regist_state_event("Aim", "exit", on_exit_Aim)
	stateMachine.regist_state_event("Aim", "entry", on_entry_Aim)
	
	stateMachine.init_current_state("Idle")

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
		

	if stateMachine.is_transit_process("Idle", "Aim", delta):
		pass
	elif stateMachine.is_transit_process("Aim", "Idle", delta):
		pass
	else:
		match stateMachine.current_state_name():
			"Idle":
				pass
				
			"Aim":
				var dir = Input.get_axis("left", "right")
				var aimed_x = ac.aim(dir, aimSpeedOptions[player.telescopeZoomOption], delta)

				game.ui.aim_to_cam_telescope(aimed_x)
					
				bBarrel.global_rotation = -ac.get_aimed_theta()
				game.ui.subuiHint_Attack.set_possibility(player.attackChance)

				if Input.is_action_just_pressed("clickL"):
					if player.isAttack and player.attackChance and not game.ui.mouse_on_button:
						amp.play("fire")
						player.attackChance = false
						
						if multiplayer.is_server():
							game.rpc("send_transmit", "p1_fired")
						else:
							game.rpc("send_transmit", "p2_fired")
				
	if reverseBlast > 0:
		global_position.x -= heading * reverseBlast * delta
		reverseBlast = move_toward(reverseBlast, 0, 100 * delta)
	
	update_cur_velocity(delta)
	if abs(curVelocity) > 0:
		rotate_wheel(delta)
	# 항상 바닥에 고정
	if not inPondID:
		self.global_position.y = 0


func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return

	if multiplayer.is_server():
		self.global_position.x = clamp(self.global_position.x, world.vertical_boundary["p1_left_end"] + 200, world.vertical_boundary["p1_right_end"])
	else:
		self.global_position.x = clamp(self.global_position.x, world.vertical_boundary["p2_left_end"], world.vertical_boundary["p2_right_end"] - 200)


func on_exit_Idle():
	pass
func on_entry_Idle():
	pass
func on_exit_Aim():
	pass
func on_entry_Aim():
	pass
	
func on_fire():
	var launcher: int = 0
	if not multiplayer.is_server():
		launcher = 1
	world.rpc("start_shelling", player.selectedShell, shellPathes[player.selectedShell], ac.get_breech_pos(), ac.V0, ac.get_aimed_theta(), launcher)
	reverseBlast += 200

	var burstDir: Vector2 = nBreech.global_position.direction_to(nMuzzle.global_position).normalized()
	game.rpc("server_spawn_request", "res://Scene/fx_burst.tscn", "none", {
		"global_position" : nMuzzle.global_position,
		"direction" : burstDir})
