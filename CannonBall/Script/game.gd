extends Node2D
class_name Game

var root: CannonBall = null
var ui: InGameUI = null
var stateMachine: StateMachine = StateMachine.new()
var transmitQueue: Array[String]

var players: Array[Player]
var objects: Dictionary[String, Node2D]

var G: float = 980
var turnCount: int = 0
var gameStarted: bool = false

var tickPoolInfo: Dictionary[String, Array]
var tickPoolCallback: Dictionary[String, Callable]
var gameTime: float = 0

@rpc("any_peer", "call_local")
func spawn_object(path: String, name: String, pos: Vector2 = Vector2.ZERO) -> void:
	if objects.has(name):
		return
	
	if multiplayer.is_server():
		var ps: PackedScene = load(path)
		var inst: Node2D = ps.instantiate()
		inst.name = name
		inst.global_position = pos
		add_child(inst)
		objects[name] = inst
		
		var senderID = multiplayer.get_remote_sender_id()
		inst.rpc_id(senderID, "on_spawned")

@rpc("any_peer", "call_local")
func delete_object(name: String):
	if objects.has(name):
		var inst: Node2D = objects[name]
		inst.queue_free()
		objects.erase(name)
		
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
		
	gameStarted = true
	
	print("======================")
	print("현재 턴:", turnCount)
	if players[0].isAttack:
		print("공격: P1")
		print("수비: P2")
	if players[1].isAttack:
		print("공격: P2")
		print("수비: P1")

@rpc("any_peer", "call_local")
func transit_game_state(state: String):
	stateMachine.transit(state)

@rpc("any_peer", "call_local")
func send_transmit(transmit: String):
	if not transmitQueue.has(transmit):
		transmitQueue.append(transmit)

## 서버 전용

func check_transmit(transmit: Array[String]) -> bool:
	var result: bool = true
	for t in transmit:
		if not transmitQueue.has(t):
			result = false
		else:
			transmitQueue.erase(t)
	return result

func regist_tick(key: String, interval: float, callback: Callable):
	tickPoolInfo[key] = [0, interval]
	tickPoolCallback[key] = callback

func update_tick(delta: float):
	for key in tickPoolInfo.keys():
		var thisTick = tickPoolInfo[key]
		if thisTick[0] >= thisTick[1]:
			tickPoolCallback[key].call()
			thisTick[0] = 0
		
		else:
			thisTick[0] += delta
		
func update_game_time(delta: float) -> void:
	if multiplayer.is_server():
		if players[0].isAttack :
			players[0].lifeTime -= delta
			
		if players[1].isAttack :
			players[1].lifeTime -= delta
		
		ui.rpc("set_player_life_time",players[0].lifeTime, players[1].lifeTime)	

func is_p1_turn() -> bool:
	if turnCount % 2 == 1:
		return true
	else:
		return false
	

func _enter_tree() -> void:
	root = get_parent().root

func _ready() -> void:
	ui = root.uiMgr.get_current_ui_as_in_game()
	if ui:
		ui.game = self
		
	stateMachine.register_state("WaitSession")
	stateMachine.register_state("Turn")
	stateMachine.register_state("Shelling")
	stateMachine.register_state("EndSession")
	
	stateMachine.register_transit("WaitSession", "Turn", 0)
	stateMachine.register_transit("Turn", "Shelling", 0)
	stateMachine.register_transit("Turn", "EndSession", 0)
	stateMachine.register_transit("Shelling", "Turn", 0)
	stateMachine.register_transit("Shelling", "EndSession", 0)

	stateMachine.register_state_event("WaitSession", "entry", on_entry_WaitSession)
	stateMachine.register_state_event("WaitSession", "exit", on_exit_WaitSession)
	stateMachine.register_state_event("Turn", "entry", on_entry_Turn)
	stateMachine.register_state_event("Turn", "exit", on_exit_Turn)
	stateMachine.register_state_event("Shelling", "entry", on_entry_Shelling)
	stateMachine.register_state_event("Shelling", "exit", on_exit_Shelling)
	stateMachine.register_state_event("EndSession", "entry", on_entry_EndSession)
	stateMachine.register_state_event("EndSession", "exit", on_exit_EndSession)

func _process(delta: float) -> void:
			
	if stateMachine.is_transit_process("WaitSession", "Turn", delta):
		pass
	elif stateMachine.is_transit_process("Turn", "EndSession", delta):
		pass
	elif stateMachine.is_transit_process("Turn", "EndSession", delta):
		pass
	elif stateMachine.is_transit_process("Shelling", "Turn", delta):
		pass
	elif stateMachine.is_transit_process("Shelling", "EndSession", delta):
		pass
	# 상태 전환 프로세스가 없으면 각 상태에서의 행동 처리
	else:
		match stateMachine.current_state_name():
			"WaitSession":
				if len(players) == 2:
					rpc("transit_game_state", "Turn")
			"Turn":
				if multiplayer.is_server():
					update_tick(delta)
					update_game_time(delta)
					
					if check_transmit(["p1_fired"]) or check_transmit(["p2_fired"]):
						rpc("transit_game_state", "Shelling")
			"Shelling":
				if multiplayer.is_server():
					update_tick(delta)
					
			"EndSession":
				pass
	
	print(stateMachine.current_state_name())
		
func on_entry_WaitSession():
	pass
func on_exit_WaitSession():
	pass
func on_entry_Turn():
	if multiplayer.is_server():
		rpc("change_turn")
func on_exit_Turn():
	pass
func on_entry_Shelling():
	pass
func on_exit_Shelling():
	pass
func on_entry_EndSession():
	pass
func on_exit_EndSession():
	pass

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print(node.name)
	if node is Player:
		players.append(node as Player)
	elif is_instance_valid(node.get_instance_id()):
		add_object(node)
