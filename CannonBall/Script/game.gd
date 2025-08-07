extends Node2D
class_name Game

var root: CannonBall = null
var ui: InGameUI = null
var stateMachine: StateMachine = StateMachine.new()
var transmitQueue: Array[String]

var peerID: int = 0
var players: Array[Player]
var objects: Dictionary[String, Node2D]

@onready var world: World = $World
@onready var spawner: MultiplayerSpawner = $MultiplayerSpawner

var G: float = 980
var turnCount: int = 0

var lifetimePool: Dictionary[String, Lifetime]
var gameTime: float = 0
var winner: int = -1

## 오브젝트 풀링
## 서버에게 스폰을 요청함. 서버가 스폰하면 자동으로 클라에서도 스폰
@rpc("any_peer", "call_local")
func server_spawn_request(path: String, object_name: String, props: Dictionary[StringName, Variant]={}) -> void: 
	if object_name == "none":
		object_name = "object" + str(Time.get_ticks_usec())
	elif objects.has(object_name):
		return
	if not multiplayer.is_server():
		return
	
	var spawnable: bool = false
	var count: int = spawner.get_spawnable_scene_count()
	for i in range(count):
		var spawnable_path: String = spawner.get_spawnable_scene(i)
		if path == spawnable_path:
			spawnable = true
	if not spawnable:
		return

	var ps: PackedScene = load(path)
	var inst: Node2D = ps.instantiate()
	if object_name:
		inst.name = object_name
	
	for k in props.keys():
		inst.set(k, props[k])
	
	add_child(inst)
	objects[object_name] = inst
	
	var senderID = multiplayer.get_remote_sender_id()
	inst.rpc_id(senderID, "on_spawned")

## 서버가 직접 스폰함. 클라에게도 스폰됨.
func server_spawn_directly(ps: PackedScene, object_name: String, props: Dictionary[StringName, Variant]={}) -> Node2D:
	if object_name == "none":
		object_name = "object" + str(Time.get_ticks_usec())
	elif objects.has(object_name):
		return
	if not multiplayer.is_server():
		return
	
	var spawnable: bool = false
	var count: int = spawner.get_spawnable_scene_count()
	for i in range(count):
		var spawnable_path: String = spawner.get_spawnable_scene(i)
		if ps.resource_path == spawnable_path:
			spawnable = true
	if not spawnable:
		return
	
	var inst: Node2D = ps.instantiate()
	if object_name:
		inst.name = object_name
	
	for k in props.keys():
		inst.set(k, props[k])
	
	add_child(inst)
	objects[object_name] = inst
	return inst

@rpc("any_peer", "call_local")
func delete_object(object_name: String):
	if objects.has(object_name):
		var inst: Node2D = objects[object_name]
		inst.queue_free()
		objects.erase(object_name)
		
func get_object(name: String) -> Node2D:
	if objects.has(name):
		return objects[name]
	else:
		return null
		
func add_object(object: Node2D) -> bool:
	if objects.has(name):
		return false
	else:
		objects[object.name] = object
		return true

## 턴, 게임플로우 관리
func is_p1_turn() -> bool:
	if turnCount % 2 == 1:
		return true
	else:
		return false

@rpc("any_peer", "call_local")
func change_turn() -> void:
	turnCount += 1
	if is_p1_turn():
		players[0].isAttack = true
		players[0].attackChance = true
		players[1].isAttack = false
	else: 
		players[1].isAttack = true
		players[1].attackChance = true
		players[0].isAttack = false
	
	if multiplayer.is_server():
		update_lifetime_turn()

@rpc("any_peer", "call_local")
func transit_game_state(state: String):
	stateMachine.transit(state)

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
	if multiplayer.is_server():
		if players[0].isAttack :
			players[0].lifeTime -= delta
			
		if players[1].isAttack :
			players[1].lifeTime -= delta
		
		ui.rpc("set_player_life_time",players[0].lifeTime, players[1].lifeTime)	

func regist_lifetime(key: String, turn: int, sec: float):
	lifetimePool[key] = Lifetime.new(turn, sec)
	
func update_lifetime_turn():
	for key in lifetimePool.keys():
		var lft: Lifetime = lifetimePool[key]
		if lft.turn > 0:
			var live: bool = lft.pass_turn()
			if not live and lft.sec == 0:
				objects[key].rpc("lifetime_end")
				lifetimePool.erase(key)
			
func update_lifetime_sec(delta: float):
	for key in lifetimePool.keys():
		var lft: Lifetime = lifetimePool[key]
		if not lft.turn:
			var live: bool = lft.pass_sec(delta)
			if not live:
				objects[key].rpc("lifetime_end")
				lifetimePool.erase(key)
		
		
