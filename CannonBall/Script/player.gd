# 플레이어의 상태에 따른 행동의 분류, 분류 안에서의 행동 등을 구현한다.
# 이동 속도, 대포 상호작용 가능 여부, 상태 머신을 속성으로 가지고 있으며
# 대포와 플레이어를 포커싱하는 카메라 무빙 컨트롤러에 대한 첨조를 저장한다.

#extends CharacterBody2D
extends Node2D
class_name Player

var walkSpeed: float = 500.0
var cannonSpeed: float = 300.0
var velocity: float = 0
var telescopeZoomOption: int = 1

var stateMachine: StateMachine = StateMachine.new()

var isInCannon: bool = false
var isAttack: bool = true
var attackChance: bool = false
var selectedShell: int = 0
var gameFinished: bool = false
# var isWalking: bool = false

@export var psCMC: PackedScene

# 멀티플레이 동기화
@export var canMove: bool = false
@export var lifeTime: float = 60;
@export var hp: int = 20
@export var inPondID: int = 0

@onready var nCamTargetDefault: Node2D = $CameraTarget_Default
@onready var nCamTargetAim: Node2D = $CameraTarget_Default/CameraTarget_Aim
@onready var world: World = $"../World"
@onready var pandent: Sprite2D = $CannonReaper/Skeleton2D/Bone_Body/Body/Pandent
@onready var character: Node2D = $CannonReaper
@onready var amp: AnimationPlayer = $AnimationPlayer
@onready var amt: AnimationTree = $AnimationTree
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

var game: Game = null
var cmc: CameraMovingController = null
var cannon: Cannon = null

@rpc("any_peer", "call_local")
func get_damage(damage: int):
	if not is_multiplayer_authority():
		return
	
	damage = min(damage, hp)
	hp -= damage
	
	if multiplayer.is_server():
		game.ui.rpc("remove_hp_points", 0, damage)
	else:
		game.ui.rpc("remove_hp_points", 1, damage)
	
	if hp == 0 and game.defeat_condition_die:
		if multiplayer.is_server():
			game.rpc("send_transmit", "p1_defeat")
		else:
			game.rpc("send_transmit", "p2_defeat")


@rpc("any_peer", "call_remote")
func set_lifetime(time: float) -> void:
	self.lifeTime = time

@rpc("any_peer", "call_local")
func shake_camera(from_x: float, range: float) -> void:
	if not is_multiplayer_authority():
		return
		
	var distance: float = abs(from_x - cmc.camera.global_position.x)
	var t: float = inverse_lerp(range, 0, distance)
	var amplitude = lerp(0, 100, clamp(t, 0, 1))
	cmc.shake(amplitude)
	
func h_movement(mode: String, speed: float, delta: float):
	if not canMove:
		return
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity = direction * speed
	else:
		velocity = move_toward(velocity, 0, 50)
		
	match mode:
		"self":
			# 단독 무브먼트
			self.global_position.x += velocity * delta
			if direction:
				character.scale.x = direction
		"cannon":
			# 대포 무브먼트
			cannon.global_position.x += velocity * delta
			self.global_position.x = cannon.get_handle_x()

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	game = get_parent() as Game

