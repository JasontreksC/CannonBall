extends Node2D
class_name Game

var root: CannonBall = null
var ui: InGameUI = null

var players: Array[Player]
var objects: Dictionary[String, Node2D]
var freeQueue: Array[String]

var G: float = 980
var turnCount: int = 0
var gameStarted: bool = false

var tickPoolInfo: Dictionary[String, Array]
var tickPoolCallback: Dictionary[String, Callable]


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
	return
	turnCount += 1
	if turnCount % 2 == 1:
		players[0].isAttack = true
		players[0].attackChance = true
		players[1].isAttack = false
	else: 
		players[0].isAttack = false
		players[1].isAttack = true
		players[1].attackChance = true
		
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
		if tickPoolInfo[key][0] >= tickPoolInfo[key][1]:
			tickPoolCallback[key].call()
			tickPoolInfo[key][0] = 0
		
		else:
			tickPoolInfo[key][0] += delta
		

func _enter_tree() -> void:
	root = get_parent().root

func _ready() -> void:
	ui = root.uiMgr.get_current_ui_as_in_game()

func _process(delta: float) -> void:
	if multiplayer.is_server():
		if len(players) == 2:
			if not gameStarted:
				gameStarted = true
				rpc("change_turn")
		update_tick(delta)

func _on_multiplayer_spawner_spawned(node: Node) -> void:
	print(node.name)
	if node is Player:
		players.append(node as Player)
	elif is_instance_valid(node.get_instance_id()):
		add_object(node)
