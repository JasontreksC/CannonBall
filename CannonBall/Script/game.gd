extends Node2D
class_name Game

var root: CannonBall = null
var ui: InGameUI = null
var stateMachine: StateMachine = StateMachine.new()
var transmitQueue: Array[String]

var peerID: int = 0
var players: Array[Player]

@export var defeat_condition_die: bool = true
@export var defeat_condition_timeout: bool = true

@onready var world: World = $World
@onready var spawner: MultiplayerSpawner = $MultiplayerSpawner

var G: float = 980
var turnCount: int = 0

var lifetimePool: Dictionary[String, Lifetime]
var gameTime: float = 0
var winner: int = -1
var activatedShell: String

var lifetimes: Array[int] = [60, 60]

## 오브젝트 풀링
## 서버에게 스폰을 요청함. 서버가 스폰하면 자동으로 클라에서도 스폰
@rpc("any_peer", "call_local")
func server_spawn_request(path: String, object_name: String, props: Dictionary={}) -> void: 
	if not multiplayer.is_server():
		return

	if object_name == "none":
		object_name = "object" + str(Time.get_ticks_usec())

	var spawnable: bool = false
	var count: int = spawner.get_spawnable_scene_count()
	for i in range(count):
		var spawnable_path: String = spawner.get_spawnable_scene(i)
		if path == spawnable_path:
			spawnable = true
	if not spawnable:
		print("스폰할려는 오브젝트 씬이 MuliplaySpawner에 등록되어 있지 않음!")
		return

	var ps: PackedScene = load(path)
	var inst: Node2D = ps.instantiate()

	inst.name = object_name
	
	for k in props.keys():
		inst.set(k, props[k])
	
	add_child(inst)
	
	var senderID = multiplayer.get_remote_sender_id()
	inst.rpc_id(senderID, "on_spawned")

## 서버가 직접 스폰함. 클라에게도 스폰됨.
func server_spawn_directly(ps: PackedScene, object_name: String, props: Dictionary[StringName, Variant]={}) -> Node2D:
	if not multiplayer.is_server():
		return
	
	var spawnable: bool = false
	var count: int = spawner.get_spawnable_scene_count()
	for i in range(count):
		var spawnable_path: String = spawner.get_spawnable_scene(i)
		if ps.resource_path == spawnable_path:
			spawnable = true
	if not spawnable:
		print("스폰할려는 오브젝트 씬이 MuliplaySpawner에 등록되어 있지 않음!")
		return
	
	var inst: Node2D = ps.instantiate()
	inst.name = object_name + str(Time.get_ticks_usec())
	
	for k in props.keys():
		inst.set(k, props[k])
	
	add_child(inst)
	return inst

@rpc("any_peer", "call_local")
func delete_object(node_path: String):
	if not multiplayer.is_server():
		return
	if has_node(node_path):
		get_node(node_path).queue_free()

## 턴, 게임플로우 관리
func is_p1_turn() -> bool:
	if turnCount % 2 == 0:
		return true
	else:
		return false

@rpc("any_peer", "call_local")
func change_turn() -> void:
	if is_p1_turn():
		print("p1attack")
		players[0].isAttack = true
		players[0].attackChance = true
		players[1].isAttack = false
	else: 
		print("p2attack")
		players[1].isAttack = true
		players[1].attackChance = true
		players[0].isAttack = false

@rpc("any_peer", "call_local")
func transit_game_state(state: String, delay: float=0):
	await get_tree().create_timer(delay).timeout
	stateMachine.execute_transit(state)

@rpc("any_peer", "call_local")
func send_transmit(transmit: String):
	if not transmitQueue.has(transmit):
		transmitQueue.append(transmit)

func check_transmit(transmit: Array[String]) -> bool:
	var result: bool = true
	for t in transmit:
		if not transmitQueue.has(t):
			result = false
		else:
			transmitQueue.erase(t)
	return result

func update_game_time(delta: float) -> void:
	lifetimes[0] -= delta
	lifetimes[1] -= delta


	if multiplayer.is_server():
		if players[0].isAttack :
			players[0].lifeTime -= delta
			
		if players[1].isAttack :
			players[1].lifeTime -= delta
			players[1].rpc("set_lifetime", players[1].lifeTime)

@rpc("any_peer", "call_local")
func regist_lifeturn(key: String, turn: int):
	if multiplayer.is_server():
		lifetimePool[key] = Lifetime.new(turn)
	
func update_lifeturn():
	for key in lifetimePool.keys():
		var lft: Lifetime = lifetimePool[key]
		var live: bool = lft.pass_turn()
		if not live:
			if has_node(key):
				get_node(key).rpc("lifetime_end")
				lifetimePool.erase(key)

func quit_game():
	if multiplayer.is_server():
		var objs: Array[Node] = get_children()
		for o in objs:
			o.free()

	if multiplayer.is_server():
		match winner:
			0:
				root.sceneMgr.gameResult = 1
			1:
				root.sceneMgr.gameResult = 0
	else:
		match winner:
			0:
				root.sceneMgr.gameResult = 0
			1:
				root.sceneMgr.gameResult = 1
	
	await get_tree().create_timer(0.25).timeout
	root.uiMgr.call_deferred("set_ui", 2)
	root.sceneMgr.call_deferred("set_scene", 2)

