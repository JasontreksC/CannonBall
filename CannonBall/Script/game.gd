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
	if turnCount % 2 == 1:
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
		

func _enter_tree() -> void:
	root = get_parent().root

func _ready() -> void:
	ui = root.uiMgr.get_current_ui_as_in_game()
	if ui:
		ui.game = self
		
	stateMachine.register_state("WaitSession")
	stateMachine.register_state("TurnStart")
	stateMachine.register_state("WaitAttack")
	stateMachine.register_state("Attacking")
	stateMachine.register_state("EndAttack")
	stateMachine.register_state("EndTurn")
	stateMachine.register_state("EndSession")
	
	stateMachine.register_transit("WaitSession", "TurnStart", 1)
	stateMachine.register_transit("TurnStart", "WaitAttack", 1)
	stateMachine.register_transit("WaitAttack", "Attacking", 1)
	stateMachine.register_transit("WaitAttack", "EndTurn", 1)
	stateMachine.register_transit("Attacking", "EndAttack", 1)
	stateMachine.register_transit("EndAttack", "EndTurn", 1)
	stateMachine.register_transit("EndTurn", "TurnStart", 1)
	stateMachine.register_transit("EndTurn", "EndSession", 1)
	stateMachine.register_transit("EndSession", "WaitSession", 1)
	

func _process(delta: float) -> void:
	if multiplayer.is_server():
		if len(players) == 2:
			if not gameStarted:
				gameStarted = true
				rpc("change_turn")
				
		if gameStarted:
			update_tick(delta)
			update_game_time(delta)
			
			
	if stateMachine.is_transit_process("WaitSession", "TurnStart", delta):
		players[0].inControl = true
		players[1].inControl = true
		
	elif stateMachine.is_transit_process("TurnStart", "WaitAttack", delta):
		pass
	elif stateMachine.is_transit_process("WaitAttack", "Attacking", delta):
		pass
	elif stateMachine.is_transit_process("WaitAttack", "EndTurn", delta):
		pass
	elif stateMachine.is_transit_process("Attacking", "EndAttack", delta):
		pass
	elif stateMachine.is_transit_process("EndAttack", "EndTurn", delta):
		pass
	elif stateMachine.is_transit_process("EndTurn", "TurnStart", delta):
		pass
	elif stateMachine.is_transit_process("EndTurn", "EndSession", delta):
		pass
	elif stateMachine.is_transit_process("EndSession", "WaitSession", delta):
		pass
	# 상태 전환 프로세스가 없으면 각 상태에서의 행동 처리
	else:
		match stateMachine.current_state_name():
			"WaitSession":
				if len(players) == 2:
					stateMachine.transit("TurnStart")
			"TurnStart":
				stateMachine.transit("WaitAttack")
				pass
			"WaitAttack":
				
				pass
			"Attacking":
				pass
			"EndAttack":
				pass
			"EndTurn":
				pass
			"EndSession":
				pass
		#stateMachine.register_state("WaitSession")
	#stateMachine.register_state("TurnStart")
	#stateMachine.register_state("WaitAttack")
	#stateMachine.register_state("Attacking")
	#stateMachine.register_state("EndAttack")
	#stateMachine.register_state("EndTurn")
	#stateMachine.register_state("EndSession")


func update_game_time(delta: float) -> void:
	if multiplayer.is_server():
		if players[0].isAttack :
			players[0].lifeTime -= delta
			
		if players[1].isAttack :
			players[1].lifeTime -= delta
		
		ui.rpc("set_player_life_time",players[0].lifeTime, players[1].lifeTime)	
		
		
func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print(node.name)
	if node is Player:
		players.append(node as Player)
	elif is_instance_valid(node.get_instance_id()):
		add_object(node)
		
func check_transmit(transmit: Array[String]) -> bool:
	var result: bool = true
	for t in transmit:
		if not transmitQueue.has(t):
			result = false
		else:
			transmitQueue.erase(t)
	return result

@rpc("any_peer", "call_local")
func send_transmit(transmit: String):
	if not transmitQueue.has(transmit):
		transmitQueue.append(transmit)