func _enter_tree() -> void:
	root = get_parent().root
	root.uiMgr.set_ui(1)

func _ready() -> void:
	ui = root.uiMgr.get_current_ui_as_in_game()
	if ui:
		ui.game = self
		
	stateMachine.register_state("WaitSession")
	stateMachine.register_state("Turn")
	stateMachine.register_state("Shelling")
	stateMachine.register_state("EndSession")
	
	stateMachine.register_transit("WaitSession", "Turn", 3)
	stateMachine.register_transit("Turn", "Shelling", 0)
	stateMachine.register_transit("Turn", "EndSession", 3)
	stateMachine.register_transit("Shelling", "Turn", 3)
	stateMachine.register_transit("Shelling", "EndSession", 3)

	stateMachine.register_state_event("WaitSession", "entry", on_entry_WaitSession)
	stateMachine.register_state_event("WaitSession", "exit", on_exit_WaitSession)
	stateMachine.register_state_event("Turn", "entry", on_entry_Turn)
	stateMachine.register_state_event("Turn", "exit", on_exit_Turn)
	stateMachine.register_state_event("Shelling", "entry", on_entry_Shelling)
	stateMachine.register_state_event("Shelling", "exit", on_exit_Shelling)
	stateMachine.register_state_event("EndSession", "entry", on_entry_EndSession)
	stateMachine.register_state_event("EndSession", "exit", on_exit_EndSession)
	
	stateMachine.init_current_state("WaitSession")
func _process(delta: float) -> void:
			
	if stateMachine.is_transit_process("WaitSession", "Turn", delta):
		pass
	elif stateMachine.is_transit_process("Turn", "EndSession", delta):
		pass
	elif stateMachine.is_transit_process("Turn", "EndSession", delta):
		players[0].cmc.rpc("zoom_out", 0.1, delta)
		players[1].cmc.rpc("zoom_out", 0.1, delta)
		pass
	elif stateMachine.is_transit_process("Shelling", "Turn", delta):
		pass
	elif stateMachine.is_transit_process("Shelling", "EndSession", delta):
		pass
	# 상태 전환 프로세스가 없으면 각 상태에서의 행동 처리
	else:
		match stateMachine.current_state_name():
			"WaitSession":
				if check_transmit(["client_connected"]):
					for i in range(3):
						ui.set_state_text("접속 성공! 게임 시작까지 %d 초 전" % (3 - i))
						await get_tree().create_timer(1).timeout
					ui.set_state_text("시작!")
					rpc("transit_game_state", "Turn")		
					
			"Turn":
				if multiplayer.is_server():
					update_lifetime_sec(delta)
					update_game_time(delta)
					
					if check_transmit(["p1_fired"]) or check_transmit(["p2_fired"]):
						print("ShellingStarted!")
						rpc("transit_game_state", "Shelling")
					
				if check_transmit(["p1_defeat"]):
					print("p2 win!")
					winner = 1
				elif check_transmit(["p2_defeat"]):
					print("p1 win!")
					winner = 0
				if winner != -1:
					stateMachine.transit("EndSession")
					
			"Shelling":
				if multiplayer.is_server():
					update_lifetime_sec(delta)
					
				if check_transmit(["p1_defeat"]):
					print("p2 win!")
					winner = 1
				elif check_transmit(["p2_defeat"]):
					print("p1 win!")
					winner = 0
				if winner != -1:
					stateMachine.transit("EndSession")
					
			"EndSession":
				root.sceneMgr.set_scene(2)
		
	if winner != -1:
		stateMachine.transit("EndSession")
		
func on_entry_WaitSession():
	pass
		
func on_exit_WaitSession():
	ui.generate_hp_points(0, 20)
	ui.generate_hp_points(1, 20)
	players[0].canMove = true
	players[1].canMove = true
	

func on_entry_Turn():
	if multiplayer.is_server():
		rpc("change_turn")
	
func on_exit_Turn():
	pass
		
func on_entry_Shelling():
	pass
func on_exit_Shelling():
	for i in range(3):
		ui.set_state_text("공수전환까지 %d초 전" % (3 - i))
		await get_tree().create_timer(1).timeout
		ui.set_state_text("시작!")	

func on_entry_EndSession():
	ui.set_state_text("게임 종료!")
	
	players[0].canMove = false
	players[1].canMove = false
	
	lifetimePool.clear()
	transmitQueue.clear()
	
func on_exit_EndSession():
	pass

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is Player:
		players.append(node as Player)
	elif is_instance_valid(node.get_instance_id()):
		add_object(node)