func get_my_player() -> Player:
	if has_node(str(peerID)):
		return get_node(str(peerID))
	else:
		return null

func disconnected(id=1) -> void:
	if id != peerID:
		print("%d과의 접속이 끊어짐!" % id)
	
	ui.subuiDisconnected.visible = true
	get_my_player().canMove = false
	get_my_player().set_multiplayer_authority(-1)
	get_my_player().cannon.set_multiplayer_authority(-1)
	get_tree().paused = true

	await get_tree().create_timer(3).timeout
	root.back_to_lobby()

func _enter_tree() -> void:
	root = get_parent().root
	root.uiMgr.set_ui(1)

func _ready() -> void:
	peerID = multiplayer.get_unique_id()
	if not multiplayer.peer_disconnected.is_connected(disconnected):
		multiplayer.peer_disconnected.connect(disconnected)
	
	ui = root.uiMgr.get_current_ui_as_in_game()
	if ui:
		ui.game = self
		
	stateMachine.regist_state("WaitSession")
	stateMachine.regist_state("Turn")
	stateMachine.regist_state("Shelling")
	stateMachine.regist_state("EndSession")
	
	stateMachine.regist_transit("WaitSession", "Turn", 3)
	stateMachine.regist_transit("Turn", "Shelling", 0)
	stateMachine.regist_transit("Turn", "EndSession", 0)
	stateMachine.regist_transit("Shelling", "Turn", 3)
	stateMachine.regist_transit("Shelling", "EndSession", 0)

	stateMachine.regist_state_event("WaitSession", "exit", on_exit_WaitSession)
	stateMachine.regist_state_event("Turn", "entry", on_entry_Turn)
	stateMachine.regist_state_event("Turn", "exit", on_exit_Turn)
	stateMachine.regist_state_event("Shelling", "entry", on_entry_Shelling)
	stateMachine.regist_state_event("Shelling", "exit", on_exit_Shelling)
	stateMachine.regist_state_event("EndSession", "entry", on_entry_EndSession)
	
	stateMachine.init_current_state("WaitSession")
	
func _process(delta: float) -> void:
			
	if stateMachine.is_transit_process("WaitSession", "Turn", delta):
		pass
		
	elif stateMachine.is_transit_process("Turn", "Shelling", delta):
		pass
		
	elif stateMachine.is_transit_process("Shelling", "Turn", delta):
		pass
		
	elif stateMachine.is_transit_process("Turn", "EndSession", delta):
		pass
		
	elif stateMachine.is_transit_process("Shelling", "EndSession", delta):
		pass
		
	# 상태 전환 프로세스가 없으면 각 상태에서의 행동 처리
	else:
		match stateMachine.current_state_name():
			"WaitSession":
				if check_transmit(["client_connected"]):
					rpc("transit_game_state", "Turn")
					
			"Turn":
				if multiplayer.is_server():
					update_game_time(delta)
					
					if check_transmit(["p1_fired"]) or check_transmit(["p2_fired"]):
						rpc("transit_game_state", "Shelling")
					
			"Shelling":
				pass
					
			"EndSession":
				pass
	
	if check_transmit(["p1_defeat"]):
		winner = 1
		stateMachine.execute_transit("EndSession")
	elif check_transmit(["p2_defeat"]):
		winner = 0
		stateMachine.execute_transit("EndSession")
		
func on_exit_WaitSession():
	ui.generate_hp_points(0, 20)
	ui.generate_hp_points(1, 20)
	players[0].canMove = true
	players[1].canMove = true

	ui.subuiDashBoard.show_text("접속 성공!\n잠시 후 게임 시작", 3)
	ui.subuiDashBoard.set_pb_time(3)

	world.process_mode = Node.PROCESS_MODE_INHERIT
	world.process_start()

func on_entry_Turn():
	if multiplayer.is_server():
		rpc("change_turn")
	
	if is_p1_turn():
		ui.subuiDashBoard.show_text("Player1 공격", -1)
		ui.subuiDashBoard.focus_player_info(0)
	else:
		ui.subuiDashBoard.show_text("Player2 공격", -1)
		ui.subuiDashBoard.focus_player_info(1)
		
func on_exit_Turn():
	turnCount += 1
		
func on_entry_Shelling():
	ui.subuiDashBoard.hide_text()

	if is_p1_turn():
		ui.subuiDashBoard.unfocus_player_info(1)
	else:
		ui.subuiDashBoard.unfocus_player_info(0)

func on_exit_Shelling():
	if multiplayer.is_server():
		update_lifeturn()
		world.on_turn_count()

	if winner == -1:
		ui.subuiDashBoard.show_text("잠시후 공수전환", 3)
		ui.subuiDashBoard.set_pb_time(3)

func on_entry_EndSession():
	ui.subuiDashBoard.show_text("게임 종료!", 5)
	ui.subuiDashBoard.set_pb_time(5)
	
	get_my_player().canMove = false
	get_my_player().set_multiplayer_authority(-1)
	get_my_player().cannon.set_multiplayer_authority(-1)
	
	lifetimePool.clear()
	transmitQueue.clear()
	world.process_mode = Node.PROCESS_MODE_DISABLED

	get_tree().create_timer(5).timeout.connect(quit_game)

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is Player:
		players.append(node as Player)