func _ready() -> void:
	# _enter_tree()에서 설정한 멀티플레이어 권한은 고유의 id값이다.
	# 멀티플레이를 하게 되면 한 쪽의 컴퓨터에서도 플레이어 객체가 두개 존재하게 되는데, 본 사용자에게 할당된 플레이어 아니면
	# 이 함수의 내용을 무시하고 리턴하는 것이다. 즉 입력의 중복 등을 방지한다.
	if not is_multiplayer_authority():
		return
	
	if not multiplayer.is_server():
		game.rpc("send_transmit", "client_connected")
	
	game = get_parent() as Game
	game.ui = game.root.uiMgr.get_current_ui_as_in_game()

	## 대포 생성
	#  서버에서 생성하기 위해 원격 함수 호출(클라->서버)
	#  서버의 경우 직접 호출
	game.rpc("server_spawn_request", "res://Scene/cannon.tscn", self.name + "cannon")

	if multiplayer.is_server():
		global_position = world.get_spawn_spot("p1")
		character.scale.x = 1
	else:
		nCamTargetAim.position.x = -700
		game.root.uiMgr.currentUI.position.x = 0
		global_position = world.get_spawn_spot("p2")
		character.scale.x = -1

	# 상태 머신 정의
	stateMachine.regist_state("Idle")
	stateMachine.regist_state("HandleCannon")
	stateMachine.regist_state("ReadyFire")
	
	stateMachine.regist_transit("Idle", "HandleCannon", 0)
	stateMachine.regist_transit("HandleCannon", "Idle", 0)
	stateMachine.regist_transit("Idle", "ReadyFire", 0)
	stateMachine.regist_transit("ReadyFire", "Idle", 0)
	stateMachine.regist_transit("ReadyFire", "HandleCannon", 0)
	stateMachine.regist_transit("HandleCannon", "ReadyFire", 0)
	
	stateMachine.regist_state_event("Idle", "exit", on_exit_Idle)
	stateMachine.regist_state_event("Idle", "entry", on_entry_Idle)
	stateMachine.regist_state_event("HandleCannon", "exit", on_exit_HandleCannon)
	stateMachine.regist_state_event("HandleCannon", "entry", on_entry_HandleCannon)
	stateMachine.regist_state_event("ReadyFire", "exit", on_exit_ReadyFire)
	stateMachine.regist_state_event("ReadyFire", "entry", on_entry_ReadyFire)
	
	stateMachine.init_current_state("Idle")
	
	var smPandent: ShaderMaterial = pandent.material
	if smPandent:
		if multiplayer.is_server():
			smPandent.set_shader_parameter("TeamColor", Color.RED)
		else:
			smPandent.set_shader_parameter("TeamColor", Color.BLUE)
	
	# 카메라 무빙 컨트롤러 생성
	cmc = psCMC.instantiate()
	cmc.name = name + "_cmc"
	cmc.global_position = global_position
	game.add_child(cmc)
	# cmc.set_target_zoom(Vector2(0.7, 0.7))
	cmc.set_target(nCamTargetDefault)
	cmc.camera.make_current()
	
	
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	# 상태 전환 처리 중 처리해야하는 내용에 대한 분기이다.
	# 예를 들어 플레이어가 대포를 잡을때, 순간이동하듯 손잡이쪽으로 즉시 위치하는것이 아니라
	# 손잡이쪽으로 걸어가 손잡이를 잡게기까지 애니메이션이 짧게라도 나오는것이 자연스럽다.
	# 그 동안 이동이나 조준과 같은 다른 조작이 입력되면 안된다. 그래서 따로 분기를 정해놓은 것
	# register_transit을 호출했을 때 두 번째 인수로 건네준 실수값이 초 단위인데, 그동안 이 분기가 처리된다. 0이면 실행되지 않는다.
	if stateMachine.is_transit_process("Idle", "HandleCannon", delta):
		pass
	elif stateMachine.is_transit_process("HandleCannon", "Idle", delta):
		pass
		
	elif stateMachine.is_transit_process("Idle", "ReadyFire", delta):
		pass
	elif stateMachine.is_transit_process("ReadyFire", "Idle", delta):
		pass
		
	elif stateMachine.is_transit_process("HandleCannon", "ReadyFire", delta):
		pass
	elif stateMachine.is_transit_process("ReadyFire", "HandleCannon", delta):
		pass
	# 상태 전환 프로세스가 없으면 각 상태에서의 행동 처리
	else:
		match stateMachine.current_state_name():
			"Idle":
				# 입력 시 상태 전환
				if isInCannon:
					stateMachine.transit_by_input("handle", "HandleCannon")
					stateMachine.transit_by_input("aim", "ReadyFire")
				
				h_movement("self", walkSpeed, delta)
				amt.set("parameters/BT_Idle/Blend2/blend_amount", clamp(abs(velocity), 0, 1))
				
			"HandleCannon":
				# 대포 무브먼트에 고정
				if cannon:
					position.x = cannon.get_handle_x()

				stateMachine.transit_by_input("handle", "Idle")
				stateMachine.transit_by_input("aim", "ReadyFire")
			
				h_movement("cannon", cannonSpeed, delta)
				amt.set("parameters/BT_HC/Blend2/blend_amount", clamp(abs(cannon.curVelocity), 0, 1))
				
			"ReadyFire":
				if Input.is_action_just_pressed("aim"):
					if isInCannon:
						stateMachine.transit_back()
					else:
						stateMachine.execute_transit("Idle")
					
				# 만원경으로 조준
				if game.ui.zoomFinished:
					if Input.is_action_just_pressed("wheel_up"):
						telescopeZoomOption += 1
						telescopeZoomOption = clamp(telescopeZoomOption, 0, len(game.ui.telescopeZoomOptions) - 1)
						game.ui.zoom_cam_telescope(telescopeZoomOption)

					elif Input.is_action_just_pressed("wheel_down"):
						telescopeZoomOption -= 1
						telescopeZoomOption = clamp(telescopeZoomOption, 0, len(game.ui.telescopeZoomOptions) - 1)
						game.ui.zoom_cam_telescope(telescopeZoomOption)				

	# 높이를 항상 바닥에 고정
	if not inPondID:
		self.global_position.y = 0

	if cannon:
		#대포의 상호작용구역 안에 들어왔음을 감지
		if abs(cannon.global_position.x - self.global_position.x) < 150:
			isInCannon = true
		else:
			isInCannon = false
	
	if abs(velocity) > 0:
		if not audio.playing:
			audio.play()
	else:
		audio.stop()

func _process(delta: float) -> void:
	if self.name == "1":
		game.ui.subuiDashBoard.p1_time_left = lifeTime
	else:
		game.ui.subuiDashBoard.p2_time_left = lifeTime


	if not is_multiplayer_authority():
		return

	if Input.is_action_just_pressed("tab"):
		selectedShell = (selectedShell + 1) % 3 

	if multiplayer.is_server():
		self.global_position.x = clamp(self.global_position.x, world.vertical_boundary["p1_left_end"], world.vertical_boundary["p1_right_end"])
	else:
		self.global_position.x = clamp(self.global_position.x, world.vertical_boundary["p2_left_end"], world.vertical_boundary["p2_right_end"])

	if lifeTime < 0 and game.defeat_condition_timeout and not gameFinished:
		lifeTime = 0
		if multiplayer.is_server():
			game.ui.subuiDashBoard.p1TimeLeftRing.modulate = Color(1, 0, 0, 1)
			game.rpc("send_transmit", "p1_defeat")
		else:
			game.ui.subuiDashBoard.p2TimeLeftRing.modulate = Color(1, 0, 0, 1)
			game.rpc("send_transmit", "p2_defeat")
		gameFinished = true

# 전환 이벤트. 상태 전환이 발생했을 때 한번만 실행된다.
func on_exit_Idle():
	amt.set("parameters/conditions/is_state_idle", false)
	
func on_entry_Idle():
	amt.set("parameters/conditions/is_state_idle", true)
	
	if cannon:
		cannon.stateMachine.execute_transit("Idle")

func on_exit_HandleCannon():
	amt.set("parameters/conditions/is_state_hc", false)
	
func on_entry_HandleCannon():
	amt.set("parameters/conditions/is_state_hc", true)
	
	if multiplayer.is_server():
		character.scale.x = 1
	else:
		character.scale.x = -1
	
	if cannon:
		cannon.stateMachine.execute_transit("Move")

func on_exit_ReadyFire():
	# 카메라 위치를 원래대로 되돌림
	cmc.set_target(nCamTargetDefault)
	
	game.ui.off_observe()
	cannon.stateMachine.execute_transit("Idle")
	game.ui.set_hints(0)
	
func on_entry_ReadyFire():
	if multiplayer.is_server():
		character.scale.x = 1
	else:
		character.scale.x = -1
	
	if cannon:
		cannon.stateMachine.execute_transit("Aim")
		
	# 카메라 위치를 이동시킴
	cmc.set_target(nCamTargetAim)
	game.ui.on_observe()
	game.ui.set_hints(1)
